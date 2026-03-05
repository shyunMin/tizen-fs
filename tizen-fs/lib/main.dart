import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/action_model.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/models/immersive_carosel_model.dart';
import 'package:tizen_fs/models/storage_model.dart';
import 'package:tizen_fs/ai/ai_config_provider.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/ai/ai_provider.dart';
import 'package:tizen_fs/providers/backdrop_provider.dart';
import 'package:tizen_fs/providers/media_data_provider.dart';
import 'package:tizen_fs/providers/setting_menu_provider.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';
import 'package:tizen_fs/providers/video_control_provider.dart';
import 'package:tizen_fs/providers/volume_provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/providers/locale_provider.dart';
import 'package:tizen_fs/providers/network_status_provider.dart';
import 'package:tizen_fs/providers/tts_setting_provider.dart';
import 'package:tizen_fs/providers/stt_setting_provider.dart';
import 'package:tizen_fs/providers/notification_provider.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/router.dart';
import 'package:tizen_fs/router_service.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_interop/9.0/tizen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setupAppModel();
  setupSettingProvider();
  setupDeviceInfoProvider();
  setupAdditionalFeatureProvider();

  // warm-up for tizen_interop(loading native symbols)
  debugPrint(tizen.get_error_message(0).toDartString());

  PaintingBinding.instance.imageCache.maximumSizeBytes = 35 * 1024 * 1024;

  RouterService.instance.setRouter(AppRouter.router);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppDataModel>(
          create: (context) => getIt<AppDataModel>(),
        ),
        ChangeNotifierProvider<StorageDataModel>(
          create: (context) => getIt<StorageDataModel>(),
        ),
        ChangeNotifierProvider<BtModel>(create: (context) => getIt<BtModel>()),
        ChangeNotifierProvider<WifiProvider>(
          create: (context) => getIt<WifiProvider>(),
        ),
        ChangeNotifierProvider<DeviceInfoProvider>(
          create: (context) => DeviceInfoProvider(),
        ),
        ChangeNotifierProvider<NetworkStatusProvider>(
          create: (context) => getIt<NetworkStatusProvider>(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (context) => getIt<LocaleProvider>(),
        ),
        ChangeNotifierProvider<TtsSettingProvider>(
          create: (context) => getIt<TtsSettingProvider>(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(),
        ),
        ChangeNotifierProvider<SttSettingProvider>(
          create: (context) => getIt<SttSettingProvider>(),
        ),
        ChangeNotifierProvider<VideoControllerProvider>(
          create: (context) => getIt<VideoControllerProvider>(),
        ),
        ChangeNotifierProvider<TabBarProvider>(
          create: (context) => getIt<TabBarProvider>(),
        ),
        ChangeNotifierProvider<BackdropProvider>(
          create: (context) => BackdropProvider(),
        ),
        ChangeNotifierProvider<ImmersiveCarouselModel>(
          create: (context) => ImmersiveCarouselModel.fromMock(),
        ),
        ChangeNotifierProvider<RecentFileProvider>(
          create: (context) => RecentFileProvider(),
        ),
        ChangeNotifierProvider<SettingMenuProvider>(
          create: (context) => getIt<SettingMenuProvider>(),
        ),
        ChangeNotifierProvider<ActionModel>(create: (context) => ActionModel()),
        ChangeNotifierProvider<AIConfigProvider>(
          create: (context) => AIConfigProvider(),
        ),
        ChangeNotifierProvider<AIProvider>(
          create: (context) => getIt<AIProvider>(),
        ),
        ChangeNotifierProvider<AdditaionalFeatureProvider>(
          create: (context) => getIt<AdditaionalFeatureProvider>(),
        ),
        ChangeNotifierProvider<VolumeProvider>(
          create: (context) => VolumeProvider(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.altLeft) {
        RouterService.instance.safePush(ScreenPaths.action);
        return true;
      }
    }
    return false;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if ((event.logicalKey == LogicalKeyboardKey.backspace) ||
              (event.physicalKey == PhysicalKeyboardKey.escape)) {
            RouterService.instance.safePop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MaterialApp.router(
        title: 'Tizen First Screen',
        themeMode: ThemeMode.dark,
        theme: $style.colors.toLightThemeData(),
        darkTheme: $style.colors.toDarkThemeData(),
        routerConfig: AppRouter.router,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en'), const Locale('ko')],
        locale: localeProvider.currentLocale,
      ),
    );
  }
}
