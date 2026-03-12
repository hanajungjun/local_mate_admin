import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPhotoListPage extends StatefulWidget {
  const AdminPhotoListPage({super.key});

  @override
  State<AdminPhotoListPage> createState() => _AdminPhotoListPageState();
}

class _AdminPhotoListPageState extends State<AdminPhotoListPage> {
  final SupabaseClient _client = Supabase.instance.client;

  late Future<List<String>> _photoUrlsFuture;

  @override
  void initState() {
    super.initState();
    _photoUrlsFuture = _loadAllPhotoUrls();
  }

  // =========================================================
  // 🔥 [핵심 수정] RLS 우회용 RPC 기반 사진 URL 로드
  // =========================================================
  Future<List<String>> _loadAllPhotoUrls() async {
    final result = await _client.rpc('admin_all_uploaded_photo_urls');

    if (result == null) return [];

    return List<String>.from(result);
  }
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('업로드된 사진 목록'),
      ),
      body: FutureBuilder<List<String>>(
        future: _photoUrlsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('업로드된 사진이 없습니다.'));
          }

          final photos = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 20,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return _PhotoTile(
                imageUrl: photos[index],
                onTap: () => _openPreview(context, photos[index]),
              );
            },
          );
        },
      ),
    );
  }

  void _openPreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
