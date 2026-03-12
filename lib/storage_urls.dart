import 'package:supabase_flutter/supabase_flutter.dart';

class StorageUrls {
  StorageUrls._();

  static const String _bucket = 'travel_images';

  static String systemImage(String path) {
    if (path.isEmpty) return '';

    // ✅ 핵심: 이미 전체 URL인 경우 그대로 반환해야 함!
    if (path.startsWith('http')) {
      return path;
    }

    // 상대 경로일 때만 슈파베이스 주소 생성
    return Supabase.instance.client.storage.from(_bucket).getPublicUrl(path);
  }

  // travelImage도 동일한 로직 적용
  static String travelImage(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return Supabase.instance.client.storage.from(_bucket).getPublicUrl(path);
  }
}
