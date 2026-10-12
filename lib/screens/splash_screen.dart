import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'name_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _continueAfterSplash();
  }

  Future<void> _continueAfterSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final darkMode = await DatabaseHelper.instance.readSetting('dark_mode') == 'true';
    AppThemeController.instance.setDarkMode(darkMode);
    final userName = await DatabaseHelper.instance.readUserName();
    final profileImage = await DatabaseHelper.instance.readProfileImage();
    if (!mounted) return;
    final nextScreen = userName == null
        ? const NameSetupScreen()
        : MainNavigationScreen(userName: userName, profileImage: profileImage);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_white.png',
                      width: 112,
                      height: 112,
                      fit: BoxFit.contain,
                      semanticLabel: 'Logo MySaving',
                    ),
                    const SizedBox(height: 18),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'MySaving',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sedikit demi sedikit, jadi nyata.',
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LoadingDot(delay: 0),
                  SizedBox(width: 7),
                  _LoadingDot(delay: 150),
                  SizedBox(width: 7),
                  _LoadingDot(delay: 300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDot extends StatefulWidget {
  final int delay;

  const _LoadingDot({required this.delay});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
        child: Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.lime, shape: BoxShape.circle)),
      );
}
