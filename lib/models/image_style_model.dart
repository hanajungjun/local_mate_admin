// lib/models/image_style_model.dart
class ImageStyleModel {
  final String id;
  final String title;
  final String titleEn;
  final String prompt;
  final bool isEnabled;
  final bool isPremium; // ✅ 추가
  final String? thumbnailUrl;
  final int sortOrder;

  ImageStyleModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.prompt,
    required this.isEnabled,
    required this.isPremium, // ✅ 추가
    this.thumbnailUrl,
    this.sortOrder = 0,
  });

  factory ImageStyleModel.fromMap(Map<String, dynamic> map) {
    return ImageStyleModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      titleEn: map['title_en'] as String? ?? '',
      prompt: map['prompt'] as String? ?? '',
      isEnabled: map['is_enabled'] as bool? ?? true,
      isPremium: map['is_premium'] as bool? ?? false, // ✅ 추가
      thumbnailUrl: map['thumbnail_url'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  ImageStyleModel copyWith({
    String? title,
    String? titleEn,
    String? prompt,
    bool? isEnabled,
    bool? isPremium, // ✅ 추가
    String? thumbnailUrl,
    int? sortOrder,
  }) {
    return ImageStyleModel(
      id: id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      prompt: prompt ?? this.prompt,
      isEnabled: isEnabled ?? this.isEnabled,
      isPremium: isPremium ?? this.isPremium, // ✅ 추가
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
