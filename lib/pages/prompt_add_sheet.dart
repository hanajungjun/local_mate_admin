import 'package:flutter/material.dart';
import 'package:local_mate_admin/models/prompt_model.dart';

class PromptAddSheet extends StatefulWidget {
  final PromptModel? initialPrompt;
  final Function(PromptModel) onSubmit;

  const PromptAddSheet({super.key, this.initialPrompt, required this.onSubmit});

  @override
  State<PromptAddSheet> createState() => _PromptAddSheetState();
}

class _PromptAddSheetState extends State<PromptAddSheet> {
  late TextEditingController _titleController;
  late TextEditingController _koController;
  late TextEditingController _enController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialPrompt?.title ?? '',
    );
    _koController = TextEditingController(
      text: widget.initialPrompt?.contentKo ?? '',
    );
    _enController = TextEditingController(
      text: widget.initialPrompt?.contentEn ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _koController.dispose();
    _enController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // 🔥 1. 기본 padding을 0으로 날려서 화면 끝까지 쓸 수 있게 합니다.
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        // 🔥 2. 가로 너비를 화면의 95%로 강제 고정합니다.
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // 헤더 영역
            Row(
              children: [
                const Icon(Icons.edit_note, size: 32, color: Colors.amber),
                const SizedBox(width: 12),
                Text(
                  widget.initialPrompt == null ? '프롬프트 생성' : '프롬프트 수정',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 32),
                ),
              ],
            ),
            const Divider(height: 40, thickness: 1.2),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 제목 영역 (가로 꽉 채움) ---
                    const Text(
                      '프롬프트 제목',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- 🇰🇷 한글 프롬프트 (가로로 아주 길게) ---
                    const Row(
                      children: [
                        Icon(Icons.language, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '한글 프롬프트 (KO)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _koController,
                      maxLines: 12, // 한글 영역 넉넉하게
                      style: const TextStyle(fontSize: 17, height: 1.6),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '한글 지시문을 가로로 길게 작성하세요...',
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- 🇺🇸 영어 프롬프트 (한글 아래에 똑같이 꽉!) ---
                    const Row(
                      children: [
                        Icon(Icons.language, color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '영어 프롬프트 (EN)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _enController,
                      maxLines: 12, // 영어 영역도 넉넉하게
                      style: const TextStyle(fontSize: 17, height: 1.6),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter English instructions here...',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 40),

            // 하단 버튼 레이아웃
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('취소', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    final prompt = PromptModel(
                      id: widget.initialPrompt?.id ?? '',
                      title: _titleController.text,
                      contentKo: _koController.text,
                      contentEn: _enController.text,
                      isActive: widget.initialPrompt?.isActive ?? false,
                    );
                    widget.onSubmit(prompt);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '저장하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
