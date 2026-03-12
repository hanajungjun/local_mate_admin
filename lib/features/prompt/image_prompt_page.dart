import 'package:flutter/material.dart';
import 'package:local_mate_admin/models/image_prompt_model.dart';
import 'package:local_mate_admin/services/image_prompt_service.dart';

class ImagePromptPage extends StatefulWidget {
  const ImagePromptPage({super.key});

  @override
  State<ImagePromptPage> createState() => _ImagePromptPageState();
}

class _ImagePromptPageState extends State<ImagePromptPage> {
  List<ImagePromptModel> prompts = [];
  ImagePromptModel? selected;

  final titleCtrl = TextEditingController();
  final koCtrl = TextEditingController();
  final enCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ImagePromptService.fetchAll();
    setState(() {
      prompts = data;
    });
  }

  void _newPrompt() {
    selected = null;
    titleCtrl.text = '새 이미지 프롬프트';
    koCtrl.clear();
    enCtrl.text = 'A flat illustration...'; // 기본 예시
    setState(() {});
  }

  void _select(ImagePromptModel p) {
    selected = p;
    titleCtrl.text = p.title;
    koCtrl.text = p.contentKo;
    enCtrl.text = p.contentEn;
    setState(() {});
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty) return;

    if (selected == null) {
      await ImagePromptService.add(
        title: titleCtrl.text.trim(),
        ko: koCtrl.text.trim(),
        en: enCtrl.text.trim(),
      );
    } else {
      await ImagePromptService.update(
        ImagePromptModel(
          id: selected!.id,
          title: titleCtrl.text.trim(),
          contentKo: koCtrl.text.trim(),
          contentEn: enCtrl.text.trim(),
          isActive: selected!.isActive,
        ),
      );
    }
    await _load();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('저장되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 📌 좌측 리스트
        SizedBox(
          width: 280,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _newPrompt,
                  icon: const Icon(Icons.add),
                  label: const Text('새 프롬프트'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: prompts.length,
                  itemBuilder: (context, index) {
                    final p = prompts[index];
                    return ListTile(
                      selected: selected?.id == p.id,
                      title: Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: p.isActive
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : null,
                      onTap: () => _select(p),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // ✏️ 우측 에디터 (시원시원하게!)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleCtrl,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: '제목',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                      ),
                      child: const Text('저장하기'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🇰🇷 한글 가이드 (KO)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: koCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '한글 설명을 적으세요...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🇺🇸 이미지 생성 프롬프트 (EN)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: enCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'AI가 읽을 영어 프롬프트를 적으세요...',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
