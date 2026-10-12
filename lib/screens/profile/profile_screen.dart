import 'dart:async';

import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/format_helper.dart';
import '../../utils/goal_data_notifier.dart';
import '../../utils/image_picker_helper.dart';
import '../../utils/saving_reminder_service.dart';
import '../../widgets/page_header.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/setting_tile.dart';
import 'about_screen.dart';
import 'data_management_screen.dart';
import 'monthly_summary_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String? profileImage;
  final void Function(String name, String? imagePath) onProfileChanged;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.onProfileChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileStats> _stats;
  bool _reminders = false;
  bool _updatingReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _darkMode = AppThemeController.instance.isDarkMode;
  bool _editingProfile = false;
  bool _savingProfile = false;
  late final TextEditingController _nameController;
  late String _profileName;
  late String? _profileImage;
  String _lastSavedName = '';
  String? _lastSavedImage;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _profileName = widget.userName;
    _profileImage = widget.profileImage;
    _lastSavedName = widget.userName;
    _lastSavedImage = widget.profileImage;
    _nameController = TextEditingController(text: widget.userName);
    _stats = _loadStats();
    _loadReminderSettings();
    goalDataVersion.addListener(_onGoalDataChanged);
  }

  Future<void> _loadReminderSettings() async {
    try {
      final enabled = await SavingReminderService.isEnabled();
      final (hour, minute) = await SavingReminderService.readTime();
      if (!mounted) return;
      setState(() {
        _reminders = enabled;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      });
    } catch (_) {
      // Tetap tampilkan pengingat nonaktif jika pengaturan belum bisa dibaca.
    }
  }

  Future<void> _toggleReminder() async {
    if (_updatingReminder) return;
    setState(() => _updatingReminder = true);
    try {
      if (_reminders) {
        await SavingReminderService.disable();
        if (mounted) setState(() => _reminders = false);
      } else {
        final enabled = await SavingReminderService.enable(
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
        if (!mounted) return;
        if (enabled) {
          setState(() => _reminders = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin notifikasi belum diberikan.')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengingat gagal diperbarui: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingReminder = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    try {
      await SavingReminderService.setTime(
        hour: picked.hour,
        minute: picked.minute,
      );
      if (mounted) setState(() => _reminderTime = picked);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Waktu pengingat gagal disimpan: $error')),
        );
      }
    }
  }

  String get _reminderTimeLabel {
    final hour = _reminderTime.hour.toString().padLeft(2, '0');
    final minute = _reminderTime.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
    );
  }

  Future<void> _openMonthlySummary() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const MonthlySummaryScreen()),
    );
  }

  Future<void> _openDataManagement() async {
    final restored = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const DataManagementScreen()),
    );
    if (restored != true || !mounted) return;
    final name = await DatabaseHelper.instance.readUserName();
    final image = await DatabaseHelper.instance.readProfileImage();
    if (!mounted) return;
    _saveDebounce?.cancel();
    setState(() {
      _editingProfile = false;
      _profileName = name ?? '';
      _profileImage = image;
      _lastSavedName = name ?? '';
      _lastSavedImage = image;
      _nameController.text = name ?? '';
    });
    widget.onProfileChanged(name ?? '', image);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editingProfile &&
        (oldWidget.userName != widget.userName ||
            oldWidget.profileImage != widget.profileImage)) {
      _profileName = widget.userName;
      _profileImage = widget.profileImage;
      _lastSavedName = widget.userName;
      _lastSavedImage = widget.profileImage;
      _nameController.text = widget.userName;
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    goalDataVersion.removeListener(_onGoalDataChanged);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _setDarkMode(bool enabled) async {
    setState(() => _darkMode = enabled);
    AppThemeController.instance.setDarkMode(enabled);
    try {
      await DatabaseHelper.instance.saveSetting(
        'dark_mode',
        enabled.toString(),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _darkMode = !enabled);
      AppThemeController.instance.setDarkMode(!enabled);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengaturan tema gagal disimpan: $error')),
      );
    }
  }

  Future<_ProfileStats> _loadStats() async {
    final values = await Future.wait([
      DatabaseHelper.instance.getGoalCount(),
      DatabaseHelper.instance.getGrandTotal(),
    ]);
    return _ProfileStats(values[0] as int, values[1] as double);
  }

  Future<void> _refresh() async {
    final next = _loadStats();
    setState(() {
      _stats = next;
    });
    await next;
  }

  void _onGoalDataChanged() {
    if (mounted) _refresh();
  }

  void _toggleProfileEdit() {
    if (!_editingProfile) {
      setState(() {
        _editingProfile = true;
        _profileName = widget.userName;
        _profileImage = widget.profileImage;
        _nameController.text = widget.userName;
      });
      return;
    }
    _saveDebounce?.cancel();
    _saveProfile();
    setState(() => _editingProfile = false);
  }

  void _onProfileNameChanged(String value) {
    setState(() => _profileName = value);
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 450), _saveProfile);
  }

  Future<void> _pickProfilePhoto() async {
    final path = await ImagePickerHelper.pickProfileImage();
    if (path == null || !mounted) return;
    setState(() => _profileImage = path);
    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    final name = _profileName.trim();
    if (name.isEmpty || _savingProfile) return;
    if (name == _lastSavedName && _profileImage == _lastSavedImage) return;
    final image = _profileImage;
    final oldImage = _lastSavedImage;
    var saved = false;
    setState(() => _savingProfile = true);
    try {
      await DatabaseHelper.instance.saveUserName(name);
      await DatabaseHelper.instance.saveProfileImage(image);
      saved = true;
      _lastSavedName = name;
      _lastSavedImage = image;
      widget.onProfileChanged(name, image);
      if (oldImage != image) {
        await ImagePickerHelper.deleteProfileImage(oldImage);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil gagal disimpan: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _savingProfile = false);
        if (saved &&
            (_profileName.trim() != _lastSavedName ||
                _profileImage != _lastSavedImage)) {
          _saveDebounce?.cancel();
          _saveDebounce = Timer(
            const Duration(milliseconds: 100),
            _saveProfile,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(title: 'Profil & Pengaturan'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: FutureBuilder<_ProfileStats>(
                future: _stats,
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? const _ProfileStats(0, 0);
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(26),
                        child: InkWell(
                          onTap: _editingProfile ? null : _toggleProfileEdit,
                          borderRadius: BorderRadius.circular(26),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _editingProfile
                                      ? _pickProfilePhoto
                                      : null,
                                  child: ProfileAvatar(
                                    name: _profileName,
                                    imagePath: _profileImage,
                                    size: 64,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_editingProfile)
                                        TextField(
                                          controller: _nameController,
                                          onChanged: _onProfileNameChanged,
                                          onSubmitted: (_) => _saveProfile(),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.done,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Nama profil',
                                            hintStyle: TextStyle(
                                              color: Colors.white60,
                                            ),
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                          ),
                                        )
                                      else
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          child: Text(
                                            widget.userName,
                                            key: ValueKey(widget.userName),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _editingProfile
                                            ? (_savingProfile
                                                  ? 'Menyimpan perubahan…'
                                                  : 'Perubahan tersimpan otomatis')
                                            : 'Penabung konsisten',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white60,
                                        ),
                                      ),
                                      if (_editingProfile)
                                        Wrap(
                                          spacing: 4,
                                          children: [
                                            TextButton(
                                              onPressed: _pickProfilePhoto,
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(48, 30),
                                              ),
                                              child: const Text('Ubah foto'),
                                            ),
                                            if (_profileImage != null)
                                              TextButton(
                                                onPressed: () async {
                                                  setState(
                                                    () => _profileImage = null,
                                                  );
                                                  await _saveProfile();
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.white70,
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(
                                                    48,
                                                    30,
                                                  ),
                                                ),
                                                child: const Text('Hapus foto'),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_editingProfile)
                                  IconButton(
                                    tooltip: 'Selesai mengedit profil',
                                    onPressed: _toggleProfileEdit,
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  AppIcons.fromAsset(
                                    AppIcons.edit,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('TARGET', '${stats.targets}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              'TERKUMPUL',
                              AppFormat.rupiah(stats.saved),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle('PREFERENSI'),
                      _settingsCard([
                        SettingTile(
                          icon: AppIcons.bell,
                          title: 'Pengingat menabung',
                          subtitle: _reminders
                              ? 'Setiap hari, $_reminderTimeLabel'
                              : 'Nonaktif · Pilih jam pengingat',
                          toggleValue: _reminders,
                          onTap: _pickReminderTime,
                          onToggle: _toggleReminder,
                        ),
                        Divider(
                          height: 1,
                          indent: 68,
                          color: AppColors.divider,
                        ),
                        SettingTile(
                          icon: AppIcons.moon,
                          title: 'Mode gelap',
                          subtitle: _darkMode ? 'Aktif' : 'Nonaktif',
                          toggleValue: _darkMode,
                          onToggle: () => _setDarkMode(!_darkMode),
                        ),
                        Divider(
                          height: 1,
                          indent: 68,
                          color: AppColors.divider,
                        ),
                        SettingTile(
                          icon: AppIcons.trend,
                          title: 'Ringkasan bulanan',
                          subtitle: 'Lihat setoran 6 bulan terakhir',
                          onTap: _openMonthlySummary,
                        ),
                        Divider(
                          height: 1,
                          indent: 68,
                          color: AppColors.divider,
                        ),
                        SettingTile(
                          icon: AppIcons.storage,
                          title: 'Kelola data',
                          subtitle: 'Backup dan pulihkan data offline',
                          onTap: _openDataManagement,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _sectionTitle('TENTANG'),
                      _settingsCard([
                        SettingTile(
                          icon: AppIcons.info,
                          title: 'Tentang MySaving',
                          subtitle: 'Versi 1.0.0 · Offline',
                          onTap: _openAbout,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      Text(
                        'Dibuat untuk membantu impianmu\njadi lebih dekat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.6,
                          color: AppColors.faint,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.faint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: AppColors.faint,
      ),
    ),
  );

  Widget _settingsCard(List<Widget> children) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(children: children),
  );
}

class _ProfileStats {
  final int targets;
  final double saved;

  const _ProfileStats(this.targets, this.saved);
}
