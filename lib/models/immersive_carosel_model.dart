import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImmersiveCarouselContent {
  final String overline;
  final String title;
  final String description;
  final String backdrop;
  final String buttonText;
  final String url;

  ImmersiveCarouselContent({
    required this.overline,
    required this.title,
    required this.description,
    required this.backdrop,
    required this.buttonText,
    required this.url,
  });

  factory ImmersiveCarouselContent.fromJson(Map<String, dynamic> json) {
    return ImmersiveCarouselContent(
      overline: json['overline'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      backdrop: json['backdrop'] as String,
      url: json['url'] as String,
      buttonText: json['buttonText'] as String,
    );
  }

  static Future<List<ImmersiveCarouselContent>> loadFromJson() async {
    final jsonString = await rootBundle.loadString(
      'assets/mock/mock_carousel_content.json',
    );
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<ImmersiveCarouselContent> contents =
        jsonList
            .map((json) => ImmersiveCarouselContent.fromJson(json))
            .toList();

    return contents;
  }
}

class ImmersiveCarouselModel extends ChangeNotifier {
  late List<ImmersiveCarouselContent> contents;
  bool _isLoading = false;
  int _selectedIndex = 0;
  final defaultBackdropUrl = 'gradient-bg-static-alt-a-D0K-Mjox.jpg';

  ImmersiveCarouselModel(this.contents);

  ImmersiveCarouselModel.fromMock() {
    _isLoading = true;
    ImmersiveCarouselContent.loadFromJson().then((value) {
      _isLoading = false;
      contents = value;
      notifyListeners();
    });
  }

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int get itemCount => _isLoading ? 0 : contents.length;

  String get backdrop =>
      (_isLoading) ? defaultBackdropUrl : contents[_selectedIndex].backdrop;

  ImmersiveCarouselContent getSelectedContent() {
    if (_isLoading) {
      return ImmersiveCarouselContent(
        overline: 'Loading...',
        title: 'Loading...',
        description: 'Loading...',
        backdrop: 'Loading...',
        url: '',
        buttonText: 'Loading...',
      );
    }
    return contents[_selectedIndex];
  }
}
