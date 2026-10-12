import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import 'app_button.dart';

/// Tampilan kosong ala desain: ikon dompet + tombol aksi.
class EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.iconTileBg,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(
                  child: AppIcons.fromAsset(
                    AppIcons.wallet,
                    size: 50,
                    color: AppColors.iconTileFg,
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4C979),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcons.fromAsset(
                        AppIcons.add,
                        size: 18,
                        color: const Color(0xFF6B4A18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Mulai tujuan pertamamu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Punya sesuatu yang kamu impikan? Buat target dan mulai menabung sedikit demi sedikit.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Buat Target',
            icon: AppIcons.add,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
