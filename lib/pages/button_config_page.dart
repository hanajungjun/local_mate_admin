import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ButtonConfigPage extends StatefulWidget {
  const ButtonConfigPage({super.key});

  @override
  State<ButtonConfigPage> createState() => _ButtonConfigPageState();
}

class _ButtonConfigPageState extends State<ButtonConfigPage> {
  final _supabase = Supabase.instance.client;

  // ============================
  // Push
  // ============================
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tokenController = TextEditingController();

  String _targetType = 'topic';
  String _selectedTopic = 'all_users';
  bool _isSendingPush = false;

  // ============================
  // Utils
  // ============================
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프롬프트가 클립보드에 복사되었습니다!')),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ============================
  // Push Logic
  // ============================
  Future<void> _sendPushNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      _showErrorSnackBar('제목과 내용을 입력해주세요.');
      return;
    }

    setState(() => _isSendingPush = true);

    try {
      final response = await _supabase.functions.invoke(
        'send-push',
        body: {
          'title': _titleController.text.trim(),
          'body': _bodyController.text.trim(),
          'targetType': _targetType,
          'targetValue':
              _targetType == 'topic' ? _selectedTopic : _tokenController.text,
        },
      );

      if (response.status == 200 || response.status == 201) {
        _showSuccessDialog('전송 완료', '푸시 알림이 성공적으로 전송되었습니다.');
      } else {
        throw 'push failed';
      }
    } catch (e) {
      _showErrorSnackBar('푸시 에러: $e');
    } finally {
      if (mounted) setState(() => _isSendingPush = false);
    }
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 1, child: _buildPushSection()),
          const VerticalDivider(
              width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          Expanded(flex: 1, child: _buildPassportAdminSection()),
          const VerticalDivider(
              width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          Expanded(flex: 1, child: _buildPromptTemplateSection()),
        ],
      ),
    );
  }

  // ============================
  // Sections
  // ============================
  Widget _buildPushSection() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.campaign, '푸시 알림 관리', Colors.blueAccent),
            const SizedBox(height: 35),
            _buildLabel('발송 방식'),
            Row(
              children: [
                _buildSelectButton(
                  '그룹(토픽)',
                  _targetType == 'topic',
                  () => setState(() => _targetType = 'topic'),
                ),
                const SizedBox(width: 10),
                _buildSelectButton(
                  '개별(토큰)',
                  _targetType == 'token',
                  () => setState(() => _targetType = 'token'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_targetType == 'topic') ...[
              _buildLabel('대상 토픽 선택'),
              Wrap(
                spacing: 10,
                children: [
                  _buildTopicChip('전체 공지', 'all_users'),
                  _buildTopicChip('마케팅 정보', 'marketing'),
                ],
              ),
            ] else ...[
              _buildLabel('FCM 토큰 입력'),
              TextField(
                controller: _tokenController,
                decoration: _inputDecoration('상대방의 FCM 토큰 입력'),
              ),
            ],
            const SizedBox(height: 35),
            const Divider(),
            const SizedBox(height: 35),
            _buildLabel('알림 제목'),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('제목 입력'),
            ),
            const SizedBox(height: 25),
            _buildLabel('알림 본문'),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: _inputDecoration('본문 내용 입력'),
            ),
            const SizedBox(height: 45),
            _buildActionButton(
              '푸시 알림 즉시 전송',
              Colors.blueAccent,
              _isSendingPush,
              _sendPushNotification,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportAdminSection() {
    return Container();
  }

  Widget _buildPromptTemplateSection() {
    return Container();
  }

  // ============================
  // Components
  // ============================
  Widget _buildTemplateCard(String title, String prompt, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => _copyToClipboard(prompt),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prompt,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(18),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    bool isLoading,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSelectButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : const Color(0xFFE5E7EB),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label, String value) {
    final isSelected = _selectedTopic == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTopic = value),
      selectedColor: Colors.blueAccent.withOpacity(0.1),
      checkmarkColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blueAccent : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
