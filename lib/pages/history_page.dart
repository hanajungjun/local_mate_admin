import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    final data =
        await _supabase.from('notices').select().order('id', ascending: false);
    setState(() {
      _notices = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  // 🎯 공지 추가/수정 통합 다이얼로그 (사이즈 UP!)
  void _showNoticeForm({Map<String, dynamic>? notice}) {
    final isEdit = notice != null;
    final titleKo = TextEditingController(text: notice?['title']);
    final contentKo = TextEditingController(text: notice?['content']);
    final titleEn = TextEditingController(text: notice?['title_en']);
    final contentEn = TextEditingController(text: notice?['content_en']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isEdit ? '공지사항 수정' : '새 공지사항 등록',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width:
              MediaQuery.of(context).size.width * 0.8, // 👈 화면의 80% 차지 (시원하게!)
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("🇰🇷 한국어 (KOREAN)"),
                _buildTextField(titleKo, "제목을 입력하세요"),
                _buildTextField(contentKo, "내용을 입력하세요 (\\n으로 줄바꿈)",
                    isContent: true),
                const SizedBox(height: 24),
                _buildSectionTitle("🇺🇸 영어 (ENGLISH)"),
                _buildTextField(titleEn, "Enter title in English"),
                _buildTextField(contentEn, "Enter content in English",
                    isContent: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () async {
              final data = {
                'title': titleKo.text,
                'content': contentKo.text,
                'title_en': titleEn.text,
                'content_en': contentEn.text,
                'is_active': notice?['is_active'] ?? true,
              };

              if (isEdit) {
                await _supabase
                    .from('notices')
                    .update(data)
                    .eq('id', notice['id']);
              } else {
                await _supabase.from('notices').insert(data);
              }
              if (mounted) Navigator.pop(context);
              _fetchNotices();
            },
            child: Text(isEdit ? '수정완료' : '등록하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isContent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: isContent ? 8 : 1, // 👈 내용 입력창 8줄로 팍팍!
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('공지사항 ADMIN',
            style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showNoticeForm(),
              icon: const Icon(Icons.add),
              label: const Text("공지 추가"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notices.length,
              itemBuilder: (context, index) {
                final notice = _notices[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(notice['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(notice['content'] ?? '',
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: notice['is_active'] ?? false,
                          onChanged: (val) async {
                            await _supabase.from('notices').update(
                                {'is_active': val}).eq('id', notice['id']);
                            _fetchNotices();
                          },
                        ),
                        IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showNoticeForm(notice: notice)),
                        IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () async {
                              await _supabase
                                  .from('notices')
                                  .delete()
                                  .eq('id', notice['id']);
                              _fetchNotices();
                            }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
