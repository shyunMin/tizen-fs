import 'package:flutter/material.dart';

class AppTheme {
  static final AppColors colors = AppColors();
  static final AppDimens dimens = AppDimens();
  static final AppTextStyles textStyles = AppTextStyles();
}

class AppColors {
  /// Primary focus color, used for active/selected items and highlighted text.
  final Color focus = const Color(0xF04285F4);

  /// Secondary text color, used for subtitles and unselected text.
  final Color textSecondary = const Color(0xFF979AA0);

  /// Inactive icon color, used for unfocused icons or disabled states.
  final Color iconInactive = const Color(0xF0AEB2B9);

  /// Unfocused background color, often used in lists and cards when not focused.
  final Color unfocusedBackground = const Color(0xF0263041);
  
  /// Dark background color, used in popups or dark containers.
  final Color darkBackground = const Color(0xFF101010);
}

class AppDimens {
  /// Large outer padding for main app windows/pages that scales contextually.
  /// Typically EdgeInsets.fromLTRB(120, 60, 40, 0) or EdgeInsets.fromLTRB(80, 60, 80, 0)
  final EdgeInsets pagePaddingLarge = const EdgeInsets.fromLTRB(120, 60, 40, 0);
  final EdgeInsets pagePaddingNormal = const EdgeInsets.fromLTRB(80, 60, 80, 0);

  /// Horizontal padding for list items and inner containers.
  final double paddingHorizontalLarge = 80.0;
  final double paddingHorizontalNormal = 40.0;

  /// Padding for Popups
  final EdgeInsets popupPadding = const EdgeInsets.fromLTRB(80, 80, 0, 0);
  final EdgeInsets popupContentPadding = const EdgeInsets.fromLTRB(0, 100, 0, 0);

  /// Default Border Radius for list items and cards
  final BorderRadius borderRadiusNormal = BorderRadius.circular(10);
  
  /// Border Radius for popups and large elements
  final BorderRadius borderRadiusLarge = BorderRadius.circular(20);
  final BorderRadius borderRadiusXLarge = BorderRadius.circular(30);
  
  /// Small border radius for inputs or small buttons
  final BorderRadius borderRadiusSmall = BorderRadius.circular(8);
}

class AppTextStyles {
  /// Secondary text style (subtitles, descriptions)
  final TextStyle secondaryText = const TextStyle(
    fontSize: 11,
    color: Color(0xFF979AA0),
  );
}
