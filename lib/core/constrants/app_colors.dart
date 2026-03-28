import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppColors {
  static const Color aquaTeal = Color(0xFF50C9C3);
  static const Color mintLight = Color(0xFF96DEDA);
  static const Color light=Colors.white;
  static const Color black=Colors.black;
  static const Color greyAqua=Color.fromRGBO( 233, 246, 254,1);

  // Tailwind Gray Palette
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
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
      Color(0xFF6FD6D1),
    ],
  );
  static const LinearGradient darkBlend = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F7F7B), Color(0xFF1F5F5C)],
  );
}
