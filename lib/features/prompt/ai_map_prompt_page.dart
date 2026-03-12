import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AppLogPage extends StatefulWidget {
  const AppLogPage({super.key});

  @override
  State<AppLogPage> createState() => _AppLogPageState();
}

class _AppLogPageState extends State<AppLogPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  String _searchQuery = "";
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _clearAllLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 로그 전체 소탕'),
        content: const Text('DB의 모든 로그를 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase
            .from('app_logs')
            .delete()
            .neq('id', '00000000-0000-0000-0000-000000000000');
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ 로그 삭제 완료')));
      } catch (e) {
        debugPrint('삭제 실패: $e');
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startDate = picked;
        else
          _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('시스템 로그 센터'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _clearAllLogs, icon: const Icon(Icons.delete_sweep)),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: const Color(0xFF2C3E50),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '태그 또는 메시지 검색...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _dateBtn(_startDate, 'From', () => _pickDate(true)),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child:
                            Text('~', style: TextStyle(color: Colors.white))),
                    _dateBtn(_endDate, 'To', () => _pickDate(false)),
                    const SizedBox(width: 8),
                    if (_startDate != null || _endDate != null)
                      IconButton(
                        onPressed: () => setState(() {
                          _startDate = null;
                          _endDate = null;
                        }),
                        icon: const Icon(Icons.refresh,
                            color: Colors.yellow, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase.from('app_logs').stream(
                  primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final logs = snapshot.data!.where((log) {
                  final msg = (log['message'] ?? '').toString().toLowerCase();
                  final tag = (log['tag'] ?? '').toString().toLowerCase();
                  // 🎯 여기서 한국 시간으로 변환해서 필터링
                  final createdAt = DateTime.parse(log['created_at']).toLocal();
                  final logDate =
                      DateTime(createdAt.year, createdAt.month, createdAt.day);

                  bool matchesSearch =
                      msg.contains(_searchQuery) || tag.contains(_searchQuery);
                  bool matchesDate = true;
                  if (_startDate != null)
                    matchesDate &= !logDate.isBefore(_startDate!);
                  if (_endDate != null)
                    matchesDate &= !logDate.isAfter(_endDate!);

                  return matchesSearch && matchesDate;
                }).toList();

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final level = log['level'] ?? 'info';
                    final color = level == 'error'
                        ? Colors.red
                        : (level == 'warn' ? Colors.orange : Colors.blue);

                    // 🎯 [핵심 수정] UTC 시간을 한국 시간으로 변환 후 포맷팅
                    final DateTime logDateTime =
                        DateTime.parse(log['created_at'].toString()).toLocal();
                    final String timeStr =
                        DateFormat('HH:mm:ss').format(logDateTime);
                    final String fullDateStr =
                        DateFormat('yyyy.MM.dd HH:mm:ss').format(logDateTime);

                    return Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        backgroundColor: Colors.white,
                        collapsedBackgroundColor: Colors.white,
                        leading: Container(
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(level.toString().toUpperCase(),
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10)),
                        ),
                        title: Text(log['message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                        // 🎯 subtitle에 한국 시간 적용
                        subtitle: Text('${log['tag']} | $timeStr',
                            style: const TextStyle(fontSize: 11)),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🎯 상세 보기 안에 전체 날짜/시간 표시 추가
                                Text('발생 시각: $fullDateStr',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold)),
                                const Divider(height: 20),
                                SelectableText(log['message'] ?? '',
                                    style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBtn(DateTime? date, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Text(
            date == null ? label : DateFormat('yyyy.MM.dd').format(date),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: date == null ? Colors.white54 : Colors.white,
                fontSize: 12),
          ),
        ),
      ),
    );
  }
}
