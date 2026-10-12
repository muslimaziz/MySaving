import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import '../utils/format_helper.dart';

/// Label + kotak input melengkung ala desain (`.field-wrap`).
class FormFieldWrap extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;
  final String? prefix;

  const FormFieldWrap({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                  ),
                ),
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentDark,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.fieldBorder),
            borderRadius: BorderRadius.circular(16),
            color: AppColors.card,
          ),
          child: Row(
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    prefix!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label,
                    ),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

/// Input teks di dalam `FormFieldWrap` tanpa border sendiri.
class BareTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool numeric;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const BareTextField({
    super.key,
    this.controller,
    this.hint = '',
    this.numeric = false,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.faint),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: InputBorder.none,
      ),
    );
  }
}

/// Tanggal (hanya bisa dipilih lewat kalender).
class DateField extends StatefulWidget {
  final TextEditingController controller;
  final DateTime initialDate;
  final ValueChanged<DateTime>? onChanged;
  final String? Function(String?)? validator;

  const DateField({
    super.key,
    required this.controller,
    required this.initialDate,
    this.onChanged,
    this.validator,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
      widget.controller.text = AppFormat.prettyDate(
        AppFormat.toIsoDate(picked),
      );
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.fieldBorder),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.card,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.controller.text,
                style: TextStyle(fontSize: 14, color: AppColors.text),
              ),
            ),
            AppIcons.fromAsset(
              AppIcons.calendar,
              size: 20,
              color: AppColors.iconTileFg,
            ),
          ],
        ),
      ),
    );
  }
}
