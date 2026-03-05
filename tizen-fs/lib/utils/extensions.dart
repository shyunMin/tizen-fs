import 'package:tizen_fs/models/page_node.dart';

extension IntExtensions on int {
  String toSizeString() {
    final suffixes = ["Bytes", "KB", "MB", "GB"];
    int counter = 0;

    if (this == 0) {
      return '$this ${suffixes[counter]}';
    }

    double size = this.toDouble();
    while ((size / 1024).round() >= 1) {
      size = size / 1024;
      counter++;
    }

    String formatted = size.toStringAsFixed(2);

    if (formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }

    if (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    return '$formatted ${suffixes[counter]}';
  }
}

extension DurationExtensions on Duration {
  Duration clamp(Duration min, Duration max) {
    if (this < min) {
      return min;
    }

    if (this > max) {
      return max;
    }

    return this;
  }
}

extension PageNodeExtensions on PageNode {
  PageNode? find(String uri) {
    final nodes = uri.split('/').where((s) => s.isNotEmpty).skip(1).toList();
    PageNode parent = this;
    for (var id in nodes) {
      final node = parent.children.where((c) => c.id == id).firstOrNull;
      if (node != null) {
        parent = node;
      } else {
        return null;
      }
    }
    return parent;
  }
}
