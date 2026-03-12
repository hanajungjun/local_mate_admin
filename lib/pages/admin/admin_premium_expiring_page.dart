import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPremiumExpiringPage extends StatefulWidget {
  const AdminPremiumExpiringPage({super.key});

  @override
  State<AdminPremiumExpiringPage> createState() =>
      _AdminPremiumExpiringPageState();
}

class _AdminPremiumExpiringPageState extends State<AdminPremiumExpiringPage> {
  final SupabaseClient _client = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadExpiringUsers();
  }

  Future<List<Map<String, dynamic>>> _loadExpiringUsers() async {
    final nowPlus7 =
        DateTime.now().add(const Duration(days: 7)).toIso8601String();

    final data = await _client
        .from('users')
        .select('id, email, nickname, premium_until')
        .eq('is_premium', true)
        .not('premium_until', 'is', null) // ✅ 핵심
        .lte('premium_until', nowPlus7)
        .order('premium_until');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _sendNotice(Map<String, dynamic> user) async {
    // 🔥 나중에 Supabase Edge Function으로 교체
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user['nickname'] ?? user['email']} 에게 만료 알림 전송',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('만료 예정 프리미엄')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('만료 예정 유저가 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              final until = DateTime.parse(u['premium_until']);

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.timer, color: Colors.red),
                  title: Text(
                    u['nickname'] ?? u['email'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '만료일: ${until.toLocal().toString().substring(0, 16)}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _sendNotice(u),
                    child: const Text('알림 보내기'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
