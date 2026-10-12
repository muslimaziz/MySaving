import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../widgets/page_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Tentang MySaving',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo_white.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              semanticLabel: 'Logo MySaving',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'MySaving',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bantu impianmu jadi lebih dekat, satu tabungan dalam satu waktu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Apa itu MySaving?',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MySaving membantu kamu merencanakan tabungan, mencatat setoran, dan melihat perkembangan setiap target. Buat tujuan sesuai kebutuhanmu, lalu pantau progresnya dari waktu ke waktu.',
                    style: TextStyle(
                      color: AppColors.label,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Fitur utama',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _feature(
                    AppIcons.target,
                    'Target tabungan',
                    'Buat target dengan nominal dan tanggal yang kamu inginkan.',
                  ),
                  _feature(
                    AppIcons.moneyIn,
                    'Catatan setoran',
                    'Simpan dan kelola riwayat uang yang sudah ditabung.',
                  ),
                  _feature(
                    AppIcons.bell,
                    'Pengingat harian',
                    'Pilih jam pengingat agar kamu ingat untuk menabung.',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        AppIcons.fromAsset(
                          AppIcons.storage,
                          size: 20,
                          color: AppColors.iconTileFg,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data tersimpan di perangkat dan dapat digunakan tanpa akun.',
                            style: TextStyle(
                              color: AppColors.label,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        color: AppColors.faint,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.iconTileBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AppIcons.fromAsset(
                  icon,
                  size: 20,
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
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
