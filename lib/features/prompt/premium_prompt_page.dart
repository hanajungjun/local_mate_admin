import 'package:flutter/material.dart';

import 'package:local_mate_admin/models/ai_premium_prompt_model.dart';
import 'package:local_mate_admin/services/ai_premium_prompt_service.dart';

class PremiumPromptPage extends StatefulWidget {
  const PremiumPromptPage({super.key});

  @override
  State<PremiumPromptPage> createState() => _PremiumPromptPageState();
}

class _PremiumPromptPageState extends State<PremiumPromptPage> {
  List<AiPremiumPromptModel> prompts = [];
  AiPremiumPromptModel? selected;

  final titleCtrl = TextEditingController();
  final promptCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    promptCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    prompts = await AiPremiumPromptService.fetchAll();
    setState(() {});
  }

  void _newPrompt() {
    selected = null;
    titleCtrl.clear();
    promptCtrl.clear();
    descCtrl.clear();
    setState(() {});
  }

  void _select(AiPremiumPromptModel p) {
    selected = p;
    titleCtrl.text = p.title;
    promptCtrl.text = p.prompt;
    descCtrl.text = p.description ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty || promptCtrl.text.trim().isEmpty) return;

    if (selected == null) {
      await AiPremiumPromptService.add(
        AiPremiumPromptModel(
          title: titleCtrl.text.trim(),
          prompt: promptCtrl.text.trim(),
          description: descCtrl.text.trim().isEmpty
              ? null
              : descCtrl.text.trim(),
          isActive: false, // ❌ 저장 시 활성화 안 함
        ),
      );
    } else {
      await AiPremiumPromptService.update(
        selected!.copyWith(
          title: titleCtrl.text.trim(),
          prompt: promptCtrl.text.trim(),
          description: descCtrl.text.trim().isEmpty
              ? null
              : descCtrl.text.trim(),
        ),
      );
    }

    await _load();
  }

  Future<void> _activateSelected() async {
    if (selected == null) return;
    await AiPremiumPromptService.activateOnlyByKey(selected!.key);
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
                  label: const Text('새 프리미엄 프롬프트'),
                ),
              ),
              Expanded(
                child: ListView(
                  children: prompts.map((p) {
                    return ListTile(
                      title: Text(p.title),
                      trailing: p.isActive
                          ? const Icon(Icons.star, color: Colors.orange)
                          : null,
                      onTap: () => _select(p),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1),

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
                    controller: promptCtrl,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      labelText: '프리미엄 프롬프트',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: '설명 (선택)'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('저장'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _activateSelected,
                        child: const Text('이 프롬프트 적용'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
