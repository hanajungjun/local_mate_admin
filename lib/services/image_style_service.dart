import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/image_style_model.dart';

class ImageStyleService {
  static final _client = Supabase.instance.client;
  static const _bucket = 'travel_images';

  // ✅ 1. 모든 스타일 가져오기 (정렬 순서 적용)
  static Future<List<ImageStyleModel>> fetchAll() async {
    final res = await _client
        .from('ai_image_styles')
        .select()
        .order('sort_order', ascending: true);
    return (res as List).map((e) => ImageStyleModel.fromMap(e)).toList();
  }

  // ✅ 2. 활성화된 스타일만 가져오기 (앱 사용자용)
  static Future<List<ImageStyleModel>> fetchEnabled() async {
    final res = await _client
        .from('ai_image_styles')
        .select()
        .eq('is_enabled', true)
        .order('sort_order', ascending: true);
    return (res as List).map((e) => ImageStyleModel.fromMap(e)).toList();
  }

  // ✅ 3. 드래그 앤 드롭 순서 업데이트
  static Future<void> updateOrder(List<ImageStyleModel> styles) async {
    for (int i = 0; i < styles.length; i++) {
      await _client
          .from('ai_image_styles')
          .update({'sort_order': i}).eq('id', styles[i].id);
    }
  }

  // ✅ 4. 스타일 추가
  static Future<void> add({
    required String title,
    required String titleEn,
    required String prompt,
    bool isPremium = false,
  }) async {
    final maxRes = await _client
        .from('ai_image_styles')
        .select('sort_order')
        .order('sort_order', ascending: false)
        .limit(1)
        .maybeSingle();

    final nextOrder = (maxRes?['sort_order'] as int? ?? 0) + 1;

    await _client.from('ai_image_styles').insert({
      'title': title,
      'title_en': titleEn,
      'prompt': prompt,
      'sort_order': nextOrder,
      'is_enabled': true,
      'is_premium': isPremium,
    });
  }

  // ✅ 5. 스타일 정보 업데이트
  static Future<void> update(ImageStyleModel style) async {
    await _client.from('ai_image_styles').update({
      'title': style.title,
      'title_en': style.titleEn,
      'prompt': style.prompt,
      'thumbnail_url': style.thumbnailUrl, // 여기서 리턴받은 system/... 경로가 저장됨
      'sort_order': style.sortOrder,
      'is_enabled': style.isEnabled,
      'is_premium': style.isPremium,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', style.id);
  }

  // ✅ 6. 활성화 여부 토글
  static Future<void> setEnabled(String id, bool enabled) async {
    await _client.from('ai_image_styles').update({
      'is_enabled': enabled,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

// ✅ 7. 썸네일 업로드 (슈파베이스 스토리지 구조 반영)
  static Future<String> uploadThumbnail({
    required String styleId,
    required Uint8List imageBytes,
    String? oldUrl,
  }) async {
    // ✅ 기존 파일 삭제 (전체 URL에서 경로만 추출)
    if (oldUrl != null && oldUrl.isNotEmpty) {
      try {
        // URL에서 버킷 이름('travel_images/') 이후의 경로만 잘라냅니다.
        final path = oldUrl.split('$_bucket/').last.split('?').first;
        await _client.storage.from(_bucket).remove([path]);
      } catch (e) {
        debugPrint("기존 파일 삭제 실패: $e");
      }
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final String relativePath =
        'system/style_thumbnails/${styleId}_$timestamp.webp';

    // 스토리지 업로드
    await _client.storage.from(_bucket).uploadBinary(
          relativePath,
          imageBytes,
          fileOptions:
              const FileOptions(contentType: 'image/webp', upsert: true),
        );

    // ✅ [수정] 상대 경로가 아닌 '전체 URL'을 반환하여 DB에 저장되게 함
    return _client.storage.from(_bucket).getPublicUrl(relativePath);
  }

  // ✅ 8. 스타일 삭제 (경로 로직 완전 수정)
  static Future<void> delete(ImageStyleModel style) async {
    if (style.thumbnailUrl != null && style.thumbnailUrl!.isNotEmpty) {
      try {
        // ✅ 전체 URL에서 'travel_images/' 뒤쪽 경로만 추출
        final path =
            style.thumbnailUrl!.split('$_bucket/').last.split('?').first;
        await _client.storage.from(_bucket).remove([path]);
      } catch (e) {
        debugPrint("스토리지 파일 삭제 실패: $e");
      }
    }
    await _client.from('ai_image_styles').delete().eq('id', style.id);
  }
}
