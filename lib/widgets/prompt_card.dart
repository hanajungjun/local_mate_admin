import 'package:flutter/material.dart';
import 'package:local_mate_admin/models/prompt_model.dart';

class PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final ValueChanged<bool?> onToggle; // 모델 구조에 맞춰 bool?로 대응하거나 bool로 강제
  final VoidCallback onEdit;

  const PromptCard({
    super.key,
    required this.prompt,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prompt.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 활성화 스위치
              Switch(value: prompt.isActive, onChanged: onToggle),
              // 수정 버튼
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                onPressed: onEdit,
              ),
            ],
          ),
          const Divider(height: 20), // 구분선 추가
          // --- 한글 프롬프트 영역 ---
          const Row(
            children: [
              Icon(Icons.language, size: 14, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                'KO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            prompt.contentKo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),

          const SizedBox(height: 12),

          // --- 영어 프롬프트 영역 ---
          const Row(
            children: [
              Icon(Icons.language, size: 14, color: Colors.orange),
              SizedBox(width: 4),
              Text(
                'EN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            prompt.contentEn,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
