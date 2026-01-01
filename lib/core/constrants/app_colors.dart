import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppColors {
  static const Color aquaTeal = Color(0xFF50C9C3);

  /// Soft mint – highlight / light tone
  static const Color mintLight = Color(0xFF96DEDA);
  static const Color light=Colors.white;
  static const Color black=Colors.black;
  static const Color greyAqua=Color.fromRGBO( 233, 246, 254,1);
}

class AppGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.aquaTeal, AppColors.mintLight],
  );
  static const LinearGradient softVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.mintLight, AppColors.aquaTeal],
  );
  static const LinearGradient focus = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.aquaTeal,
      Color(0xFF6FD6D1), // bridge color
    ],
  );
  static const LinearGradient darkBlend = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F7F7B), Color(0xFF1F5F5C)],
  );
}
