import 'package:flutter/material.dart';
import 'package:tizen_fs/models/item_display_interface.dart';

class PageNode implements ItemDisplayInterface {
  final String id;
  final String title;
  final String? description;
  final IconData? icon;
  final List<PageNode> children;
  Widget Function(
    BuildContext context,
    PageNode node,
    bool isEnabled,
    Function(int) onRequestPageUpdate,
    Function(int) onRequestPageMove,
    Function(int) onRequestGoBack,
  )?
  builder;
  bool isEnd;
  late final String uri;

  PageNode({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.builder,
    this.children = const [],
    this.isEnd = false,
  });

  @override
  String get displayText => title;

  @override
  String? get displaySubText => (description != null) ? description : null;

  @override
  Object? get iconSourceData => icon;

  @override
  IconSourceType get iconSourceType => IconSourceType.icon;

  @override
  bool get isSelectable => true;
}
