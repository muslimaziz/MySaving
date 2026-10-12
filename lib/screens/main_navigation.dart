import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/goal_data_notifier.dart';
import '../widgets/app_bottom_nav.dart';
import 'goals/goals_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String userName;
  final String? profileImage;

  const MainNavigationScreen({
    super.key,
    required this.userName,
    this.profileImage,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _dataRevision = 0;
  late String _userName;
  late String? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userName = widget.userName;
    _profileImage = widget.profileImage;
    _dataRevision = goalDataVersion.value;
    goalDataVersion.addListener(_onGoalDataChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    goalDataVersion.removeListener(_onGoalDataChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    // Muat ulang ringkasan setelah aplikasi kembali aktif, misalnya setelah
    // perangkat sempat terputus dari sesi debug atau berada di latar belakang.
    setState(() => _dataRevision++);
  }

  void _onGoalDataChanged() {
    if (!mounted) return;
    setState(() => _dataRevision = goalDataVersion.value);
  }

  void _updateProfile(String name, String? imagePath) {
    setState(() {
      _userName = name;
      _profileImage = imagePath;
    });
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeRebuilder(
      builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.bg,
          statusBarIconBrightness: AppColors.darkMode
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: AppColors.darkMode
              ? Brightness.dark
              : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                dataRevision: _dataRevision,
                userName: _userName,
                profileImage: _profileImage,
                onSeeAllTargets: _selectTab,
              ),
              GoalsScreen(dataRevision: _dataRevision),
              ProfileScreen(
                userName: _userName,
                profileImage: _profileImage,
                onProfileChanged: _updateProfile,
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: _currentIndex,
            onTap: _selectTab,
          ),
        ),
      ),
    );
  }
}
