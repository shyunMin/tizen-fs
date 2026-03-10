enum IconSourceType { none, uri, color, icon }

abstract class ItemDisplayInterface {
  String get displayText;
  String? get displaySubText;

  Object? get iconSourceData;
  IconSourceType get iconSourceType;

  /// Determines if the item can receive focus and be selected
  bool get isSelectable => true;
}
