import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/offline_backup_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/page_header.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _busy = false;

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final location = await OfflineBackupService.exportBackup();
      if (!mounted || location == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File backup berhasil disimpan.')),
      );
    } catch (error) {
      if (mounted) _showError('Backup gagal dibuat: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pulihkan backup?'),
        content: const Text(
          'Data target, setoran, dan profil saat ini akan diganti dengan isi '
          'backup. Pastikan backup yang dipilih benar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pilih backup'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (selected == null) return;
      await OfflineBackupService.restoreBackup(await selected.readAsBytes());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup berhasil dipulihkan.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showError('Backup gagal dipulihkan: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    final cleanMessage = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('FormatException: ', '');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(cleanMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Kelola Data',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcons.fromAsset(
                          AppIcons.storage,
                          size: 21,
                          color: AppColors.iconTileFg,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Backup disimpan sebagai file di perangkat. '
                            'Tidak perlu akun atau koneksi internet. '
                            'Target, setoran, nama profil, dan foto ikut disertakan.',
                            style: TextStyle(
                              color: AppColors.label,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Backup data',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simpan salinan data untuk dipindahkan atau dipulihkan nanti.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _busy ? 'Memproses...' : 'Buat Backup',
                    icon: AppIcons.storage,
                    onPressed: _busy ? null : _exportBackup,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Pulihkan dari Backup',
                    icon: AppIcons.arrow,
                    kind: AppButtonKind.secondary,
                    onPressed: _busy ? null : _restoreBackup,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'File backup berisi foto dalam bentuk data gambar. Simpan '
                    'file tersebut di lokasi aman. Pemulihan akan mengganti '
                    'target dan setoran yang ada.',
                    style: TextStyle(
                      color: AppColors.faint,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  if (Platform.isAndroid || Platform.isIOS) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Setelah membuat backup, pilih lokasi penyimpanan '
                        'pada jendela file perangkat.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
