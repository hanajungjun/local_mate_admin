import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:local_mate_admin/services/admin_service.dart';

class GuideApprovalPage extends StatefulWidget {
  const GuideApprovalPage({super.key});

  @override
  State<GuideApprovalPage> createState() => _GuideApprovalPageState();
}

class _GuideApprovalPageState extends State<GuideApprovalPage> {
  final AdminService _adminService = AdminService();

  // ✅ 새로고침 핵심: stream을 직접 관리
  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _resetStream();
  }

  void _resetStream() {
    _stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }

  // ✅ 버튼 누를 때 호출 - 스트림 강제 재생성으로 무조건 새로고침
  void _refreshList() {
    setState(() {
      _resetStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text(
          "가이드 관리 센터",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = (snapshot.data ?? [])
              .where((u) => u['guide_status'] != 'none')
              .toList();

          if (users.isEmpty) return const Center(child: Text("내역이 없습니다."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) => _buildUserCard(users[index]),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          user['nickname'] ?? '이름 없음',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "상태: ${user['guide_status']} | ${DateFormat('MM/dd HH:mm').format(DateTime.parse(user['updated_at']))}",
        ),
        trailing: _buildStatusBadge(user['guide_status']),
        onTap: () => _showFullDetail(user),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final color = status == 'approved'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.orange);
    final text = status == 'approved'
        ? "승인됨"
        : (status == 'rejected' ? "거절됨" : "대기중");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFullDetail(Map<String, dynamic> user) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F4F7),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("${user['nickname']} 상세 정보"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoGrid(user),
                const SizedBox(height: 20),
                const Text(
                  "📸 증빙 서류",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // ✅ 이미지 2개 가로로 - 작게 + 안짤리게
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoBox(
                        user['guide_profile_image'],
                        "본인확인",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPhotoBox(
                        user['guide_certification_image'],
                        "자격증",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        context,
                        user['id'],
                        'approved',
                        Colors.blue,
                        "승인하기",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _actionBtn(
                        context,
                        user['id'],
                        'rejected',
                        Colors.orange,
                        "신청거절",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _actionBtn(
                        context,
                        user['id'],
                        'pending',
                        Colors.red,
                        "활동중단",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionBtn(
    BuildContext context,
    String userId,
    String status,
    Color color,
    String label,
  ) {
    return ElevatedButton(
      onPressed: () async {
        await _adminService.updateGuideStatus(userId, status);
        Navigator.pop(context); // ✅ 닫고
        _refreshList(); // ✅ 스트림 강제 재생성 → 무조건 새로고침
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoGrid(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("닉네임", user['nickname']),
          _infoRow("이메일", user['email']),
          _infoRow("나이/성별", "${user['age']}세 / ${user['gender']}"),
          _infoRow("국적/MBTI", "${user['nationality']} / ${user['mbti']}"),
          _infoRow("언어", user['languages']?.join(', ')),
          _infoRow("자기소개", user['bio']),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox(String? path, String label) {
    final url = _adminService.getImageUrl(path);

    return GestureDetector(
      onTap: url.isEmpty ? null : () => _showImageFullScreen(url, label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            // ✅ 고정 높이 120 - 작은 썸네일
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: url.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.no_photography,
                      color: Colors.grey,
                      size: 28,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      // ✅ 작은 박스 안에서 짤리지 않게 contain
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 120,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          const Text(
            "탭하면 확대",
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showImageFullScreen(String url, String label) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 8.0,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 50,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
