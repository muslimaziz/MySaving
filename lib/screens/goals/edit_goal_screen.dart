import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/goal.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/image_picker_helper.dart';

class EditGoalScreen extends StatefulWidget {
  final Goal goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _dateController;
  late TextEditingController _noteController;

  late DateTime _selectedDate;
  late String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    // Menampilkan angka harga tanpa format desimal koma jika bilangan bulat
    _priceController = TextEditingController(
      text: widget.goal.targetPrice.toStringAsFixed(0),
    );
    _selectedDate = DateTime.parse(widget.goal.targetDate);
    _dateController = TextEditingController(
      text: DateFormat('dd MMM yyyy').format(_selectedDate),
    );
    _noteController = TextEditingController(text: widget.goal.note ?? '');
    _imagePath = widget.goal.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // Fungsi memilih foto target dari galeri
  Future<void> _pickImage() async {
    final path = await ImagePickerHelper.pickGoalImage();
    if (path != null && mounted) {
      setState(() => _imagePath = path);
    }
  }

  void _updateGoal() async {
    if (_formKey.currentState!.validate()) {
      final updatedGoal = Goal(
        id: widget.goal.id,
        name: _nameController.text.trim(),
        targetPrice: double.parse(_priceController.text),
        targetDate: _selectedDate.toIso8601String(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        image: _imagePath,
        status: widget.goal.status,
        createdAt: widget.goal.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.updateGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal dan detail target berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Kembali ke dashboard dengan membawa sinyal refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeRebuilder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Koreksi / Edit Target')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto Target (Opsional)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imagePath != null && _imagePath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcons.fromAsset(
                                AppIcons.target,
                                size: 40,
                                color: AppColors.muted,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah Foto Target',
                                style: TextStyle(color: AppColors.muted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tekan untuk memilih dari galeri',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_imagePath != null && _imagePath!.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _imagePath = null),
                      icon: AppIcons.fromAsset(
                        AppIcons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Hapus Foto',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Peringatan kecil agar pengguna tahu mereka bisa mengoreksi salah input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Salah memasukkan nominal harga? Anda bisa langsung memperbaikinya di sini tanpa harus membuat target baru.',
                    style: TextStyle(fontSize: 13, color: AppColors.text),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Target',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama target wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Koreksi Harga Target (Rp)',
                    hintText: 'Contoh: 5000000',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga target wajib diisi.';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Masukkan nominal angka yang valid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Target',
                    border: OutlineInputBorder(),
                    suffixIcon: InkWell(
                      onTap: () => _selectDate(context),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AppIcons.fromAsset(
                          AppIcons.calendar,
                          size: 20,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Simpan Perubahan Nominal',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
