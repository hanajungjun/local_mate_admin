import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 👤 총 가입자 수
  /// - users 테이블 row 수
  Future<int> getTotalUserCount() async {
    final response =
        await _client.from('users').select('id').count(CountOption.exact);

    return response.count ?? 0;
  }

  /// 🔑 어제 접속자 수 (updated_at 기준)
  Future<int> getYesterdayActiveUserCount() async {
    final result = await _client.rpc('admin_yesterday_active_user_count');
    return (result as int?) ?? 0;
  }

  /// 🖼 업로드된 사진 수 (photo_urls 기준)
  Future<int> getUploadedPhotoCount() async {
    final result = await _client.rpc('admin_uploaded_photo_count');
    return (result as int?) ?? 0;
  }

  /// 📊 최근 7일 접속자 수
  Future<List<Map<String, dynamic>>> getActiveUsersLast7Days() async {
    final result = await _client.rpc('admin_active_users_last_7_days');

    return List<Map<String, dynamic>>.from(result);
  }

  /// 📈 최근 7일 가입자 수
  Future<List<Map<String, dynamic>>> getNewUsersLast7Days() async {
    final result = await _client.rpc('admin_new_users_last_7_days');

    return List<Map<String, dynamic>>.from(result);
  }

  /// 💎 현재 프리미엄 유저 수
  Future<int> getActivePremiumUserCount() async {
    final result = await _client.rpc('admin_active_premium_user_count');
    return (result as int?) ?? 0;
  }

  /// ⏰ 7일 이내 만료 예정 프리미엄 유저 수
  Future<int> getPremiumExpiringSoonCount() async {
    final result = await _client.rpc('admin_premium_expiring_soon_count');
    return (result as int?) ?? 0;
  }

  /// ⏰ 프리미엄 만료 예정 스파크라인
  Future<List<int>> getPremiumExpiringSparkline() async {
    final result = await _client.rpc('admin_premium_expiring_sparkline');

    return List<Map<String, dynamic>>.from(result)
        .map((e) => e['expiring_count'] as int)
        .toList();
  }

  // 심사 모드 상태 가져오기
  Future<bool> getReviewMode() async {
    final data = await Supabase.instance.client
        .from('app_config')
        .select('is_review_mode')
        .single();
    return data['is_review_mode'] ?? false;
  }

// 심사 모드 상태 업데이트하기
  Future<void> updateReviewMode(bool isAdminReview) async {
    await Supabase.instance.client.from('app_config').update(
        {'is_review_mode': isAdminReview}).eq('id', 1); // id가 1인 설정을 업데이트
  }
}
