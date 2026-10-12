import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

/// Baris pengaturan ala desain: ikon, judul, subjudul,
/// lalu toggle atau chevron.
class SettingTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool? toggleValue;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasToggle = toggleValue != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? (hasToggle ? onToggle : null),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconTileBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AppIcons.fromAsset(
                    icon,
                    size: 19,
                    color: AppColors.iconTileFg,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasToggle)
                _Toggle(value: toggleValue!, onTap: onToggle)
              else
                AppIcons.fromAsset(
                  AppIcons.chevron,
                  size: 17,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final VoidCallback? onTap;

  const _Toggle({required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? AppColors.iconTileFg : const Color(0xFFCDD5D1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.small,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
