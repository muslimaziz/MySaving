import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Progress bar melengkung. `light` untuk latar gelap
/// (track putih transparan, isi lime) — otherwise kuning.
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final bool light;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.light = false,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: clamped,
          backgroundColor: light
              ? const Color(0x33FFFFFF) // white/20
              : AppColors.track,
          valueColor: AlwaysStoppedAnimation(
            light ? AppColors.lime : AppColors.accent,
          ),
          minHeight: height,
        ),
      ),
    );
  }
}
