import 'package:flutter/material.dart';

/// إيثار — Design tokens (from README handoff)
class AppColors {
  // Core brand
  static const Color primary = Color(0xFFDE5436); // CTAs, active, chips, AI badge
  static const Color primaryDark = Color(0xFFA73B3F); // gradient end
  static const Color orange = Color(0xFFF28724); // logo accent
  static const Color brandTeal = Color(0xFF23424C); // logo bg / dark
  static const Color wordmarkTeal = Color(0xFF4F8F9A); // wordmark on welcome

  // Tints & ink
  static const Color tintSoft = Color(0x1ADE5436); // rgba(222,84,54,0.10)
  static const Color ink = Color(0xFF1D3A44); // primary text
  static const Color ink2 = Color(0xFF5C6F76); // secondary text

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF6F7F7);
  static const Color border = Color(0xFFECEFF0);
  static const Color borderInput = Color(0xFFDFE4E6);
  static const Color disabled = Color(0xFFCDD4D7);
  static const Color placeholder = Color(0xFFA9B3B7);
  static const Color tabInactive = Color(0xFF8A979C);

  // Status
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color pendingFg = Color(0xFF92400E);
  static const Color acceptedBg = Color(0xFFD1FAE5);
  static const Color acceptedFg = Color(0xFF065F46);
  static const Color acceptedSolid = Color(0xFF059669);
  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color rejectedFg = Color(0xFF991B1B);
  static const Color rejectedSolid = Color(0xFFE11D48);
  static const Color notifNew = Color(0xFF0891B2);
}

/// NGO logo tile palette — cycles oklch(0.72 0.12 X)
class NgoColors {
  static const List<Color> palette = [
    Color(0xFFD98A6B), // ~ hue 30
    Color(0xFF6FB59A), // ~ hue 160
    Color(0xFF6BA0C4), // ~ hue 220
    Color(0xFFC47BA8), // ~ hue 340
    Color(0xFFC4B96B), // ~ hue 90
  ];
  static Color at(int i) => palette[i % palette.length];
}

class AppRadius {
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r18 = 18;
  static const double r20 = 20;
  static const double r22 = 22;
  static const double r24 = 24;
  static const double r28 = 28;
  static const double pill = 100;
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> primaryCta = [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> hero = [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12)),
  ];
  static const List<BoxShadow> logo = [
    BoxShadow(color: Color(0x471D3A44), blurRadius: 44, offset: Offset(0, 20)),
  ];
  static const List<BoxShadow> stat = [
    BoxShadow(color: Color(0x0F1F1730), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

const String kFontFamily = 'IBMPlexSansArabic';

class AppText {
  // H1 32/800/1.2
  static const TextStyle h1 = TextStyle(
    fontFamily: kFontFamily, fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, color: AppColors.ink,
  );
  // Screen title 22/800
  static const TextStyle screenTitle = TextStyle(
    fontFamily: kFontFamily, fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink,
  );
  // Top bar 17/700
  static const TextStyle topBar = TextStyle(
    fontFamily: kFontFamily, fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink,
  );
  // Body 16/400/1.6
  static const TextStyle body = TextStyle(
    fontFamily: kFontFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: AppColors.ink2,
  );
  // Chat 15/400/1.6
  static const TextStyle chat = TextStyle(
    fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.w400, height: 1.6, color: AppColors.ink,
  );
  static const TextStyle buttonBig = TextStyle(
    fontFamily: kFontFamily, fontSize: 17, fontWeight: FontWeight.w700,
  );
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: kFontFamily, fontSize: 14, fontWeight: FontWeight.w700,
  );
  // Chip 13/600
  static const TextStyle chip = TextStyle(
    fontFamily: kFontFamily, fontSize: 13, fontWeight: FontWeight.w600,
  );
  static const TextStyle meta = TextStyle(
    fontFamily: kFontFamily, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.ink2,
  );
  static const TextStyle tabLabel = TextStyle(
    fontFamily: kFontFamily, fontSize: 11, fontWeight: FontWeight.w700,
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: kFontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: kFontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: AppText.topBar,
      ),
      splashColor: AppColors.tintSoft,
      highlightColor: Colors.transparent,
    );
  }
}
