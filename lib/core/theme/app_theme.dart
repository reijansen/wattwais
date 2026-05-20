import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const ink = Color(0xFF020910);
  static const midnight = Color(0xFF080D36);
  static const panel = Color(0xFF111826);
  static const navyPanel = Color(0xFF20264B);
  static const border = Color(0xFF536C91);
  static const mutedBorder = Color(0xFF27313B);
  static const blue = Color(0xFF149BEE);
  static const blueDark = Color(0xFF0C6EB8);
  static const cyan = Color(0xFF2BC6FF);
  static const text = Color(0xFFF2F6FF);
  static const muted = Color(0xFFA7B1BF);
  static const dim = Color(0xFF74829B);
  static const danger = Color(0xFFFF4A50);
}

class AppSpacing {
  const AppSpacing._();

  static const page = 22.0;
  static const cardRadius = 22.0;
  static const pillRadius = 999.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.ink,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue,
      secondary: AppColors.cyan,
      surface: AppColors.panel,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'Helvetica Neue',
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

extension TextStyles on BuildContext {
  TextStyle get titleLarge => const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: 0,
  );

  TextStyle get sectionLabel => const TextStyle(
    color: AppColors.muted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
  );
}
