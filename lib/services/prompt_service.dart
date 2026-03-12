import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prompt_model.dart';

class PromptService {
  static final _supabase = Supabase.instance.client;

  static Future<List<PromptModel>> fetchPrompts() async {
    final response =
        await _supabase.from('ai_prompts').select().order('created_at');
    return (response as List).map((e) => PromptModel.fromJson(e)).toList();
  }

  static Future<void> addPrompt(PromptModel prompt) async {
    await _supabase.from('ai_prompts').insert(prompt.toJson());
  }

  static Future<void> updatePrompt(PromptModel prompt) async {
    await _supabase
        .from('ai_prompts')
        .update(prompt.toJson())
        .eq('id', prompt.id);
  }

  static Future<void> deletePrompt(int id) async {
    await Supabase.instance.client
        .from('prompts') // 테이블명이 prompts라고 가정
        .delete()
        .eq('id', id);
  }

  static Future<void> setActive(String id) async {
    // 모든 프롬프트를 비활성화하고 선택한 것만 활성화 (라디오 버튼 방식 로직)
    await _supabase.from('ai_prompts').update({'is_active': false}).neq(
        'id', '00000000-0000-0000-0000-000000000000');
    await _supabase.from('ai_prompts').update({'is_active': true}).eq('id', id);
  }
}
