# MySaving

MySaving adalah aplikasi pencatat tabungan untuk membantu pengguna membuat target, mencatat setoran, dan memantau perkembangan tabungan. Aplikasi menyimpan data secara lokal dan dapat digunakan tanpa akun maupun koneksi internet.

## Fitur

- Membuat, mengubah, dan menghapus target tabungan beserta nominal, tanggal, catatan, dan foto target.
- Mencatat, mengubah, dan menghapus setoran untuk setiap target.
- Melihat total tabungan, progres per target, serta riwayat setoran.
- Melihat ringkasan setoran bulan ini dan total per bulan selama enam bulan terakhir.
- Mengatur pengingat menabung harian dan memilih waktu notifikasi.
- Mengubah nama dan foto profil. Foto profil dapat dipotong sebelum disimpan.
- Mengaktifkan mode gelap.
- Membuat dan memulihkan file backup offline. Backup mencakup target, setoran, nama profil, dan foto terkait.

## Penyimpanan dan backup

Data target, setoran, nama profil, dan pengaturan aplikasi disimpan di database SQLite lokal bernama `mysaving.db`. Lokasinya mengikuti direktori database yang disediakan oleh platform. Foto profil dan target disimpan di direktori dokumen aplikasi.

> **Penting:** file backup disimpan di lokasi yang dipilih pengguna melalui pemilih file perangkat. Memulihkan backup akan mengganti data target, setoran, dan profil yang sedang ada. Pengaturan tampilan dan pengingat tidak termasuk dalam file backup.

Semua fitur inti berjalan tanpa server. Koneksi internet tidak diperlukan untuk mencatat tabungan, membuat backup, atau memulihkan backup dari file lokal.

## Teknologi

- Flutter dan Dart
- SQLite melalui `sqflite`
- `image_picker` dan `image_cropper` untuk foto
- `file_picker` untuk menyimpan dan memilih file backup
- `flutter_local_notifications` dan `timezone` untuk pengingat harian
- `intl` untuk format tanggal dan angka lokal Indonesia

## Menjalankan aplikasi

Pastikan Flutter SDK yang terpasang memenuhi batas versi di `pubspec.lock` dan perangkat atau emulator sudah tersedia.

```bash
flutter pub get
flutter run
```

Untuk membuat APK Android:

```bash
flutter build apk
```

## Izin perangkat

- **Notifikasi:** izin notifikasi diminta ketika pengguna mengaktifkan pengingat.
- **Foto:** aplikasi membuka pemilih foto sistem dan hanya memakai foto yang dipilih pengguna. iOS memiliki keterangan penggunaan galeri di `ios/Runner/Info.plist`.

## Struktur proyek

```text
lib/            Kode aplikasi Flutter
  database/     Database SQLite dan operasi data
  models/       Model target, setoran, dan ringkasan target
  screens/      Layar beranda, target, setoran, profil, dan pengaturan
  theme/        Warna, tema terang/gelap, dan transisi halaman
  utils/        Format data, pemilih gambar, backup, dan pengingat
  widgets/      Komponen UI yang digunakan bersama

assets/         Font, ikon, logo, dan gambar aplikasi
```

## Catatan

- Nama package Dart tetap `mysaving`; nama yang terlihat oleh pengguna adalah **MySaving**.
- Backup merupakan file JSON lokal dan tidak otomatis tersinkron ke cloud atau perangkat lain.
