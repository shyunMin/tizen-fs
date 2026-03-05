import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/native/mcp_service.dart';
import 'package:tizen_fs/models/ai_model.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

enum ChatMessageType { user, sysetm }

class ChatMessage {
  ChatMessageType type;
  String message;

  ChatMessage({required this.type, this.message = ''});
}

abstract class AIService {
  String get modelName;

  Future<bool> connect();
  Future<String> sendMessage(String message);
  Future<void> disconnect();
}
