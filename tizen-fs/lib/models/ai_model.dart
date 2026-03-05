class Content {
  final String languageCode;
  final String content;

  Content({required this.languageCode, required this.content});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      languageCode: json['languageCode'] as String,
      content: json['content'] as String,
    );
  }
}

class Model {
  final String modelId;
  final List<Content> name;
  final List<Content> description;

  Model({required this.modelId, required this.name, required this.description});

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      modelId: json['modelId'] as String? ?? '',
      name:
          (json['name'] as List<dynamic>?)
              ?.map((e) => Content.fromJson(e))
              .toList() ??
          [],
      description:
          (json['description'] as List<dynamic>?)
              ?.map((e) => Content.fromJson(e))
              .toList() ??
          [],
    );
  }

  String getDescrption(String lang) {
    return description
            .where((d) => d.languageCode == lang)
            .firstOrNull
            ?.content ??
        '';
  }

  String getName(String lang) {
    return name.where((d) => d.languageCode == lang).firstOrNull?.content ?? '';
  }
}
