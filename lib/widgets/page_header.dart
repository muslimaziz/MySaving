import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

/// Header halaman lengkung: tombol kembali kiri, judul tengah,
/// slot kanan opsional (seperti desain).
class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? right;

  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: onBack != null
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.small,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onBack,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: AppIcons.fromAsset(
                            AppIcons.arrow,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: right,
          ),
        ],
      ),
    );
  }
}
