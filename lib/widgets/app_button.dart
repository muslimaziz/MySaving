import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tombol ala desain: primary / secondary / ghost / danger.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final String? icon;
  final AppButtonKind kind;
  final bool expanded;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.kind = AppButtonKind.primary,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (kind) {
      AppButtonKind.primary => (AppColors.primary, Colors.white),
      AppButtonKind.secondary => (AppColors.softGreen, AppColors.primary),
      AppButtonKind.ghost => (Colors.transparent, const Color(0xFF56645F)),
      AppButtonKind.danger => (AppColors.dangerBg, AppColors.danger),
    };

    final button = Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            kind == AppButtonKind.primary ? AppShadows.primaryButton : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Image.asset(
                    'assets/icons/$icon',
                    width: 18,
                    height: 18,
                    color: foreground,
                  ),
                const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum AppButtonKind { primary, secondary, ghost, danger }
