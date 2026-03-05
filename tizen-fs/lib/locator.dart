import 'package:get_it/get_it.dart';
import 'package:tizen_fs/ai/gauss_service.dart';
import 'package:tizen_fs/ai/gemini_service.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/models/storage_model.dart';
import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/native/date_time_manager.dart';
import 'package:tizen_fs/native/language_input_manager.dart';
import 'package:tizen_fs/native/notification_manager.dart';
import 'package:tizen_fs/native/stt_setting_manager.dart';
import 'package:tizen_fs/native/tts_setting_manager.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/ai/ai_provider.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/providers/locale_provider.dart';
import 'package:tizen_fs/providers/network_status_provider.dart';
import 'package:tizen_fs/providers/notification_provider.dart';
import 'package:tizen_fs/providers/setting_menu_provider.dart';
import 'package:tizen_fs/providers/stt_setting_provider.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';
import 'package:tizen_fs/providers/tts_setting_provider.dart';
import 'package:tizen_fs/providers/video_control_provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';

final getIt = GetIt.instance;

void setupAppModel() {
  if (!getIt.isRegistered<AppDataModel>()) {
    getIt.registerLazySingleton<AppDataModel>(() => AppDataModel());
  }
}

void setupSettingProvider() {
  if (!getIt.isRegistered<DateTimeManager>()) {
    getIt.registerLazySingleton<DateTimeManager>(() => DateTimeManager());
  }
  if (!getIt.isRegistered<LanguageInputManager>()) {
    getIt.registerLazySingleton<LanguageInputManager>(
      () => LanguageInputManager(),
    );
  }
  if (!getIt.isRegistered<LocaleProvider>()) {
    getIt.registerLazySingleton<LocaleProvider>(() => LocaleProvider());
  }
  if (!getIt.isRegistered<TtsSettingManager>()) {
    getIt.registerLazySingleton<TtsSettingManager>(() => TtsSettingManager());
  }
  if (!getIt.isRegistered<TtsSettingProvider>()) {
    getIt.registerLazySingleton<TtsSettingProvider>(() => TtsSettingProvider());
  }
  if (!getIt.isRegistered<SttSettingManager>()) {
    getIt.registerLazySingleton<SttSettingManager>(() => SttSettingManager());
  }
  if (!getIt.isRegistered<SttSettingProvider>()) {
    getIt.registerLazySingleton<SttSettingProvider>(() => SttSettingProvider());
  }
  if (!getIt.isRegistered<WifiProvider>()) {
    getIt.registerLazySingleton<WifiProvider>(() => WifiProvider());
  }
  if (!getIt.isRegistered<BtModel>()) {
    getIt.registerLazySingleton<BtModel>(() => BtModel.init());
  }
  if (!getIt.isRegistered<StorageDataModel>()) {
    getIt.registerLazySingleton<StorageDataModel>(() => StorageDataModel());
  }
  if (!getIt.isRegistered<NotificationManager>()) {
    getIt.registerLazySingleton<NotificationManager>(
      () => NotificationManager(),
    );
  }
  if (!getIt.isRegistered<NotificationProvider>()) {
    getIt.registerLazySingleton<NotificationProvider>(
      () => NotificationProvider(),
    );
  }
  if (!getIt.isRegistered<SettingMenuProvider>()) {
    getIt.registerLazySingleton<SettingMenuProvider>(
      () => SettingMenuProvider(),
    );
  }
  if (!getIt.isRegistered<NetworkStatusProvider>()) {
    getIt.registerLazySingleton<NetworkStatusProvider>(
      () => NetworkStatusProvider(),
    );
  }
}

void setupVideoController() {
  if (!getIt.isRegistered<VideoControllerProvider>()) {
    getIt.registerLazySingleton<VideoControllerProvider>(
      () => VideoControllerProvider(),
    );
  }
}

void setupDeviceInfoProvider() {
  if (!getIt.isRegistered<DeviceInfoProvider>()) {
    getIt.registerLazySingleton<DeviceInfoProvider>(() => DeviceInfoProvider());
  }
}

void setupAdditionalFeatureProvider() {
  if (!getIt.isRegistered<TabBarProvider>()) {
    getIt.registerLazySingleton<TabBarProvider>(() => TabBarProvider());
  }
  if (!getIt.isRegistered<AIProvider>()) {
    getIt.registerLazySingleton<AIProvider>(() => AIProvider(GaussService()));
  }
  if (!getIt.isRegistered<AdditaionalFeatureProvider>()) {
    getIt.registerLazySingleton<AdditaionalFeatureProvider>(
      () => AdditaionalFeatureProvider(
        getIt<TabBarProvider>(),
        getIt<AIProvider>(),
      ),
    );
  }
}
