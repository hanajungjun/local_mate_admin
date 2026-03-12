class AiPremiumPromptModel {
  final String key;
  final String basePresetKey;
  final String title;
  final String prompt;
  final String? description;
  final bool isActive;
  final DateTime? updatedAt;

  static const String defaultBasePresetKey = 'default';

  AiPremiumPromptModel({
    String? key,
    String? basePresetKey,
    required this.title,
    required this.prompt,
    this.description,
    required this.isActive,
    this.updatedAt,
  })  : key = key ?? _generateKey(),
        basePresetKey = basePresetKey ?? defaultBasePresetKey;

  static String _generateKey() {
    return 'premium_${DateTime.now().millisecondsSinceEpoch}';
  }

  factory AiPremiumPromptModel.fromMap(Map<String, dynamic> map) {
    return AiPremiumPromptModel(
      key: map['key'],
      basePresetKey: map['base_preset_key'] ?? defaultBasePresetKey,
      title: map['title'],
      prompt: map['prompt'],
      description: map['description'],
      isActive: map['is_active'] ?? false,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'base_preset_key': basePresetKey,
      'title': title,
      'prompt': prompt,
      'description': description,
      'is_active': isActive,
    };
  }

  AiPremiumPromptModel copyWith({
    String? title,
    String? prompt,
    String? description,
    bool? isActive,
  }) {
    return AiPremiumPromptModel(
      key: key,
      basePresetKey: basePresetKey,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt,
    );
  }
}
