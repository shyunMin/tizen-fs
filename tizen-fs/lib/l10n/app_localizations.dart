import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @languageAndInput.
  ///
  /// In en, this message translates to:
  /// **'Language & Input'**
  String get languageAndInput;

  /// No description provided for @setLanguage.
  ///
  /// In en, this message translates to:
  /// **'Set Language'**
  String get setLanguage;

  /// No description provided for @setKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Set Keyboard'**
  String get setKeyboard;

  /// No description provided for @autofill.
  ///
  /// In en, this message translates to:
  /// **'Autofill'**
  String get autofill;

  /// No description provided for @voiceControl.
  ///
  /// In en, this message translates to:
  /// **'Voice Control'**
  String get voiceControl;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text To Speech'**
  String get textToSpeech;

  /// No description provided for @speechToText.
  ///
  /// In en, this message translates to:
  /// **'Speech To Text'**
  String get speechToText;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @pofileActive.
  ///
  /// In en, this message translates to:
  /// **'Profile Active'**
  String get pofileActive;

  /// No description provided for @pofileActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Tizen pofile is activated'**
  String get pofileActiveMessage;

  /// No description provided for @tizen.
  ///
  /// In en, this message translates to:
  /// **'Tizen'**
  String get tizen;

  /// No description provided for @aboutDevice.
  ///
  /// In en, this message translates to:
  /// **'About Device'**
  String get aboutDevice;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device info'**
  String get deviceInfo;

  /// No description provided for @networkStatus.
  ///
  /// In en, this message translates to:
  /// **'Network Status'**
  String get networkStatus;

  /// No description provided for @networkType.
  ///
  /// In en, this message translates to:
  /// **'Network Type'**
  String get networkType;

  /// No description provided for @ethernet.
  ///
  /// In en, this message translates to:
  /// **'Ethernet'**
  String get ethernet;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @subnetMask.
  ///
  /// In en, this message translates to:
  /// **'Subnet Mask'**
  String get subnetMask;

  /// No description provided for @gateway.
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get gateway;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @errorLoadingNetworkStatus.
  ///
  /// In en, this message translates to:
  /// **'Error loading network status.'**
  String get errorLoadingNetworkStatus;

  /// No description provided for @openSourceLicense.
  ///
  /// In en, this message translates to:
  /// **'Open source license'**
  String get openSourceLicense;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @fontType.
  ///
  /// In en, this message translates to:
  /// **'Font type'**
  String get fontType;

  /// No description provided for @screenTimeout.
  ///
  /// In en, this message translates to:
  /// **'Screen timeout'**
  String get screenTimeout;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @autoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Auto update'**
  String get autoUpdate;

  /// No description provided for @setDate.
  ///
  /// In en, this message translates to:
  /// **'Set Date'**
  String get setDate;

  /// No description provided for @setTime.
  ///
  /// In en, this message translates to:
  /// **'Set Time'**
  String get setTime;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeZone;

  /// No description provided for @hour24Clock.
  ///
  /// In en, this message translates to:
  /// **'24 hour clock'**
  String get hour24Clock;

  /// No description provided for @setTimezone.
  ///
  /// In en, this message translates to:
  /// **'Set Timezone'**
  String get setTimezone;

  /// No description provided for @noTimezonesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No timezones available'**
  String get noTimezonesAvailable;

  /// No description provided for @pleaseTurnOffAutoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Please turn off auto update'**
  String get pleaseTurnOffAutoUpdate;

  /// No description provided for @applying.
  ///
  /// In en, this message translates to:
  /// **'Applying...'**
  String get applying;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @yourApps.
  ///
  /// In en, this message translates to:
  /// **'Your Apps'**
  String get yourApps;

  /// No description provided for @selectEngine.
  ///
  /// In en, this message translates to:
  /// **'Select Engine'**
  String get selectEngine;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @autoLanguage.
  ///
  /// In en, this message translates to:
  /// **'Auto Language'**
  String get autoLanguage;

  /// No description provided for @selectVoice.
  ///
  /// In en, this message translates to:
  /// **'Select Voice'**
  String get selectVoice;

  /// No description provided for @autoVoice.
  ///
  /// In en, this message translates to:
  /// **'Auto Voice'**
  String get autoVoice;

  /// No description provided for @noEnginesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No engines available'**
  String get noEnginesAvailable;

  /// No description provided for @noLanguagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No languages available'**
  String get noLanguagesAvailable;

  /// No description provided for @noVoicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No voices available'**
  String get noVoicesAvailable;

  /// No description provided for @en_US.
  ///
  /// In en, this message translates to:
  /// **'English (United States)'**
  String get en_US;

  /// No description provided for @ko_KR.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get ko_KR;

  /// No description provided for @ja_JP.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get ja_JP;

  /// No description provided for @zh_CN.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get zh_CN;

  /// No description provided for @zh_TW.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional)'**
  String get zh_TW;

  /// No description provided for @fr_FR.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get fr_FR;

  /// No description provided for @de_DE.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get de_DE;

  /// No description provided for @es_ES.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get es_ES;

  /// No description provided for @it_IT.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get it_IT;

  /// No description provided for @pt_BR.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get pt_BR;

  /// No description provided for @ru_RU.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get ru_RU;

  /// No description provided for @ar_SA.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get ar_SA;

  /// No description provided for @hi_IN.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hi_IN;

  /// No description provided for @es_US.
  ///
  /// In en, this message translates to:
  /// **'Spanish (United States)'**
  String get es_US;

  /// No description provided for @en_GB.
  ///
  /// In en, this message translates to:
  /// **'English (United Kingdom)'**
  String get en_GB;

  /// No description provided for @zh_SG.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Singapore)'**
  String get zh_SG;

  /// No description provided for @zh_HK.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Hong Kong)'**
  String get zh_HK;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @notSupported.
  ///
  /// In en, this message translates to:
  /// **'Not Supported'**
  String get notSupported;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'There are no notifications.'**
  String get noNotifications;

  /// No description provided for @failedToEnableWifi.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable Wi-Fi'**
  String get failedToEnableWifi;

  /// No description provided for @activating.
  ///
  /// In en, this message translates to:
  /// **'Activating'**
  String get activating;

  /// No description provided for @deactivating.
  ///
  /// In en, this message translates to:
  /// **'Deactivating'**
  String get deactivating;

  /// No description provided for @paired.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get paired;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @disconnecting.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting'**
  String get disconnecting;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @associationFailed.
  ///
  /// In en, this message translates to:
  /// **'Association failed'**
  String get associationFailed;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @yourDeviceIsVisible.
  ///
  /// In en, this message translates to:
  /// **'Your device is currently visible to nearby devices.'**
  String get yourDeviceIsVisible;

  /// No description provided for @pairedDevices.
  ///
  /// In en, this message translates to:
  /// **'Paired Devices'**
  String get pairedDevices;

  /// No description provided for @availableDevices.
  ///
  /// In en, this message translates to:
  /// **'Available Devices'**
  String get availableDevices;

  /// No description provided for @timezone_region_Asia.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get timezone_region_Asia;

  /// No description provided for @timezone_region_America.
  ///
  /// In en, this message translates to:
  /// **'America'**
  String get timezone_region_America;

  /// No description provided for @timezone_region_Europe.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get timezone_region_Europe;

  /// No description provided for @timezone_region_Pacific.
  ///
  /// In en, this message translates to:
  /// **'Pacific'**
  String get timezone_region_Pacific;

  /// No description provided for @timezone_region_Australia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get timezone_region_Australia;

  /// No description provided for @timezone_city_Seoul.
  ///
  /// In en, this message translates to:
  /// **'Seoul'**
  String get timezone_city_Seoul;

  /// No description provided for @timezone_city_New_York.
  ///
  /// In en, this message translates to:
  /// **'New York'**
  String get timezone_city_New_York;

  /// No description provided for @timezone_city_Los_Angeles.
  ///
  /// In en, this message translates to:
  /// **'Los Angeles'**
  String get timezone_city_Los_Angeles;

  /// No description provided for @timezone_city_Chicago.
  ///
  /// In en, this message translates to:
  /// **'Chicago'**
  String get timezone_city_Chicago;

  /// No description provided for @timezone_city_London.
  ///
  /// In en, this message translates to:
  /// **'London'**
  String get timezone_city_London;

  /// No description provided for @timezone_city_Paris.
  ///
  /// In en, this message translates to:
  /// **'Paris'**
  String get timezone_city_Paris;

  /// No description provided for @timezone_city_Tokyo.
  ///
  /// In en, this message translates to:
  /// **'Tokyo'**
  String get timezone_city_Tokyo;

  /// No description provided for @timezone_city_Berlin.
  ///
  /// In en, this message translates to:
  /// **'Berlin'**
  String get timezone_city_Berlin;

  /// No description provided for @timezone_city_Hong_Kong.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong'**
  String get timezone_city_Hong_Kong;

  /// No description provided for @timezone_city_Shanghai.
  ///
  /// In en, this message translates to:
  /// **'Shanghai'**
  String get timezone_city_Shanghai;

  /// No description provided for @timezone_city_Singapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get timezone_city_Singapore;

  /// No description provided for @timezone_city_Sydney.
  ///
  /// In en, this message translates to:
  /// **'Sydney'**
  String get timezone_city_Sydney;

  /// No description provided for @timezone_city_Auckland.
  ///
  /// In en, this message translates to:
  /// **'Auckland'**
  String get timezone_city_Auckland;

  /// No description provided for @timezone_city_Toronto.
  ///
  /// In en, this message translates to:
  /// **'Toronto'**
  String get timezone_city_Toronto;

  /// No description provided for @timezone_city_Vancouver.
  ///
  /// In en, this message translates to:
  /// **'Vancouver'**
  String get timezone_city_Vancouver;

  /// No description provided for @timezone_city_Moscow.
  ///
  /// In en, this message translates to:
  /// **'Moscow'**
  String get timezone_city_Moscow;

  /// No description provided for @timezone_city_Dubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get timezone_city_Dubai;

  /// No description provided for @timezone_city_Mexico_City.
  ///
  /// In en, this message translates to:
  /// **'Mexico City'**
  String get timezone_city_Mexico_City;

  /// No description provided for @timezone_city_Sao_Paulo.
  ///
  /// In en, this message translates to:
  /// **'Sao Paulo'**
  String get timezone_city_Sao_Paulo;

  /// No description provided for @timezone_city_Kolkata.
  ///
  /// In en, this message translates to:
  /// **'Kolkata'**
  String get timezone_city_Kolkata;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @tizenVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get tizenVersion;

  /// No description provided for @cpu.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get cpu;

  /// No description provided for @ram.
  ///
  /// In en, this message translates to:
  /// **'RAM'**
  String get ram;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @buildId.
  ///
  /// In en, this message translates to:
  /// **'Build info'**
  String get buildId;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @errorLoadingDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading device information.'**
  String get errorLoadingDeviceInfo;

  /// No description provided for @noFileFound.
  ///
  /// In en, this message translates to:
  /// **'No file found'**
  String get noFileFound;

  /// No description provided for @connectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Connected Successfully'**
  String get connectedSuccessfully;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @disconnectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Disconnected Successfully'**
  String get disconnectedSuccessfully;

  /// No description provided for @disconnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Disconnection Failed'**
  String get disconnectionFailed;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @mediaVolume.
  ///
  /// In en, this message translates to:
  /// **'Media Volume'**
  String get mediaVolume;

  /// No description provided for @notificationVolume.
  ///
  /// In en, this message translates to:
  /// **'Notification Volume'**
  String get notificationVolume;

  /// No description provided for @systemVolume.
  ///
  /// In en, this message translates to:
  /// **'System Volume'**
  String get systemVolume;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get noTitle;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @recentFiles.
  ///
  /// In en, this message translates to:
  /// **'Recent files'**
  String get recentFiles;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @fileDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'File does not exist'**
  String get fileDoesNotExist;

  /// No description provided for @canNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Can not open the link'**
  String get canNotOpenFile;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @apps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps;

  /// No description provided for @installedApps.
  ///
  /// In en, this message translates to:
  /// **'Installed Apps'**
  String get installedApps;

  /// No description provided for @runningApps.
  ///
  /// In en, this message translates to:
  /// **'Running Apps'**
  String get runningApps;

  /// No description provided for @appDetail.
  ///
  /// In en, this message translates to:
  /// **'App Detail'**
  String get appDetail;

  /// No description provided for @allApps.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get allApps;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @uninstallMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to uninstall this app?'**
  String get uninstallMessage;

  /// No description provided for @forceStop.
  ///
  /// In en, this message translates to:
  /// **'Force Stop'**
  String get forceStop;

  /// No description provided for @forceStopMessage.
  ///
  /// In en, this message translates to:
  /// **'If you force stop an app, It may misbehave'**
  String get forceStopMessage;

  /// No description provided for @totalSize.
  ///
  /// In en, this message translates to:
  /// **'Total Size'**
  String get totalSize;

  /// No description provided for @appsize.
  ///
  /// In en, this message translates to:
  /// **'App Data'**
  String get appsize;

  /// No description provided for @userData.
  ///
  /// In en, this message translates to:
  /// **'User Data'**
  String get userData;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @clearCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to clear cache files of this app?'**
  String get clearCacheMessage;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @internalStorage.
  ///
  /// In en, this message translates to:
  /// **'Internal Storage'**
  String get internalStorage;

  /// No description provided for @externalStorage.
  ///
  /// In en, this message translates to:
  /// **'External Storage'**
  String get externalStorage;

  /// No description provided for @storageSetting.
  ///
  /// In en, this message translates to:
  /// **'Default Settings'**
  String get storageSetting;

  /// No description provided for @totalSpace.
  ///
  /// In en, this message translates to:
  /// **'Total Space'**
  String get totalSpace;

  /// No description provided for @availableSpace.
  ///
  /// In en, this message translates to:
  /// **'Available Space'**
  String get availableSpace;

  /// No description provided for @misc.
  ///
  /// In en, this message translates to:
  /// **'Misc.'**
  String get misc;

  /// No description provided for @sharedContent.
  ///
  /// In en, this message translates to:
  /// **'Shared Contents'**
  String get sharedContent;

  /// No description provided for @appInstallation.
  ///
  /// In en, this message translates to:
  /// **'App Installation'**
  String get appInstallation;

  /// No description provided for @sdCard.
  ///
  /// In en, this message translates to:
  /// **'SD Card'**
  String get sdCard;

  /// No description provided for @deviceStorage.
  ///
  /// In en, this message translates to:
  /// **'Device Storage'**
  String get deviceStorage;

  /// No description provided for @selectAppInstallLocation.
  ///
  /// In en, this message translates to:
  /// **'Select default location for installing apps'**
  String get selectAppInstallLocation;

  /// No description provided for @unmount.
  ///
  /// In en, this message translates to:
  /// **'SD Card Unmount'**
  String get unmount;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// No description provided for @noApp.
  ///
  /// In en, this message translates to:
  /// **'There are no installed apps'**
  String get noApp;

  /// No description provided for @languageChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChangedSuccessfully;

  /// No description provided for @languageChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change language'**
  String get languageChangeFailed;

  /// No description provided for @findHiddenNetwork.
  ///
  /// In en, this message translates to:
  /// **'Find Hidden Network'**
  String get findHiddenNetwork;

  /// No description provided for @enterNetworkName.
  ///
  /// In en, this message translates to:
  /// **'Enter network name'**
  String get enterNetworkName;

  /// No description provided for @networkSSID.
  ///
  /// In en, this message translates to:
  /// **'Network SSID'**
  String get networkSSID;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanning;

  /// No description provided for @wiFiMustBeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi must be enabled to search for hidden networks'**
  String get wiFiMustBeEnabled;

  /// No description provided for @wifiNetworkDetected.
  ///
  /// In en, this message translates to:
  /// **'A Wi-Fi network has been detected. You will be connected.'**
  String get wifiNetworkDetected;

  /// No description provided for @hiddenNetworkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Hidden network not found'**
  String get hiddenNetworkNotFound;

  /// No description provided for @hiddenNetworkNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The hidden network with the specified SSID could not be found. Please check the network name and try again.'**
  String get hiddenNetworkNotFoundMessage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @hiddenNetworkScanError.
  ///
  /// In en, this message translates to:
  /// **'Failed to scan for hidden network. Please try again.'**
  String get hiddenNetworkScanError;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @advancedWifiSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced WiFi settings'**
  String get advancedWifiSettings;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// No description provided for @forgetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Forget Successfully'**
  String get forgetSuccessfully;

  /// No description provided for @forgetFailed.
  ///
  /// In en, this message translates to:
  /// **'Forget Failed'**
  String get forgetFailed;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Search Successfully'**
  String get searchSuccessfully;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search Failed'**
  String get searchFailed;

  /// No description provided for @wepSecurity.
  ///
  /// In en, this message translates to:
  /// **'WEP Security'**
  String get wepSecurity;

  /// No description provided for @wpaSecurity.
  ///
  /// In en, this message translates to:
  /// **'WPA Security'**
  String get wpaSecurity;

  /// No description provided for @saeSecurity.
  ///
  /// In en, this message translates to:
  /// **'SAE Security'**
  String get saeSecurity;

  /// No description provided for @eapSecurity.
  ///
  /// In en, this message translates to:
  /// **'EAP Security'**
  String get eapSecurity;

  /// No description provided for @eapNotSupported.
  ///
  /// In en, this message translates to:
  /// **'EAP security is not supported.'**
  String get eapNotSupported;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @anonymousIdentity.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Identity'**
  String get anonymousIdentity;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @loadingChannel.
  ///
  /// In en, this message translates to:
  /// **'Loading channel'**
  String get loadingChannel;

  /// No description provided for @unableToLoadChannel.
  ///
  /// In en, this message translates to:
  /// **'Unable to load channel'**
  String get unableToLoadChannel;

  /// No description provided for @networkUnstable.
  ///
  /// In en, this message translates to:
  /// **'Network connection is unstable'**
  String get networkUnstable;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying'**
  String get retrying;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @livestream.
  ///
  /// In en, this message translates to:
  /// **'Live Stream'**
  String get livestream;

  /// No description provided for @addChannel.
  ///
  /// In en, this message translates to:
  /// **'Add Channel'**
  String get addChannel;

  /// No description provided for @currentChannel.
  ///
  /// In en, this message translates to:
  /// **'Current Channel'**
  String get currentChannel;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @noRecommendedChannels.
  ///
  /// In en, this message translates to:
  /// **'No Recommended Channels'**
  String get noRecommendedChannels;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @volumeChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The volume has been changed'**
  String get volumeChangedSuccessfully;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @appListChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The app list has been changed'**
  String get appListChangedSuccessfully;

  /// No description provided for @additionalFeatures.
  ///
  /// In en, this message translates to:
  /// **'Additional Features'**
  String get additionalFeatures;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get ai;

  /// No description provided for @aiChatConfiguration.
  ///
  /// In en, this message translates to:
  /// **'AI Chat Configuration'**
  String get aiChatConfiguration;

  /// No description provided for @aiEnable.
  ///
  /// In en, this message translates to:
  /// **'AI Chat Enable'**
  String get aiEnable;

  /// No description provided for @aiEnableMessage.
  ///
  /// In en, this message translates to:
  /// **'To enable AI chat feature, config file is required'**
  String get aiEnableMessage;

  /// No description provided for @failedToWifiOn.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn on Wi-Fi'**
  String get failedToWifiOn;

  /// No description provided for @failedToWifiOff.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn off Wi-Fi'**
  String get failedToWifiOff;

  /// No description provided for @failedToBtOn.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn on Bluetooth'**
  String get failedToBtOn;

  /// No description provided for @failedToBtOff.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn off Bluetooth'**
  String get failedToBtOff;

  /// No description provided for @aiConfiguration.
  ///
  /// In en, this message translates to:
  /// **'AI Configuration'**
  String get aiConfiguration;

  /// No description provided for @clientKey.
  ///
  /// In en, this message translates to:
  /// **'Client Key'**
  String get clientKey;

  /// No description provided for @passKey.
  ///
  /// In en, this message translates to:
  /// **'Pass Key'**
  String get passKey;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @endpointUrl.
  ///
  /// In en, this message translates to:
  /// **'Endpoint URL'**
  String get endpointUrl;

  /// No description provided for @configFilePath.
  ///
  /// In en, this message translates to:
  /// **'Config File Path'**
  String get configFilePath;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @enterDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Enter device name'**
  String get enterDeviceName;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename Device'**
  String get renameDevice;

  /// No description provided for @deviceNameChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Device name changed successfully'**
  String get deviceNameChangedSuccessfully;

  /// No description provided for @featureStateChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Feature state changed successfully'**
  String get featureStateChangedSuccessfully;

  /// No description provided for @dns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get dns;
<<<<<<< HEAD

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
=======
>>>>>>> bdf1ca1 (Resolve issue 6: Add wired network connection menu)
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
