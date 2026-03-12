import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_mate_admin/models/image_style_model.dart';
import 'package:local_mate_admin/services/image_style_service.dart';
import 'package:local_mate_admin/storage_urls.dart';

class ImageStylePage extends StatefulWidget {
  const ImageStylePage({super.key});

  @override
  State<ImageStylePage> createState() => _ImageStylePageState();
}

class _ImageStylePageState extends State<ImageStylePage> {
  List<ImageStyleModel> _styles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _styles = await ImageStyleService.fetchAll();
    setState(() => _loading = false);
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _styles.removeAt(oldIndex);
      _styles.insert(newIndex, item);
    });

    try {
      await ImageStyleService.updateOrder(_styles);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('순서 저장 실패: $e')));
    }
  }

  // ✅ 썸네일 표시 공통 위젯 (슈파베이스 주소 변환 적용)
  Widget _buildThumbnail(
    String? url, {
    double size = 56,
    bool useCacheBurst = false,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: Icon(Icons.image, size: size / 2, color: Colors.grey),
      );
    }

    // ✅ [수정] 이미 전체 URL(http)인 경우 그대로 사용, 아니면 가공
    String finalUrl = url.startsWith('http')
        ? url
        : StorageUrls.systemImage(url);

    if (useCacheBurst) {
      finalUrl +=
          (finalUrl.contains('?') ? '&' : '?') +
          "v=${DateTime.now().millisecondsSinceEpoch}";
    }

    return Image.network(
      finalUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: size,
          height: size,
          color: Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.broken_image, size: size / 2, color: Colors.grey),
    );
  }

  Future<void> _openEditor({ImageStyleModel? style}) async {
    final titleCtrl = TextEditingController(text: style?.title ?? '');
    final titleEnCtrl = TextEditingController(text: style?.titleEn ?? '');
    final promptCtrl = TextEditingController(text: style?.prompt ?? '');

    bool isPremium = style?.isPremium ?? false;
    Uint8List? pickedImageBytes;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(style == null ? '스타일 추가' : '스타일 수정'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: '스타일 이름 (한글)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleEnCtrl,
                    decoration: const InputDecoration(labelText: '스타일 이름 (영어)'),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('프리미엄 전용 스타일'),
                    value: isPremium,
                    onChanged: (v) =>
                        setModalState(() => isPremium = v ?? false),
                  ),
                  const SizedBox(height: 16),
                  Text('썸네일', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: pickedImageBytes != null
                          ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                          : _buildThumbnail(
                              style?.thumbnailUrl,
                              size: 140,
                              useCacheBurst: true,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('썸네일 선택'),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null) {
                        final bytes = await file.readAsBytes();
                        setModalState(() => pickedImageBytes = bytes);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: promptCtrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: '이미지 프롬프트',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;

    if (style == null) {
      await ImageStyleService.add(
        title: titleCtrl.text,
        titleEn: titleEnCtrl.text,
        prompt: promptCtrl.text,
        isPremium: isPremium,
      );
    } else {
      String? thumbnailUrl = style.thumbnailUrl;
      if (pickedImageBytes != null) {
        thumbnailUrl = await ImageStyleService.uploadThumbnail(
          styleId: style.id,
          imageBytes: pickedImageBytes!,
          oldUrl: style.thumbnailUrl,
        );
      }
      await ImageStyleService.update(
        style.copyWith(
          title: titleCtrl.text,
          titleEn: titleEnCtrl.text,
          prompt: promptCtrl.text,
          thumbnailUrl: thumbnailUrl,
          isPremium: isPremium,
        ),
      );
    }
    await _load();
  }

  Future<void> _toggle(ImageStyleModel style, bool enabled) async {
    await ImageStyleService.setEnabled(style.id, enabled);
    await _load();
  }

  Future<void> _confirmDelete(ImageStyleModel style) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('스타일 삭제'),
        content: const Text('이 스타일을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ImageStyleService.delete(style);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '이미지 스타일 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('스타일 추가'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              itemCount: _styles.length,
              onReorder: _onReorder,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, i) {
                final style = _styles[i];
                return Column(
                  key: ValueKey(style.id),
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_indicator, color: Colors.grey),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _buildThumbnail(style.thumbnailUrl),
                          ),
                        ],
                      ),
                      title: Text(
                        '${style.title} (${style.titleEn})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: style.isPremium
                          ? Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: style.isEnabled,
                            onChanged: (v) => _toggle(style, v),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => _openEditor(style: style),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _confirmDelete(style),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 80),
                  ],
                );
              },
            ),
    );
  }
}
