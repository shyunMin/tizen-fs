class StreamChannel {
  String name;
  String logo;
  String url;
  String? category;
  String? description;

  StreamChannel({
    required this.name,
    required this.url,
    this.logo = "",
    this.category,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'url': url,
      'category': category,
      'description': description,
    };
  }

  factory StreamChannel.fromJson(Map<String, dynamic> json) {
    return StreamChannel(
      name: json['name'],
      url: json['url'],
      logo: json['logo'],
      category: json['category'],
      description: json['description'],
    );
  }
}
