import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/saving_reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const MySavingApp());

  // Pengingat tidak perlu menahan aplikasi saat mulai. Jika plugin notifikasi
  // gagal diinisialisasi pada perangkat tertentu, aplikasi tetap bisa dibuka.
  try {
    await SavingReminderService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Gagal menginisialisasi pengingat menabung: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MySavingApp extends StatelessWidget {
  const MySavingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeController.instance;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => MaterialApp(
        title: 'MySaving',
        debugShowCheckedModeBanner: false,
        locale: const Locale('id', 'ID'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(dark: true),
        themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
