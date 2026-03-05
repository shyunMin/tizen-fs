import 'package:flutter/material.dart';

AppStyle get $style => AppStyle.instance;

class AppStyle {
  static final AppStyle _instance = AppStyle();
  static AppStyle get instance => _instance;

  final AppColors colors = AppColors();
  final StorageColors storageColors = StorageColors();

  /// Animation Durations
  final _Times times = _Times();

  final LinearGradientColors gradients = LinearGradientColors();
}

class StorageColors {
  final Color apps = Color(0xFFdea23b);
  final Color images = Color(0xFFdb567c);
  final Color videos = Color(0xFF8355db);
  final Color audio = Color(0xFF64b8e8);
  final Color misc = Color(0xFF29d256);
  final Color cache = Color(0xFF235dcc);
}

class LinearGradientColors {
  final Map<int, List<Color>> _colorMap = {
    0: [Color(0xFF235dcc), Color(0xFF22c6b3)],
    1: [Color(0xFFdb567c), Color(0xFF8355db)],
    2: [Color(0xFF64b8e8), Color(0xFF636be8)],
    3: [Color(0xFFdea23b), Color(0xFFde413f)],
    4: [Color(0xFF29d256), Color(0xFFdea23b)],
  };

  LinearGradient getGradient(int num) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _colorMap[num]!,
    );
  }

  LinearGradient generateLinearGradient(Color start, Color end) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        start.withAlphaF(0.6),
        start.withAlphaF(0.5),
        start.withAlphaF(0.4),
        start.withAlphaF(0.3),
        start.withAlphaF(0.2),
        end.withAlphaF(0.2),
        end.withAlphaF(0.3),
        end.withAlphaF(0.4),
        end.withAlphaF(0.5),
        end.withAlphaF(0.6),
      ],
      stops: [0.0, 0.05, 0.1, 0.15, 0.2, 0.5, 0.7, 0.8, 0.9, 1.0],
    );
  }
}

class AppColors {
  final Color primary = Color(0xFF1A1C1E);
  final Color onPrimary = Color.fromARGB(255, 188, 192, 202);
  final Color primaryContainer = Color(0xFF00468A);
  final Color onPrimaryContainer = Color(0xFFD6E3FF);

  final Color secondary = Color(0xFFBDC7DC);
  final Color onSecondary = Color(0xFF273141);
  final Color secondaryContainer = Color(0xFF3E4758);
  final Color onSecondaryContainer = Color(0xFFD9E3F8);

  final Color tertiary = Color(0xFFDCBCE1);
  final Color onTertiary = Color(0xFF3E2845);
  final Color tertiaryContainer = Color(0xFF563E5C);
  final Color onTertiaryContainer = Color(0xFFF9D8FE);

  final Color surface = Color(0xFF1A1C1E);
  final Color onSurface = Color(0xFFE3E2E6);
  final Color surfaceVariant = Color(0xFF43474E);
  final Color onSurfaceVariant = Color(0xFFC4C6CF);

  final Color error = Color(0xFFFFB4AB);
  final Color onError = Color(0xFF690005);
  final Color errorContainer = Color(0xFF93000A);
  final Color onErrorContainer = Color(0xFFFFB4AB);

  final Color border = Color(0xFF8E9099);

  // colors from https://samsungtizenos.com/about/brand-guide/
  final Color sblue = const Color(0xFF0F42CF);
  final Color tblue = const Color(0xFF00c9ff);
  final Color rblue = const Color(0xFF002366);

  final Color dotnetApp = const Color(0xFF008AEE);
  final Color cApp = const Color(0xFF3aa1d9);
  final Color webApp = const Color(0xFF3a3a3a);
  final Color defaulApp = const Color(0xFF3aa1d9);

  ThemeData toLightThemeData() {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: sblue,
      primary: sblue,
      secondary: tblue,
      brightness: Brightness.light,
    );

    var t = ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    ).copyWith(
      textSelectionTheme: TextSelectionThemeData(cursorColor: sblue),
      highlightColor: sblue,
    );

    return t;
  }

  ThemeData toDarkThemeData() {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: sblue,
      secondary: tblue,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    );

    var t = ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    ).copyWith(
      textSelectionTheme: TextSelectionThemeData(cursorColor: sblue),
      highlightColor: sblue,
    );

    return t;
  }

  // ThemeData toDarkThemeData() {
  //   /// Create a TextTheme and ColorScheme, that we can use to generate ThemeData
  //   TextTheme txtTheme = ThemeData.dark().textTheme;
  //   ColorScheme colorScheme = ColorScheme(
  //       // Map our custom theme to the Material ColorScheme
  //       brightness: Brightness.dark,
  //       primary: primary,
  //       onPrimary: onPrimary,
  //       primaryContainer: primaryContainer,
  //       onPrimaryContainer: onPrimaryContainer,

  //       secondary: secondary,
  //       onSecondary: onSecondary,
  //       secondaryContainer: secondaryContainer,
  //       onSecondaryContainer: onSecondaryContainer,

  //       tertiary: tertiary,
  //       onTertiary: onTertiary,
  //       tertiaryContainer: tertiaryContainer,
  //       onTertiaryContainer: onTertiaryContainer,

  //       surface: surface,
  //       onSurface: onSurface,
  //       surfaceContainerHighest: surfaceVariant,
  //       onSurfaceVariant: onSurfaceVariant,

  //       error: error,
  //       onError: onError,
  //       errorContainer: errorContainer,
  //       onErrorContainer: onErrorContainer,
  //       outline: border,
  //   );

  //   var t = ThemeData.from(textTheme: txtTheme, colorScheme: colorScheme, useMaterial3: true).copyWith(
  //     textSelectionTheme: TextSelectionThemeData(cursorColor: primary),
  //     highlightColor: primary,
  //   );

  //   /// Return the themeData which MaterialApp can now use
  //   return t;
  // }
}

extension ColorConversion on Color {
  Color withAlphaF(double alpha) {
    return withValues(alpha: alpha);
  }
}

@immutable
class _Times {
  final Duration fast = Duration(milliseconds: 100);
  final Duration med = Duration(milliseconds: 300);
  final Duration slow = Duration(milliseconds: 500);
  final Duration pageTransition = Duration(milliseconds: 200);
}
