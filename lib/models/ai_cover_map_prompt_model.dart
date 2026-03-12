class AiCoverMapPromptModel {
  final String id;
  final String type; // 'cover' | 'map'
  final String title;
  final String content;
  final bool isActive;

  AiCoverMapPromptModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isActive,
  });

  factory AiCoverMapPromptModel.fromMap(Map<String, dynamic> map) {
    return AiCoverMapPromptModel(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      content: map['content'],
      isActive: map['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'is_active': isActive,
    };
  }
}
