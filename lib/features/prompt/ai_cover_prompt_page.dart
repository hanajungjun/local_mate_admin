import 'package:flutter/material.dart';
import 'package:local_mate_admin/models/ai_cover_map_prompt_model.dart';
import 'package:local_mate_admin/services/ai_cover_map_prompt_service.dart';

class AiCoverPromptPage extends StatefulWidget {
  const AiCoverPromptPage({super.key});

  @override
  State<AiCoverPromptPage> createState() => _AiCoverPromptPageState();
}

class _AiCoverPromptPageState extends State<AiCoverPromptPage> {
  List<AiCoverMapPromptModel> prompts = [];
  AiCoverMapPromptModel? selected;

  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    prompts = await AiCoverMapPromptService.fetchByType('cover');
    setState(() {});
  }

  void _newPrompt() {
    selected = null;
    titleCtrl.text = '';
    contentCtrl.text = '';
    setState(() {});
  }

  void _select(AiCoverMapPromptModel p) {
    selected = p;
    titleCtrl.text = p.title;
    contentCtrl.text = p.content;
    setState(() {});
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) {
      return;
    }

    if (selected == null) {
      await AiCoverMapPromptService.add(
        type: 'cover',
        title: titleCtrl.text,
        content: contentCtrl.text,
      );
    } else {
      await AiCoverMapPromptService.update(
        AiCoverMapPromptModel(
          id: selected!.id,
          type: 'cover',
          title: titleCtrl.text,
          content: contentCtrl.text,
          isActive: true,
        ),
      );
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 좌측 리스트
        SizedBox(
          width: 260,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  onPressed: _newPrompt,
                  icon: const Icon(Icons.add),
                  label: const Text('새 커버 프롬프트'),
                ),
              ),
              Expanded(
                child: ListView(
                  children: prompts.map((p) {
                    return ListTile(
                      title: Text(p.title),
                      trailing: p.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () => _select(p),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(),

        // 우측 에디터
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: contentCtrl,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      labelText: '커버 이미지 프롬프트',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _save, child: const Text('저장 및 활성화')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
