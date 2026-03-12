import 'package:flutter/material.dart';

import 'package:local_mate_admin/widgets/admin_scaffold.dart';

// 기존 페이지들
import 'package:local_mate_admin/pages/admin_dashboard_page.dart';
import 'package:local_mate_admin/pages/guide_approval_page.dart';
import 'package:local_mate_admin/features/prompt/image_prompt_page.dart';
import 'package:local_mate_admin/pages/image_style_page.dart';
import 'package:local_mate_admin/pages/button_config_page.dart';
import 'package:local_mate_admin/pages/history_page.dart';
import 'package:local_mate_admin/features/prompt/ai_cover_prompt_page.dart';
import 'package:local_mate_admin/features/prompt/ai_map_prompt_page.dart';
import 'package:local_mate_admin/features/prompt/premium_prompt_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  /// ⚠️ AdminSideMenu index 와 반드시 동일한 순서
  late final List<_AdminPage> _pages = [
    _AdminPage(title: '대시보드', body: const AdminDashboardPage()), // 0

    _AdminPage(title: '가이드 승인화면', body: const GuideApprovalPage()), // 1

    _AdminPage(
      title: 'AI 이미지 프롬프트',
      body: ImagePromptPage(), // const ❌
    ), // 2

    _AdminPage(title: '스타일 프롬프트', body: const ImageStylePage()), // 3

    _AdminPage(title: 'AI 커버 프롬프트', body: const AiCoverPromptPage()), // 4

    _AdminPage(title: '로그확인', body: const AppLogPage()), // 5

    _AdminPage(title: '프리미엄 프롬프트', body: const PremiumPromptPage()), // 6

    _AdminPage(title: '버튼 설정', body: const ButtonConfigPage()), // 7

    _AdminPage(title: '공지사항', body: const HistoryPage()), // 8

    _AdminPage(title: '설정', body: const _SettingsPlaceholderPage()), // 9
  ];

  @override
  Widget build(BuildContext context) {
    final current = _pages[_selectedIndex];

    return AdminScaffold(
      title: current.title,
      body: current.body,
      selectedIndex: _selectedIndex,
      onMenuSelected: (index) {
        setState(() => _selectedIndex = index);
      },
    );
  }
}

class _AdminPage {
  final String title;
  final Widget body;

  const _AdminPage({required this.title, required this.body});
}

/// 임시 설정 페이지 (에러 방지용)
class _SettingsPlaceholderPage extends StatelessWidget {
  const _SettingsPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('설정 페이지 연결 예정'));
  }
}
