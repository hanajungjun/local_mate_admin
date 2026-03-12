import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_mate_admin/services/admin_dashboard_service.dart';
import 'package:local_mate_admin/pages/admin/admin_photo_list_page.dart';
import 'package:local_mate_admin/pages/admin/admin_active_user_chart_page.dart';
import 'package:local_mate_admin/pages/admin/admin_new_user_chart_page.dart';
import 'package:local_mate_admin/pages/admin/admin_premium_user_list_page.dart';
import 'package:local_mate_admin/pages/admin/admin_premium_expiring_page.dart';
import 'package:local_mate_admin/pages/admin/mini_sparkline.dart';
import 'package:local_mate_admin/storage_urls.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDashboardService _service = AdminDashboardService();

  late Future<int> _totalUserCountFuture;
  late Future<int> _yesterdayActiveUserCountFuture;
  late Future<int> _uploadedPhotoCountFuture;
  late Future<int> _activePremiumUserCountFuture;
  late Future<int> _premiumExpiringSoonCountFuture;
  late Future<List<int>> _premiumExpiringSparklineFuture;
  late Future<bool> _isReviewModeFuture;
  late Future<List<String>> _loadingImagesFuture;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  void _refreshStats() {
    setState(() {
      _totalUserCountFuture = _service.getTotalUserCount();
      _yesterdayActiveUserCountFuture = _service.getYesterdayActiveUserCount();
      _uploadedPhotoCountFuture = _service.getUploadedPhotoCount();
      _activePremiumUserCountFuture = _service.getActivePremiumUserCount();
      _premiumExpiringSoonCountFuture = _service.getPremiumExpiringSoonCount();
      _premiumExpiringSparklineFuture = _service.getPremiumExpiringSparkline();
      _isReviewModeFuture = _service.getReviewMode();
      _loadingImagesFuture = _getLoadingImages();
    });
  }

  Future<List<String>> _getLoadingImages() async {
    try {
      final res = await Supabase.instance.client
          .from('app_config')
          .select('loading_images')
          .eq('id', 1)
          .maybeSingle();

      if (res != null && res['loading_images'] != null) {
        return List<String>.from(res['loading_images']);
      }
    } catch (e) {
      debugPrint("❌ 이미지 리스트 로드 실패: $e");
    }
    return [];
  }

  void _openImageManager(List<String> currentImages) {
    showDialog(
      context: context,
      builder: (context) => LoadingImageManagerDialog(
        initialImages: currentImages,
        onChanged: () => _refreshStats(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            children: [
              FutureBuilder<int>(
                future: _totalUserCountFuture,
                builder: (context, snapshot) => StatCard(
                  title: '총 가입자 수',
                  subtitle: '누적 가입자',
                  value: snapshot.data?.toString() ?? '-',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminNewUserChartPage(),
                    ),
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: _yesterdayActiveUserCountFuture,
                builder: (context, snapshot) => StatCard(
                  title: '어제 접속자 수',
                  subtitle: '활동 기준',
                  value: snapshot.data?.toString() ?? '-',
                  icon: Icons.login,
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminActiveUserChartPage(),
                    ),
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: _uploadedPhotoCountFuture,
                builder: (context, snapshot) => StatCard(
                  title: '업로드된 사진 수',
                  subtitle: '유저 업로드 기준',
                  value: snapshot.data?.toString() ?? '-',
                  icon: Icons.photo_library,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPhotoListPage(),
                    ),
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: _activePremiumUserCountFuture,
                builder: (context, snapshot) => StatCard(
                  title: '프리미엄 유저',
                  subtitle: '현재 활성',
                  value: snapshot.data?.toString() ?? '-',
                  icon: Icons.workspace_premium,
                  color: Colors.amber,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPremiumUserListPage(),
                    ),
                  ),
                ),
              ),
              FutureBuilder<List<int>>(
                future: _premiumExpiringSparklineFuture,
                builder: (context, sparkSnapshot) => FutureBuilder<int>(
                  future: _premiumExpiringSoonCountFuture,
                  builder: (context, countSnapshot) => StatCard(
                    title: '만료 예정',
                    subtitle: '7일 이내',
                    value: countSnapshot.data?.toString() ?? '-',
                    icon: Icons.timer,
                    color: Colors.redAccent,
                    trailing: sparkSnapshot.hasData
                        ? MiniSparkline(
                            values: sparkSnapshot.data!,
                            color: Colors.redAccent,
                          )
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPremiumExpiringPage(),
                      ),
                    ),
                  ),
                ),
              ),
              FutureBuilder<bool>(
                future: _isReviewModeFuture,
                builder: (context, snapshot) {
                  bool isOn = snapshot.data ?? false;
                  return StatCard(
                    title: '애플 심사 모드',
                    subtitle: isOn ? '심사 중 (ID/PW 노출)' : '일반 모드 (소셜 전용)',
                    value: isOn ? 'ON' : 'OFF',
                    icon: Icons.apple,
                    color: isOn ? Colors.orange : Colors.grey,
                    trailing: Switch(
                      value: isOn,
                      activeColor: Colors.orange,
                      onChanged: (val) async {
                        await _service.updateReviewMode(val);
                        _refreshStats();
                      },
                    ),
                    onTap: () async {
                      await _service.updateReviewMode(!isOn);
                      _refreshStats();
                    },
                  );
                },
              ),
              FutureBuilder<List<String>>(
                future: _loadingImagesFuture,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  return StatCard(
                    title: '로딩 이미지 관리',
                    subtitle: '${list.length}개의 이미지 랜덤 노출',
                    value: list.length.toString(),
                    icon: Icons.auto_awesome_motion,
                    color: Colors.indigo,
                    onTap: () => _openImageManager(list),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildNoticeContainer(),
        ],
      ),
    );
  }

  Widget _buildNoticeContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관리자 안내',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '총 가입자 수는 users 테이블 기준 누적 값입니다.\n'
            '어제 접속자 수는 updated_at 기준 활동 사용자 수입니다.\n'
            '업로드된 사진 수는 travel_days.photo_urls 기준입니다.\n'
            '프리미엄 유저는 is_premium = true 기준입니다.\n'
            '로딩 이미지는 등록된 리스트 중 앱 실행 시 무작위로 한 장이 노출됩니다.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/* ====================== LOADING IMAGE MANAGER DIALOG ====================== */
class LoadingImageManagerDialog extends StatefulWidget {
  final List<String> initialImages;
  final VoidCallback onChanged;

  const LoadingImageManagerDialog({
    super.key,
    required this.initialImages,
    required this.onChanged,
  });

  @override
  State<LoadingImageManagerDialog> createState() =>
      _LoadingImageManagerDialogState();
}

class _LoadingImageManagerDialogState extends State<LoadingImageManagerDialog> {
  late List<String> _images;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  Future<void> _addImage() async {
    if (_images.length >= 50) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isProcessing = true);
      try {
        final bytes = await image.readAsBytes();

        // ✅ Supabase 스토리지 경로 규격 (system/onload/파일명.webp)
        final fileName =
            'system/onload/IMG_${DateTime.now().millisecondsSinceEpoch}.webp';

        // ✅ Supabase travel_images 버킷에 업로드
        await Supabase.instance.client.storage
            .from('travel_images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/webp',
                upsert: true,
              ),
            );

        // ✅ DB 업데이트
        _images.add(fileName);
        await _updateDatabase();
      } catch (e) {
        debugPrint("❌ 업로드 에러: $e");
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() => _isProcessing = true);
    try {
      // ✅ 스토리지에서도 파일 삭제
      final pathToRemove = _images[index];
      await Supabase.instance.client.storage.from('travel_images').remove([
        pathToRemove,
      ]);

      _images.removeAt(index);
      await _updateDatabase();
    } catch (e) {
      debugPrint("❌ 삭제 에러: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateDatabase() async {
    await Supabase.instance.client
        .from('app_config')
        .update({'loading_images': _images})
        .eq('id', 1);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '로딩 이미지 관리 (랜덤)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${_images.length} / 50',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return InkWell(
                      onTap: _addImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  // ✅ StorageUrls.systemImage를 통해 Supabase URL 생성
                  final url = StorageUrls.systemImage(_images[index]);

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
