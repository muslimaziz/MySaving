import 'package:flutter/material.dart';

class AppIcons {
  static Widget fromAsset(String iconName, {double size = 24, Color? color}) {
    return Image.asset(
      'assets/icons/$iconName',
      width: size,
      height: size,
      color: color, 
      fit: BoxFit.contain,
    );
  }

  // 14 Nama file ikon UI (asli)
  static const String home = 'ic_home.png';
  static const String target = 'ic_target.png';
  static const String profile = 'ic_profile.png';
  static const String add = 'ic_add.png';
  static const String edit = 'ic_edit.png';
  static const String delete = 'ic_delete.png';
  static const String more = 'ic_more.png';
  static const String calendar = 'ic_calendar.png';
  static const String moneyIn = 'ic_money_in.png';
  static const String wallet = 'ic_wallet.png';
  static const String storage = 'ic_storage.png';
  static const String info = 'ic_info.png';

  // 7 Ikon baru untuk desain (generated: lihat tools/generate_icons.dart)
  static const String arrow = 'ic_arrow.png'; // chevron-left (kembali)
  static const String chevron = 'ic_chevron.png'; // chevron-right
  static const String trend = 'ic_trend.png'; // trending-up
  static const String check = 'ic_check.png'; // check
  static const String image = 'ic_image.png'; // image
  static const String bell = 'ic_bell.png'; // bell
  static const String moon = 'ic_moon.png'; // moon
}
