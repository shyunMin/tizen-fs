import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mcp_client/mcp_client.dart';
import 'package:tizen_fs/native/action_manager.dart';

class McpService {
  static List<Tool> _tools = [];
  static Client? _client;

  static String getActionsString() {
    String actions = '### [Tool List]\n';

    int cnt = 1;
    for (var tool in _tools) {
      if (tool.name.contains("actionTool")) {
        final name = tool.name.substring(
          tool.name.indexOf(".") + 1,
          tool.name.length,
        );
        actions += "$cnt. **$name**: ${tool.description}";
        debugPrint("$cnt. $name loaded");
        cnt++;
      }
    }

    return actions;
  }

  static Future<void> disconnect() async {
    debugPrint('disconnect');
    // TODO: bug fix
    // _tools = [];
    // _client?.disconnect();
    // _client = null;
  }

  static Future<void> connect() async {
    if (_client != null) return;

    _tools = [];

    final config = McpClient.simpleConfig(
      name: 'OneAI',
      version: '1.0.0',
      enableDebugLogging: true,
    );

    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );

    String ipAddress = '';

    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        if (!address.isLoopback) {
          debugPrint('address: $address');
          ipAddress = address.address;
        }
      }
    }

    final transportConfig = TransportConfig.streamableHttp(
      baseUrl: 'http://$ipAddress:50050/mcp',
      // oauthConfig: OAuthConfig(
      //   authorizationEndpoint: 'https://auth.example.com/authorize',
      //   tokenEndpoint: 'https://auth.example.com/token',
      //   clientId: 'your-client-id',
      // ),
      enableCompression: true,
      heartbeatInterval: const Duration(seconds: 60),
      useHttp2: true,
      maxConcurrentRequests: 20,
      timeout: const Duration(seconds: 10),
    );

    debugPrint('Connecting to MCP server...');

    final clientResult = await McpClient.createAndConnect(
      config: config,
      transportConfig: transportConfig,
    );

    try {
      _client = clientResult.fold((c) {
        debugPrint('Successfully connected to server!');
        return c;
      }, (error) => throw Exception('Failed to connect: $error'));

      debugPrint('\n--- Available Tools ---');
      final tools = await _client?.listTools() ?? [];
      if (tools.isEmpty) {
        debugPrint('No tools available.');
      } else {
        for (final tool in tools) {
          _tools.add(tool);
        }
      }

      await Future.delayed(Duration(seconds: 1));

      debugPrint('\Tools has been loaded successfully!');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  static Future<void> runTool(Map<String, dynamic> actionData) async {
    String name = '';
    Map<String, dynamic> args = {};
    actionData.forEach((key, value) {
      if (key == "__K_ACTION_NAME") {
        name = 'actionTool.$value';
      } else {
        final arg = {key: value};
        args.addEntries(arg.entries);
      }
    });
    debugPrint(
      'Run: $name, args: ${args.toString()}, _client=${_client == null}',
    );

    // Check if this is actionTool.homeAdditionalFeature with enabled: off
    if (name == 'actionTool.homeAdditionalFeature' &&
        args.containsKey('featureName') &&
        args['featureName'] == 'ai' &&
        args.containsKey('enabled') &&
        args['enabled'] == 'off') {
      debugPrint(
        'Skipping tool call for homeAdditionalFeature with ai feature disabled',
      );

      // disconnect();
      ActionManager.runAction(actionData);
      return;
    }

    debugPrint("mac isConnected: ${_client?.isConnected}");

    if (_client?.isConnected ?? false) {
      final result = await _client?.callTool(name, args);
      final content = result?.content.first;
      if (content is TextContent) {
        debugPrint('Results: ${content.text}');
      }
    } else {
      _client = null;
      connect();
    }
  }
}
