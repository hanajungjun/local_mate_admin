import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_premium_prompt_model.dart';

class AiPremiumPromptService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'ai_premium_prompt';
  static const _defaultBaseKey = 'default';

  static Future<List<AiPremiumPromptModel>> fetchAll() async {
    final rows = await _supabase
        .from(_table)
        .select()
        .order('updated_at', ascending: false);

    return rows
        .map<AiPremiumPromptModel>((e) => AiPremiumPromptModel.fromMap(e))
        .toList();
  }

  static Future<void> add(AiPremiumPromptModel model) async {
    await _supabase.from(_table).insert(model.toMap());
  }

  static Future<void> update(AiPremiumPromptModel model) async {
    await _supabase.from(_table).update(model.toMap()).eq('key', model.key);
  }

  // ✅ 선택된 것만 활성화
  static Future<void> activateOnlyByKey(String key) async {
    await _supabase
        .from(_table)
        .update({'is_active': false}).eq('base_preset_key', _defaultBaseKey);

    await _supabase.from(_table).update({'is_active': true}).eq('key', key);
  }
}
