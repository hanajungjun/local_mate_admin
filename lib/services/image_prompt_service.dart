import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/image_prompt_model.dart';

class ImagePromptService {
  static final _supabase = Supabase.instance.client;

  // 테이블 이름 ai_image_prompts 확인 완료
  static Future<List<ImagePromptModel>> fetchAll() async {
    final response = await _supabase
        .from('ai_image_prompts')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => ImagePromptModel.fromJson(e)).toList();
  }

  static Future<void> add(
      {required String title, required String ko, required String en}) async {
    await _supabase.from('ai_image_prompts').insert({
      'title': title,
      'content_ko': ko,
      'content_en': en,
      'is_active': false,
    });
  }

  static Future<void> update(ImagePromptModel p) async {
    await _supabase.from('ai_image_prompts').update(p.toJson()).eq('id', p.id);
  }

  static Future<void> setActive(String id) async {
    // 모든 프롬프트 비활성화 후 선택한 것만 활성화
    await _supabase.from('ai_image_prompts').update({'is_active': false}).neq(
        'id', '00000000-0000-0000-0000-000000000000');
    await _supabase
        .from('ai_image_prompts')
        .update({'is_active': true}).eq('id', id);
  }
}
