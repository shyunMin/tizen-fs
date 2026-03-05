import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:flutter/material.dart';

class LocaleUtils {
  static String getTimezoneDisplayName(
    BuildContext context,
    String timezoneId,
  ) {
    final parts = timezoneId.split('/');
    if (parts.length != 2) {
      return timezoneId;
    }

    final region = parts[0];
    final city = parts[1];

    String regionName = getLocalizedTextByKey(
      context,
      'timezone_region_$region',
    );
    String cityName = getLocalizedTextByKey(context, 'timezone_city_$city');

    return '$cityName, $regionName';
  }
}
