import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/page_header.dart';
import '../../widgets/profile_avatar.dart';

class ProfileEditResult {
  final String name;
  final String? imagePath;

  const ProfileEditResult({required this.name, required this.imagePath});
}

class ProfileEditScreen extends StatefulWidget {
  final String name;
  final String? imagePath;

  const ProfileEditScreen({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _imagePath = widget.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await ImagePickerHelper.pickProfileImage();
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    setState(() => _saving = true);
    try {
      await DatabaseHelper.instance.saveUserName(name);
      await DatabaseHelper.instance.saveProfileImage(_imagePath);
      if (widget.imagePath != _imagePath) {
        await ImagePickerHelper.deleteProfileImage(widget.imagePath);
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        ProfileEditResult(name: name, imagePath: _imagePath),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil gagal disimpan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Edit Profil',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  children: [
                    Center(
                      child: Semantics(
                        button: true,
                        label: 'Ubah foto profil',
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickPhoto,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ProfileAvatar(
                                key: ValueKey(_imagePath),
                                name: _nameController.text,
                                imagePath: _imagePath,
                                size: 112,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.bg,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: AppIcons.fromAsset(
                                      AppIcons.edit,
                                      size: 16,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _pickPhoto,
                      icon: AppIcons.fromAsset(
                        AppIcons.image,
                        size: 17,
                        color: AppColors.iconTileFg,
                      ),
                      label: const Text('Ubah foto profil'),
                    ),
                    if (_imagePath != null) ...[
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _imagePath = null),
                          child: Text(
                            'Hapus foto',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Nama',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: 40,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _save(),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Nama tidak boleh kosong.'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama',
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.fieldBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.fieldFocus),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: _saving ? 'Menyimpan...' : 'Simpan Profil',
                      icon: AppIcons.check,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
