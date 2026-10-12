import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imagePath;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final initial = trimmedName.isEmpty
        ? '?'
        : trimmedName.substring(0, 1).toUpperCase();
    final fallback = Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          color: AppColors.avatarText,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.avatarAmber,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: imagePath == null || imagePath!.isEmpty
            ? KeyedSubtree(key: ValueKey('initial:$initial'), child: fallback)
            : Image.file(
                File(imagePath!),
                key: ValueKey(imagePath),
                width: size,
                height: size,
                cacheWidth: (size * 3).round(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
