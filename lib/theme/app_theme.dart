import 'package:flutter/material.dart';

/// Palet warna & tema dari desain (folder `desain/`).
class AppColors {
  /// Dipilih oleh [AppThemeController] sebelum halaman menggambar ulang.
  static bool darkMode = false;

  static Color _color(Color light, Color dark) => darkMode ? dark : light;

  // Hijau tua (primary)
  static Color get primary =>
      _color(const Color(0xFF203F36), const Color(0xFF557764));
  static Color get primaryDark =>
      _color(const Color(0xFF163129), const Color(0xFF19392D));

  // Aksen kuning
  static Color get accent =>
      _color(const Color(0xFFE7A84B), const Color(0xFFE9B65E));
  static Color get accentDark =>
      _color(const Color(0xFFD7922F), const Color(0xFFE9B65E));

  // Lime
  static Color get lime =>
      _color(const Color(0xFFD8F29E), const Color(0xFF384A32));

  // Latar & kartu
  static Color get bg =>
      _color(const Color(0xFFF7F8F5), const Color(0xFF121A16));
  static Color get card =>
      _color(const Color(0xFFFFFFFF), const Color(0xFF1D2923));
  static Color get navBar =>
      _color(const Color(0xFFFBFCFA), const Color(0xFF19231E));

  // Teks
  static Color get text =>
      _color(const Color(0xFF1B2D27), const Color(0xFFFFFFFF));
  static Color get label =>
      _color(const Color(0xFF43544E), const Color(0xFFF5F7F5));
  static Color get muted =>
      _color(const Color(0xFF8A9590), const Color(0xFFC2CDC6));
  static Color get faint =>
      _color(const Color(0xFF9AA39F), const Color(0xFFAEBBB3));

  // Komponen
  static Color get track =>
      _color(const Color(0xFFE6EBE8), const Color(0xFF34423A));
  static Color get chipBg =>
      _color(const Color(0xFFEAEEEB), const Color(0xFF2A3730));
  static Color get fieldBorder =>
      _color(const Color(0xFFE1E6E3), const Color(0xFF3A4940));
  static Color get fieldFocus =>
      _color(const Color(0xFF78958A), const Color(0xFF8DB7A2));
  static Color get softGreen =>
      _color(const Color(0xFFE2EEE8), const Color(0xFF293A31));
  static Color get iconTileBg =>
      _color(const Color(0xFFEDF4ED), const Color(0xFF293830));
  static Color get iconTileFg =>
      _color(const Color(0xFF315448), const Color(0xFFB3D4C2));
  static Color get divider =>
      _color(const Color(0xFFEEF1EF), const Color(0xFF303D35));

  // Status
  static Color get danger =>
      _color(const Color(0xFFB74833), const Color(0xFFE18A78));
  static Color get dangerBg =>
      _color(const Color(0xFFFFF0EC), const Color(0xFF402C28));
  static Color get dangerText =>
      _color(const Color(0xFFBA604E), const Color(0xFFE49A88));
  static Color get success =>
      _color(const Color(0xFF396023), const Color(0xFFA7CF83));
  static Color get successBg =>
      _color(const Color(0xFFDFF3CE), const Color(0xFF303E2A));

  // Biru (logo & splash)
  static Color get blue =>
      _color(const Color(0xFF2563EB), const Color(0xFF78A0FF));

  // Avatar
  static Color get avatarAmber =>
      _color(const Color(0xFFF0C575), const Color(0xFF70582F));
  static Color get avatarText =>
      _color(const Color(0xFF3E3A24), const Color(0xFFFFE7AE));

  AppColors._();
}

class AppThemeController extends ChangeNotifier {
  AppThemeController._();
  static final AppThemeController instance = AppThemeController._();

  bool get isDarkMode => AppColors.darkMode;

  void setDarkMode(bool enabled) {
    if (AppColors.darkMode == enabled) return;
    AppColors.darkMode = enabled;
    notifyListeners();
  }
}

class AppThemeRebuilder extends StatelessWidget {
  final WidgetBuilder builder;

  const AppThemeRebuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) => builder(context),
    );
  }
}

/// Bayangan lembut ala desain Tailwind.
class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x0F263A31), blurRadius: 35, offset: Offset(0, 10)),
  ];
  static const cardHover = [
    BoxShadow(color: Color(0x1A263A31), blurRadius: 40, offset: Offset(0, 16)),
  ];
  static const small = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const primaryButton = [
    BoxShadow(color: Color(0x33203F36), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const progressCard = [
    BoxShadow(color: Color(0x2E203F36), blurRadius: 30, offset: Offset(0, 14)),
  ];

  AppShadows._();
}

/// Tema aplikasi MySaving (Manrope + hijau tua).
ThemeData buildAppTheme({bool dark = false}) {
  final previousMode = AppColors.darkMode;
  AppColors.darkMode = dark;
  final base = ThemeData(fontFamily: 'Manrope', useMaterial3: true);
  final theme = base.copyWith(
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
      decorationColor: AppColors.text,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
      error: AppColors.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? AppColors.text : AppColors.primary,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: AppColors.card,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      todayBackgroundColor: WidgetStatePropertyAll<Color?>(AppColors.accent),
      todayForegroundColor: WidgetStatePropertyAll<Color?>(
        AppColors.primaryDark,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _FadePageTransitionsBuilder(),
        TargetPlatform.iOS: _FadePageTransitionsBuilder(),
        TargetPlatform.macOS: _FadePageTransitionsBuilder(),
        TargetPlatform.windows: _FadePageTransitionsBuilder(),
        TargetPlatform.linux: _FadePageTransitionsBuilder(),
        TargetPlatform.fuchsia: _FadePageTransitionsBuilder(),
      },
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
  AppColors.darkMode = previousMode;
  return theme;
}

/// Transisi halaman tanpa efek zoom yang membuat layar tampak mengecil.
class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
