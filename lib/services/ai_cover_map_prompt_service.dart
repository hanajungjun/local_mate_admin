import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_cover_map_prompt_model.dart';

class AiCoverMapPromptService {
  static final _supabase = Supabase.instance.client;

  static Future<List<AiCoverMapPromptModel>> fetchByType(String type) async {
    final res = await _supabase
        .from('ai_cover_map_prompts')
        .select()
        .eq('type', type)
        .order('created_at');

    return (res as List).map((e) => AiCoverMapPromptModel.fromMap(e)).toList();
  }

  static Future<void> add({
    required String type,
    required String title,
    required String content,
  }) async {
    await _supabase.from('ai_cover_map_prompts').insert({
      'type': type,
      'title': title,
      'content': content,
      'is_active': true,
    });
  }

  static Future<void> update(AiCoverMapPromptModel model) async {
    await _supabase.from('ai_cover_map_prompts').update({
      'title': model.title,
      'content': model.content,
      'is_active': model.isActive,
    }).eq('id', model.id);
  }
}
