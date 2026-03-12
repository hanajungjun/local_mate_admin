class ImagePromptModel {
  final String id;
  final String title;
  final String contentKo;
  final String contentEn;
  final bool isActive;

  ImagePromptModel({
    required this.id,
    required this.title,
    required this.contentKo,
    required this.contentEn,
    required this.isActive,
  });

  factory ImagePromptModel.fromJson(Map<String, dynamic> json) {
    return ImagePromptModel(
      id: json['id'],
      title: json['title'] ?? '',
      contentKo: json['content_ko'] ?? '',
      contentEn: json['content_en'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content_ko': contentKo,
      'content_en': contentEn,
      'is_active': isActive,
    };
  }
}
