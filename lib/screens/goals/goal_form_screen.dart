import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/goal.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/page_header.dart';

/// Form buat dan edit target, mengikuti layar TargetForm di folder desain.
class GoalFormScreen extends StatefulWidget {
  final Goal? goal;

  const GoalFormScreen({super.key, this.goal});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _date;
  late final TextEditingController _note;
  DateTime? _selectedDate;
  String? _image;
  bool _saving = false;

  bool get _editing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _name = TextEditingController(text: goal?.name ?? '');
    _price = TextEditingController(
      text: goal == null ? '' : goal.targetPrice.toStringAsFixed(0),
    );
    _selectedDate = goal == null ? null : DateTime.tryParse(goal.targetDate);
    _date = TextEditingController(
      text: _selectedDate == null
          ? ''
          : DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate!),
    );
    _note = TextEditingController(text: goal?.note ?? '');
    _image = goal?.image;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _date.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('id', 'ID'),
      initialDate: _selectedDate != null && !_selectedDate!.isBefore(today)
          ? _selectedDate!
          : today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: Theme.of(context).datePickerTheme.copyWith(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _date.text = DateFormat('d MMMM yyyy', 'id_ID').format(picked);
    });
  }

  Future<void> _pickImage() async {
    final path = await ImagePickerHelper.pickGoalImage();
    if (path != null && mounted) setState(() => _image = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal target terlebih dahulu.')),
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now().toIso8601String();
    final previous = widget.goal;
    try {
      final goal = Goal(
        id: previous?.id,
        name: _name.text.trim(),
        targetPrice: double.parse(_price.text),
        targetDate: _selectedDate!.toIso8601String(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        image: _image,
        status: previous?.status ?? 'Active',
        createdAt: previous?.createdAt ?? now,
        updatedAt: now,
      );
      if (_editing) {
        await DatabaseHelper.instance.updateGoal(goal);
      } else {
        await DatabaseHelper.instance.createGoal(goal);
      }
      if (mounted) Navigator.pop(context, _editing ? goal : true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Target gagal disimpan: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeRebuilder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: _editing ? 'Edit Target' : 'Buat Target Baru',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Gambar target ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.label,
                              ),
                            ),
                            TextSpan(
                              text: '(opsional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.faint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF3EF),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: const Color(0xFFAEBDB7)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _image != null && _image!.isNotEmpty
                              ? Image.file(
                                  File(_image!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppIcons.fromAsset(
                                      AppIcons.image,
                                      color: AppColors.iconTileFg,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Pilih dari perangkat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.iconTileFg,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _field(
                        label: 'Nama target',
                        controller: _name,
                        hint: 'Contoh: Laptop baru',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama target wajib diisi.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        label: 'Harga target',
                        controller: _price,
                        hint: '0',
                        prefix: 'Rp',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          return amount == null || amount <= 0
                              ? 'Masukkan nominal yang valid.'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _dateField(),
                      const SizedBox(height: 16),
                      _field(
                        label: 'Catatan',
                        controller: _note,
                        hint: 'Tambahkan catatan untuk target ini',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: _saving
                            ? 'Menyimpan...'
                            : (_editing ? 'Simpan Perubahan' : 'Buat Target'),
                        icon: AppIcons.check,
                        onPressed: _saving ? null : _save,
                      ),
                      if (_editing) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Hapus Target',
                          icon: AppIcons.delete,
                          kind: AppButtonKind.danger,
                          onPressed: () => Navigator.pop(context, 'delete'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? prefix,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 14, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix == null ? null : '$prefix  ',
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
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
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Tanggal target',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
            ),
          ),
        ),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Pilih tanggal',
              suffixIconConstraints: const BoxConstraints.tightFor(
                width: 52,
                height: 52,
              ),
              suffixIcon: Center(
                child: AppIcons.fromAsset(
                  AppIcons.calendar,
                  size: 20,
                  color: AppColors.iconTileFg,
                ),
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
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
                borderSide: BorderSide(
                  color: AppColors.fieldFocus,
                  width: 1.5,
                ),
              ),
            ),
            child: Text(
              _date.text.isEmpty ? 'Pilih tanggal' : _date.text,
              style: TextStyle(
                color: _date.text.isEmpty ? AppColors.faint : AppColors.text,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
