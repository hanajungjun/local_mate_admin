import 'package:flutter/material.dart';

import 'package:local_mate_admin/widgets/admin_scaffold.dart';

import 'package:local_mate_admin/features/dashboard/admin_dashboard_page.dart';
import 'package:local_mate_admin/pages/guide_approval_page.dart';

import 'package:local_mate_admin/features/prompt/image_prompt_page.dart';
import 'package:local_mate_admin/features/style/style_page.dart';
import 'package:local_mate_admin/features/prompt/ai_cover_prompt_page.dart';
import 'package:local_mate_admin/features/prompt/ai_map_prompt_page.dart';
import 'package:local_mate_admin/features/button/button_config_page.dart';
import 'package:local_mate_admin/features/history/history_page.dart';
import 'package:local_mate_admin/features/settings/admin_settings_page.dart';
import 'package:local_mate_admin/features/prompt/premium_prompt_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    AdminDashboardPage(), // 0
    GuideApprovalPage(), // 1 가이드 승인화면
    ImagePromptPage(), // 2 AI 이미지 프롬프트
    StylePage(), // 3 스타일 프롬프트
    AiCoverPromptPage(), // 4 AI 커버 프롬프트
    AppLogPage(), // 5 로그확인
    PremiumPromptPage(), // 6.프리미엄 프롬프트
    ButtonConfigPage(), // 7 버튼 설정
    HistoryPage(), // 8 공지사항
    AdminSettingsPage(), // 9 설정
  ];

  final _titles = const [
    '대시보드',
    '가이드 승인화면',
    'AI 이미지 프롬프트(이미지 요약 프롬프트)',
    '스타일 프롬프트',
    'AI 커버 프롬프트',
    '로그확인',
    '프리미엄 프롬프트',
    '버튼 설정',
    '공지사항',
    '설정',
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _titles[_index],
      body: _pages[_index],
      selectedIndex: _index,
      onMenuSelected: (i) {
        setState(() => _index = i);
      },
    );
  }
}
