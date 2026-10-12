import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

/// Bottom navigation 3 tab ala desain:
/// Beranda, Target, Profil — dengan indikator kuning di tab aktif.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    (icon: AppIcons.home, label: 'Beranda'),
    (icon: AppIcons.target, label: 'Target'),
    (icon: AppIcons.profile, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: bottomInset > 0 ? bottomInset : 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final active = index == currentIndex;
          return SizedBox(
            width: 64,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indikator kuning di atas tab aktif
                      Container(
                        height: 4,
                        width: 32,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(999),
                          ),
                        ),
                      ),
                      _tabIcon(index, active, tab.icon),
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.primary : const Color(0xFF9AA39F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _tabIcon(int index, bool active, String asset) {
    final inactiveColor = AppColors.darkMode
        ? const Color(0xFF9AA9A0)
        : const Color(0xFF9AA39F);
    final selectedColor = AppColors.darkMode ? Colors.white : Colors.black;

    if (index == 0 || index == 2) {
      final icon = index == 0
          ? (active ? Icons.home_rounded : Icons.home_outlined)
          : (active ? Icons.person_rounded : Icons.person_outline_rounded);
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: Icon(
          icon,
          key: ValueKey(icon),
          size: 23,
          color: active ? selectedColor : inactiveColor,
        ),
      );
    }

    return AppIcons.fromAsset(
      asset,
      size: 22,
      color: active ? AppColors.primary : inactiveColor,
    );
  }
}
