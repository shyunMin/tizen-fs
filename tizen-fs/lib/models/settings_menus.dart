import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/native/language_input_manager.dart';
import 'package:tizen_fs/settings/additional_feature_ai.dart';
import 'package:tizen_fs/settings/apps_detail_page.dart';
import 'package:tizen_fs/settings/apps_page.dart';
import 'package:tizen_fs/settings/bluetooth_page.dart';
import 'package:tizen_fs/settings/date_time_page.dart';
import 'package:tizen_fs/settings/device_info_page.dart';
import 'package:tizen_fs/settings/end_page.dart';
import 'package:tizen_fs/settings/addtional_features_page.dart';
import 'package:tizen_fs/settings/profile_active_page.dart';
import 'package:tizen_fs/settings/set_date_page.dart';
import 'package:tizen_fs/settings/set_language_page.dart';
import 'package:tizen_fs/settings/set_stt_engine_page.dart';
import 'package:tizen_fs/settings/set_stt_language_page.dart';
import 'package:tizen_fs/settings/set_time_page.dart';
import 'package:tizen_fs/settings/set_timezone_page.dart';
import 'package:tizen_fs/settings/set_tts_engine_page.dart';
import 'package:tizen_fs/settings/set_tts_voice_page.dart';
import 'package:tizen_fs/settings/storage_detail_page.dart';
import 'package:tizen_fs/settings/volume_detail_page.dart';
import 'package:tizen_fs/settings/volume_setting_page.dart';
import 'package:tizen_fs/settings/storage_setting_page.dart';
import 'package:tizen_fs/settings/wifi_page.dart';
import 'package:tizen_fs/settings/wifi_advanced_page.dart';
import 'package:tizen_fs/settings/about_device_page.dart';
import 'package:tizen_fs/settings/network_status_page.dart';

class SettingPages {
  late final PageNode _root;

  SettingPages() {
    _root = _buildPageTree();
    _root.uri = '/${_root.id}';

    _seturi(_root);
  }

  void _seturi(PageNode node) {
    final p = node;

    int i = 0;
    while (i < p.children.length) {
      final child = p.children[i];
      child.uri = '${p.uri}/${child.id}';
      _seturi(child);
      i++;
    }
  }

  PageNode getRoot() => _root;
  PageNode _buildPageTree() {
    PageNode settings = PageNode(
      id: 'settings',
      title: 'settings',
      children: [],
    );

    settings.children.add(
      PageNode(
        id: 'profile',
        icon: Icons.person_outlined,
        title: 'profile',
        children: [
          PageNode(
            id: 'profile_tizen',
            title: 'tizen',
            icon: const IconData(0x0054), //unicode T: 0054
            isEnd: true,
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => ProfileActivePage(node: node, isEnabled: isEnabled),
          ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'about_device',
        icon: Icons.info_outline,
        title: 'aboutDevice',
        builder:
            (
              context,
              node,
              isEnabled,
              onRequestPageUpdate,
              onRequestPageMove,
              onRequestGoBack,
            ) => AboutDevicePage(
              node: node,
              isEnabled: isEnabled,
              onFocusChanged: onRequestPageUpdate,
              onSelectionChanged: onRequestPageMove,
            ),
        children: [
          PageNode(
            id: 'about_device_device_info',
            title: 'deviceInfo',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => DeviceInfoPage(
                  node: node,
                  isEnabled: isEnabled,
                  onFocusChanged: onRequestPageUpdate,
                  onSelectionChanged: onRequestPageMove,
                ),
          ),
          PageNode(
            id: 'about_device_connection_info',
            title: 'networkStatus',
            isEnd: true,
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => NetworkStatusPage(node: node, isEnabled: isEnabled),
          ),
          PageNode(
            id: 'about_device_opensource_license',
            title: 'openSourceLicense',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => EndPage(),
            isEnd: true,
          ),
          // PageNode(
          //   id: 'about_device_certificates',
          //   title: 'Manage certificates',
          //   children: [
          //     PageNode(
          //       id: 'about_device_certificates_AAA',
          //       title: 'AAA certificates',
          //       builder:
          //           (context, node, isEnabled, onItemSelected) => EndPage(),
          //     ),
          //     PageNode(
          //       id: 'about_device_certificates_ANF',
          //       title: 'ANF certificates',
          //       builder:
          //           (context, node, isEnabled, onItemSelected) => EndPage(),
          //     ),
          //   ],
          // ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'wifi',
        icon: Icons.wifi_outlined,
        title: 'wifi',
        builder:
            (
              context,
              node,
              isEnabled,
              onRequestPageUpdate,
              onRequestPageMove,
              onRequestGoBack,
            ) => WifiPage(
              node: node,
              isEnabled: isEnabled,
              onFocusChanged: onRequestPageUpdate,
              onSelectionChanged: onRequestPageMove,
            ),
        children: [
          PageNode(
            id: 'wifi_empty',
            title: 'wifi ',
            isEnd: true,
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => EndPage(),
          ),
          PageNode(
            id: 'wifi_advanced',
            title: 'advanced',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => WifiAdvancedPage(
                  node: node,
                  isEnabled: isEnabled,
                  onFocusChanged: onRequestPageUpdate,
                  onSelectionChanged: onRequestPageMove,
                ),
          ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'bluetooth',
        icon: Icons.bluetooth_outlined,
        title: 'bluetooth',
        builder:
            (
              context,
              node,
              isEnabled,
              onRequestPageUpdate,
              onRequestPageMove,
              onRequestGoBack,
            ) => BluetoothPage(
              node: node,
              isEnabled: isEnabled,
              onSelectionChanged: onRequestPageUpdate,
            ),
        // isEnd: true,
        children: [
          // to make empty area for custom page
          PageNode(id: 'bt_empty', title: 'Bluetooth', isEnd: true),
        ],
      ),
    );

    // settings.children.add(
    //   PageNode(
    //     id: 'display',
    //     icon: Icons.light_mode_outlined,
    //     title: 'Display',
    //     children: [
    //       PageNode(id: 'display_brigetness', title: 'Brightness'),
    //       PageNode(id: 'display_font_size', title: 'Font size'),
    //       PageNode(id: 'display_font_type', title: 'Font type'),
    //       PageNode(id: 'display_screen_timeout', title: 'Screen timeout'),
    //     ],
    //   ),
    // );

    settings.children.add(
      PageNode(
        id: 'date_time',
        title: 'dateAndTime',
        icon: Icons.today_outlined,
        builder:
            (
              context,
              node,
              isEnabled,
              onRequestPageUpdate,
              onRequestPageMove,
              onRequestGoBack,
            ) => DateTimePage(
              node: node,
              isEnabled: isEnabled,
              onFocusChanged: onRequestPageUpdate,
              onSelectionChanged: onRequestPageMove,
              onRequestGoBack: onRequestGoBack,
            ),
        children: [
          PageNode(
            id: 'date_time_auto_update',
            title: 'autoUpdate',
            isEnd: true,
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => EndPage(),
          ),
          PageNode(
            id: 'date_time_set_date',
            title: 'setDate',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => SetDatePage(node: node, isEnabled: isEnabled),
          ),
          PageNode(
            id: 'date_time_set_time',
            title: 'setTime',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => SetTimePage(node: node, isEnabled: isEnabled),
          ),
          PageNode(
            id: 'date_time_time_zone',
            title: 'timeZone',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => SetTimezonePage(node: node, isEnabled: isEnabled),
          ),
          PageNode(
            id: 'date_time_24_hour_clock',
            title: 'hour24Clock',
            isEnd: true,
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => EndPage(),
          ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'language_input',
        title: 'languageAndInput',
        icon: Icons.language_outlined,
        children: [
          PageNode(
            id: 'language_input_display_language',
            title: 'setLanguage',
            description:
                GetIt.instance<LanguageInputManager>().getCurrentLanguageName(),
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => SetLanguagePage(node: node, isEnabled: isEnabled),
          ),
          // PageNode(id: 'language_input_keyboard', title: 'setKeyboard,
          //   builder: (context, node, isEnabled, onRequestPageUpdate, onRequestPageMove)
          //     => const EndPage() ),
          // PageNode(id: 'language_input_autofill_service', title: 'autofill, isEnd: true,
          //   builder: (context, node, isEnabled, onRequestPageUpdate, onRequestPageMove)
          //     => const EndPage() ),
          // PageNode(id: 'language_input_voice_control', title: 'voiceControl,
          //   builder: (context, node, isEnabled, onRequestPageUpdate, onRequestPageMove)
          //     => const EndPage() ),
          PageNode(
            id: 'language_input_tts',
            title: 'textToSpeech',
            children: [
              PageNode(
                id: 'language_input_tts_engine',
                title: 'selectEngine',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => SetTtsEnginePage(node: node, isEnabled: isEnabled),
              ),
              PageNode(
                id: 'language_input_tts_voice',
                title: 'selectVoice',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => SetTtsVoicePage(node: node, isEnabled: isEnabled),
              ),
            ],
          ),
          PageNode(
            id: 'language_input_stt',
            title: 'speechToText',
            children: [
              PageNode(
                id: 'language_input_stt_engine',
                title: 'selectEngine',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => SetSttEnginePage(node: node, isEnabled: isEnabled),
              ),
              PageNode(
                id: 'language_input_stt_language',
                title: 'selectLanguage',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => SetSttLanguagePage(node: node, isEnabled: isEnabled),
              ),
            ],
          ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'apps',
        icon: Icons.apps_outlined,
        title: 'apps',
        children: [
          PageNode(
            id: 'installed_apps',
            title: 'installedApps',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => AppsPage(
                  node: node,
                  listType: AppListType.installed,
                  isEnabled: isEnabled,
                  onSelectionChanged: onRequestPageMove,
                  onItemFocused: onRequestPageUpdate,
                  onRequestGoBack: onRequestGoBack,
                ),
            children: [
              PageNode(
                id: 'app_detail',
                title: 'appDetail',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => AppsDetailPage(
                      node: node,
                      isEnabled: isEnabled,
                      onSelectionChanged: onRequestPageUpdate,
                      onRequestGoBack: onRequestGoBack,
                    ),
              ),
            ],
          ),
          PageNode(
            id: 'running_apps',
            title: 'runningApps',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => AppsPage(
                  node: node,
                  listType: AppListType.running,
                  isEnabled: isEnabled,
                  onSelectionChanged: onRequestPageMove,
                  onItemFocused: onRequestPageUpdate,
                  onRequestGoBack: onRequestGoBack,
                ),
            children: [
              PageNode(
                id: 'app_detail',
                title: 'appDetail',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => AppsDetailPage(
                      node: node,
                      isEnabled: isEnabled,
                      onSelectionChanged: onRequestPageUpdate,
                      onRequestGoBack: onRequestGoBack,
                    ),
              ),
            ],
          ),
          PageNode(
            id: 'all_apps',
            title: 'allApps',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => AppsPage(
                  node: node,
                  listType: AppListType.all,
                  isEnabled: isEnabled,
                  onSelectionChanged: onRequestPageMove,
                  onItemFocused: onRequestPageUpdate,
                  onRequestGoBack: onRequestGoBack,
                ),
            children: [
              PageNode(
                id: 'app_detail',
                title: 'appDetail',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => AppsDetailPage(
                      node: node,
                      isEnabled: isEnabled,
                      onSelectionChanged: onRequestPageUpdate,
                      onRequestGoBack: onRequestGoBack,
                    ),
              ),
            ],
          ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'storage',
        icon: Icons.archive_outlined,
        title: 'storage',
        children: [
          PageNode(
            id: 'storage_internal',
            title: 'internalStorage',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => StorageDetailPage(
                  node: node,
                  listType: StorageListType.internal,
                  isEnabled: isEnabled,
                  onSelectionChanged: onRequestPageMove,
                  onItemFocused: onRequestPageUpdate,
                  onRequestGoBack: onRequestGoBack,
                ),
          ),
          PageNode(
            id: 'storage_external',
            title: 'externalStorage',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => StorageDetailPage(
                  node: node,
                  listType: StorageListType.external,
                  isEnabled: isEnabled,
                  onSelectionChanged: onRequestPageMove,
                  onItemFocused: onRequestPageUpdate,
                  onRequestGoBack: onRequestGoBack,
                ),
            isEnd: true,
          ),
          PageNode(
            id: 'storage_default_settings',
            title: 'storageSetting',
            children: [
              // to make empty area for custom page
              // PageNode(
              //   id: 'share_contents',
              //   title: 'sharedContent,
              //   builder:
              //       (
              //         context,
              //         node,
              //         isEnabled,
              //         onRequestPageUpdate,
              //         onRequestPageMove,
              //         onRequestGoBack,
              //       ) => StorageSettingPage(
              //         node: node,
              //         isEnabled: isEnabled,
              //         onSelectionChanged: onRequestPageMove,
              //         onRequestGoBack: onRequestGoBack,
              //       ),
              //   isEnd: true,
              // ),
              PageNode(
                id: 'app_installation',
                title: 'appInstallation',
                builder:
                    (
                      context,
                      node,
                      isEnabled,
                      onRequestPageUpdate,
                      onRequestPageMove,
                      onRequestGoBack,
                    ) => StorageSettingPage(
                      node: node,
                      isEnabled: isEnabled,
                      onSelectionChanged: onRequestPageMove,
                      onRequestGoBack: onRequestGoBack,
                    ),
              ),
            ],
          ),
          //   builder:
          //       (
          //         context,
          //         node,
          //         isEnabled,
          //         onRequestPageUpdate,
          //         onRequestPageMove,
          //         onRequestGoBack,
          //       ) => StorageDetailPage(
          //         node: node,
          //         listType: StorageListType.internal,
          //         isEnabled: isEnabled,
          //         onSelectionChanged: onRequestPageMove,
          //         onItemFocused: onRequestPageUpdate,
          //         onRequestGoBack: onRequestGoBack,
          //       ),
          // ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'volume',
        icon: Icons.volume_up_outlined,
        title: 'volume',
        builder:
            (
              context,
              node,
              isEnabled,
              onRequestPageUpdate,
              onRequestPageMove,
              onRequestGoBack,
            ) => VolumeSettingPage(
              node: node,
              isEnabled: isEnabled,
              onFocusChanged: onRequestPageUpdate,
              onSelectionChanged: onRequestPageMove,
            ),
        children: [
          PageNode(
            id: 'volume_media',
            title: 'mediaVolume',
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => VolumeDetailPage(
                  node: node,
                  isEnabled: isEnabled,
                  onRequestGoBack: onRequestGoBack,
                ),
          ),
        ],
      ),
    );

    settings.children.add(
      PageNode(
        id: 'additional_features',
        icon: Icons.auto_awesome_outlined,
        title: 'additionalFeatures',
        builder:
            (
              context,
              node,
              isEnabled,
              onRequestPageUpdate,
              onRequestPageMove,
              onRequestGoBack,
            ) => AdditonalFeaturePage(
              node: node,
              isEnabled: isEnabled,
              onFocusChanged: onRequestPageUpdate,
              onSelectionChanged: onRequestPageMove,
              onRequestGoBack: onRequestGoBack,
            ),
        children: [
          PageNode(id: 'additionaly_feaure_media', title: '', isEnd: true),
          PageNode(id: 'additionaly_feaure_live', title: '', isEnd: true),
          PageNode(
            id: 'additionaly_feaure_ai',
            title: 'aiChatConfiguration',
            icon: const IconData(0x0054), //unicode T: 0054
            isEnd: true,
            builder:
                (
                  context,
                  node,
                  isEnabled,
                  onRequestPageUpdate,
                  onRequestPageMove,
                  onRequestGoBack,
                ) => AdditionalFeatureAIPage(node: node, isEnabled: isEnabled),
          ),
        ],
      ),
    );

    return settings;
  }
}
