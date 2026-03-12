import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPremiumUserListPage extends StatefulWidget {
  const AdminPremiumUserListPage({super.key});

  @override
  State<AdminPremiumUserListPage> createState() =>
      _AdminPremiumUserListPageState();
}

class _AdminPremiumUserListPageState extends State<AdminPremiumUserListPage> {
  final SupabaseClient _client = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadPremiumUsers();
  }

  Future<List<Map<String, dynamic>>> _loadPremiumUsers() async {
    final data = await _client
        .from('users')
        .select(
          'id, email, nickname, provider, premium_until, created_at',
        )
        .eq('is_premium', true)
        .order('premium_until', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프리미엄 유저 목록')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('프리미엄 유저가 없습니다.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final u = users[index];
              final DateTime? until = u['premium_until'] != null
                  ? DateTime.parse(u['premium_until'])
                  : null;

              return ListTile(
                leading:
                    const Icon(Icons.workspace_premium, color: Colors.amber),
                title: Text(
                  u['nickname'] ?? u['email'] ?? '알 수 없음',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Provider: ${u['provider'] ?? '-'}\n'
                  '만료일: ${until != null ? until.toLocal().toString().substring(0, 16) : '-'}',
                ),
                trailing: until != null &&
                        until.isBefore(
                            DateTime.now().add(const Duration(days: 7)))
                    ? const Chip(
                        label: Text('만료 임박'),
                        backgroundColor: Colors.redAccent,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
