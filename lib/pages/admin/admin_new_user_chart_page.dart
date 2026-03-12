import 'package:flutter/material.dart';
import 'package:local_mate_admin/services/admin_dashboard_service.dart';

class AdminNewUserChartPage extends StatefulWidget {
  const AdminNewUserChartPage({super.key});

  @override
  State<AdminNewUserChartPage> createState() => _AdminNewUserChartPageState();
}

class _AdminNewUserChartPageState extends State<AdminNewUserChartPage> {
  final AdminDashboardService _service = AdminDashboardService();

  late Future<List<Map<String, dynamic>>> _chartFuture;

  @override
  void initState() {
    super.initState();
    _chartFuture = _service.getNewUsersLast7Days();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('최근 7일 가입자 수')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chartFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final maxValue = data
              .map((e) => e['user_count'] as int)
              .fold<int>(1, (a, b) => a > b ? a : b);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((e) {
                final int count = e['user_count'] ?? 0;
                final String day = e['day'].toString().substring(5); // MM-DD

                final double height = (count / maxValue) * 160 + 10;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        count.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: height,
                        width: 22,
                        decoration: BoxDecoration(
                          color: Colors.blue, // 👈 가입자 컬러
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
