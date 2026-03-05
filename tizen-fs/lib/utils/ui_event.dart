enum PanelType { notification, account }

enum WidgetType {
  wifi,
  wifiList,
  wifiFind,
  bluetooth,
  bluetoothList,
  bluetoothFind,
  volume,
  live,
}

sealed class UiEvent {}

class ShowToastMessageEvent extends UiEvent {
  final String message;
  ShowToastMessageEvent(this.message);
}

class ShowDialogEvent extends UiEvent {
  final PanelType type;
  ShowDialogEvent(this.type);
}

class ShowMessageEvent extends UiEvent {
  final String message;
  ShowMessageEvent(this.message);
}

class ShowWidgetEvent extends UiEvent {
  final WidgetType widgetType;
  final String? param;
  ShowWidgetEvent(this.widgetType, this.param);
}
