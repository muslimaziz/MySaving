import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import 'goal_data_notifier.dart';

class OfflineBackupService {
  static const _formatVersion = 1;

  static Future<Uri?> exportBackup() async {
    final db = await DatabaseHelper.instance.database;
    final goals = await db.query('goals', orderBy: 'id ASC');
    final transactions = await db.query('transactions', orderBy: 'id ASC');
    final settings = await db.query(
      'app_settings',
      columns: ['setting_key', 'setting_value'],
      where: 'setting_key IN (?, ?)',
      whereArgs: ['user_name', 'profile_image'],
    );
    final settingsByKey = {
      for (final row in settings)
        row['setting_key'] as String: row['setting_value'] as String,
    };

    final backupGoals = <Map<String, Object?>>[];
    for (final goal in goals) {
      final row = Map<String, Object?>.from(goal);
      final imagePath = row.remove('image') as String?;
      row['image_data'] = await _encodeImage(imagePath);
      backupGoals.add(row);
    }

    final profileImage = await _encodeImage(settingsByKey['profile_image']);
    final now = DateTime.now();
    final fileName =
        'mysaving_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.json';
    final payload = <String, Object?>{
      'app': 'MySaving',
      'format_version': _formatVersion,
      'created_at': now.toIso8601String(),
      'goals': backupGoals,
      'transactions': transactions,
      'profile': {
        'name': settingsByKey['user_name'],
        'image_data': profileImage,
      },
    };

    return FilePicker.saveFile(
      dialogTitle: 'Simpan backup MySaving',
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(payload))),
      type: FileType.custom,
      allowedExtensions: const ['json'],
      mimeType: 'application/json',
    );
  }

  static Future<void> restoreBackup(Uint8List bytes) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const FormatException('File backup tidak valid atau rusak.');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'MySaving' ||
        decoded['format_version'] != _formatVersion) {
      throw const FormatException(
        'File bukan backup MySaving yang didukung.',
      );
    }

    final goals = _readMapList(decoded['goals'], 'target');
    final transactions = _readMapList(decoded['transactions'], 'setoran');
    final profile = decoded['profile'];
    if (profile is! Map<String, dynamic>) {
      throw const FormatException('Data profil pada backup tidak valid.');
    }
    final name = profile['name'];
    if (name != null && name is! String) {
      throw const FormatException('Nama profil pada backup tidak valid.');
    }

    final goalIds = <int>{};
    for (final goal in goals) {
      final id = goal['id'];
      if (id is! int || !goalIds.add(id)) {
        throw const FormatException('ID target pada backup tidak valid.');
      }
    }
    for (final transaction in transactions) {
      if (transaction['id'] is! int ||
          transaction['goal_id'] is! int ||
          !goalIds.contains(transaction['goal_id'])) {
        throw const FormatException('Data setoran pada backup tidak valid.');
      }
    }

    final createdFiles = <String>[];
    try {
      final db = await DatabaseHelper.instance.database;
      await db.transaction((txn) async {
        await txn.delete('transactions');
        await txn.delete('goals');
        await txn.delete(
          'app_settings',
          where: 'setting_key IN (?, ?)',
          whereArgs: ['user_name', 'profile_image'],
        );

        for (final source in goals) {
          final row = Map<String, Object?>.from(source);
          final imageData = row.remove('image_data') as String?;
          row['image'] = await _restoreImage(
            imageData,
            folder: 'goal_images',
            prefix: 'goal',
            createdFiles: createdFiles,
          );
          await txn.insert('goals', row, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        for (final transaction in transactions) {
          await txn.insert(
            'transactions',
            transaction,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        if (name is String && name.trim().isNotEmpty) {
          await txn.insert('app_settings', {
            'setting_key': 'user_name',
            'setting_value': name.trim(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        final profileImage = await _restoreImage(
          profile['image_data'] as String?,
          folder: 'profile_images',
          prefix: 'profile',
          createdFiles: createdFiles,
        );
        if (profileImage != null) {
          await txn.insert('app_settings', {
            'setting_key': 'profile_image',
            'setting_value': profileImage,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
      notifyGoalDataChanged();
    } catch (_) {
      for (final path in createdFiles) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      rethrow;
    }
  }

  static List<Map<String, Object?>> _readMapList(
    Object? value,
    String label,
  ) {
    if (value is! List) {
      throw FormatException('Daftar $label pada backup tidak valid.');
    }
    return value.map((item) {
      if (item is! Map) {
        throw FormatException('Data $label pada backup tidak valid.');
      }
      return Map<String, Object?>.from(item);
    }).toList();
  }

  static Future<String?> _encodeImage(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return base64Encode(await file.readAsBytes());
  }

  static Future<String?> _restoreImage(
    String? encoded, {
    required String folder,
    required String prefix,
    required List<String> createdFiles,
  }) async {
    if (encoded == null || encoded.isEmpty) return null;
    final bytes = base64Decode(encoded);
    final appDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(p.join(appDirectory.path, folder));
    await imageDirectory.create(recursive: true);
    final filePath = p.join(
      imageDirectory.path,
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${createdFiles.length}.jpg',
    );
    await File(filePath).writeAsBytes(bytes, flush: true);
    createdFiles.add(filePath);
    return filePath;
  }
}
