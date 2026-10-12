import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/goal.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/format_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/page_header.dart';

class AddTransactionScreen extends StatefulWidget {
  final Goal goal;
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, required this.goal, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _amountController = TextEditingController(
      text: transaction?.amount.toStringAsFixed(0) ?? '',
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _date = transaction == null
        ? DateUtils.dateOnly(DateTime.now())
        : DateTime.tryParse(transaction.transactionDate) ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('id', 'ID'),
      initialDate: _date,
      firstDate: DateTime(2000),
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
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now().toIso8601String();
    final previous = widget.transaction;
    final transaction = TransactionModel(
      id: previous?.id,
      goalId: widget.goal.id!,
      amount: double.parse(_amountController.text),
      transactionDate: DateFormat('yyyy-MM-dd').format(_date),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      if (previous == null) {
        await DatabaseHelper.instance.createTransaction(transaction);
      } else {
        await DatabaseHelper.instance.updateTransaction(transaction);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Setoran gagal disimpan: $error')));
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
                title: widget.transaction == null
                    ? 'Tambah Tabungan'
                    : 'Edit Tabungan',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MENABUNG UNTUK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.goal.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Berapa yang kamu tabung?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          return amount == null || amount <= 0
                              ? 'Masukkan nominal yang valid.'
                              : null;
                        },
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixText: 'Rp  ',
                          prefixStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label,
                          ),
                          filled: true,
                          fillColor: AppColors.card,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: AppColors.fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: AppColors.fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: AppColors.fieldFocus,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      if (_amountController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppFormat.rupiah(
                              double.tryParse(_amountController.text) ?? 0,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      Text(
                        'Tanggal tabungan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: InputDecoration(
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
                              borderSide: BorderSide(
                                color: AppColors.fieldBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.fieldBorder,
                              ),
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
                            DateFormat('d MMMM yyyy', 'id_ID').format(_date),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Tabungan mingguan',
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.fieldBorder,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: _saving
                            ? 'Menyimpan...'
                            : (widget.transaction == null
                                  ? 'Simpan Tabungan'
                                  : 'Simpan Perubahan'),
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
      ),
    );
  }
}
