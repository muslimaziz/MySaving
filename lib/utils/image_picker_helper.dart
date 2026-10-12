import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';

/// Helper memilih foto target dari galeri dan menyimpan salinannya
/// ke folder dokumen aplikasi agar tetap awet.
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Memilih foto dari galeri. Mengembalikan path file yang sudah
  /// disimpan, atau null jika pengguna membatalkan.
  static Future<String?> pickGoalImage() async {
    return _pickAndSaveImage('goal_images', 'goal');
  }

  static Future<String?> pickProfileImage() async {
    return _pickAndSaveImage('profile_images', 'profile', cropToAvatar: true);
  }

  static Future<String?> _pickAndSaveImage(
    String folder,
    String prefix, {
    bool cropToAvatar = false,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked == null) return null;

    var sourcePath = picked.path;
    var extension = p.extension(picked.path);
    if (cropToAvatar) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 720,
        maxHeight: 720,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 88,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Foto Profil',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Atur Foto Profil',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );
      if (cropped == null) return null;
      sourcePath = cropped.path;
      extension = '.jpg';
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/$folder');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName =
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedPath = '${imagesDir.path}/$fileName';
    await File(sourcePath).copy(savedPath);
    return savedPath;
  }

  /// Menghapus file foto target dari penyimpanan aplikasi.
  static Future<void> deleteGoalImage(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteProfileImage(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
