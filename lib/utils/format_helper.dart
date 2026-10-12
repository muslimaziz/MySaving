import 'package:intl/intl.dart';

/// Helper format Rupiah & tanggal ala desain (id-ID).
class AppFormat {
  /// Rp 18.000.000
  static String rupiah(double value) {
    return 'Rp${NumberFormat.decimalPattern('id_ID').format(value.round())}';
  }

  /// Rp 18 jt / Rp 7,5 jt / Rp 750 rb
  static String shortRupiah(double value) {
    if (value >= 1000000) {
      final jt = value / 1000000;
      final text = jt.toStringAsFixed(1);
      final trimmed = text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
      return 'Rp$trimmed jt';
    }
    if (value >= 1000) {
      return 'Rp${(value / 1000).round()} rb';
    }
    return rupiah(value);
  }

  /// 30 Desember 2026 — menerima string ISO (date atau datetime).
  static String prettyDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      return DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  /// 2026-12-30 (untuk disimpan ke database)
  static String toIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  AppFormat._();
}
