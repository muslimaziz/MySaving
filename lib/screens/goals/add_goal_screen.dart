import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/goal.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/image_picker_helper.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Fungsi memunculkan kalender
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Validasi: Tidak boleh sebelum hari ini
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format tampilan tanggal menggunakan package intl
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

  // Fungsi menyimpan data ke SQLite
  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      // Pastikan tanggal sudah dipilih
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal target terlebih dahulu!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final newGoal = Goal(
          name: _nameController.text.trim(),
          targetPrice: double.parse(_priceController.text),
          targetDate: _selectedDate!.toIso8601String(),
          image: _imagePath,
          note: _noteController.text.trim(),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        await DatabaseHelper.instance.createGoal(newGoal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target tabungan berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Cetak error ke terminal debug
        debugPrint('ERROR SAAT MENYIMPAN: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeRebuilder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Tambah Target')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Foto Target (Opsional)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imagePath != null
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
                const SizedBox(height: 16),

                // 2. Input Nama Target
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Target',
                    hintText: 'Contoh: Laptop Gaming',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama target wajib diisi.';
                    }
                    if (value.trim().length < 2) {
                      return 'Nama target minimal 2 karakter.';
                    }
                    if (value.length > 100) {
                      return 'Nama target maksimal 100 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Input Harga Target
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Target (Rp)',
                    hintText: 'Contoh: 10000000',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga target wajib diisi.';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Harga target harus berupa angka.';
                    }
                    if (number <= 0) {
                      return 'Harga target harus lebih dari Rp0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. Input Tanggal Target
                TextFormField(
                  controller: _dateController,
                  readOnly: true, // Hanya bisa diisi lewat popup kalender
                  decoration: InputDecoration(
                    labelText: 'Tanggal Target',
                    hintText: 'Pilih tenggat waktu',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Target tanggal wajib dipilih.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 5. Input Catatan
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Contoh: Digunakan untuk kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.length > 500) {
                      return 'Catatan maksimal 500 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 6. Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    child: const Text(
                      'Simpan Target',
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
