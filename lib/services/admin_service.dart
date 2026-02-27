import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AdminService {
  final _supabase = Supabase.instance.client;

  // ✅ [수정] 최신순 정렬 (ascending: false) 적용
  Stream<List<Map<String, dynamic>>> get allGuideRequestsStream {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }

  Future<void> updateGuideStatus(String userId, String status) async {
    try {
      await _supabase
          .from('users')
          .update({
            'guide_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('상태 업데이트 실패: $e');
    }
  }

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return _supabase.storage.from('verifications').getPublicUrl(path);
  }
}
