import 'package:flutter/material.dart';

class AdminSideMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AdminSideMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF111827),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Travel Memoir\nADMIN',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _MenuItem(
            index: 0,
            selectedIndex: selectedIndex,
            icon: Icons.dashboard,
            label: '대시보드',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 1,
            selectedIndex: selectedIndex,
            icon: Icons.auto_awesome,
            label: '가이드 승인화면',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 2,
            selectedIndex: selectedIndex,
            icon: Icons.image,
            label: 'AI 이미지 프롬프트',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 3,
            selectedIndex: selectedIndex,
            icon: Icons.palette,
            label: '스타일 프롬프트',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 4,
            selectedIndex: selectedIndex,
            icon: Icons.photo_album,
            label: 'AI 커버 프롬프트',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 5,
            selectedIndex: selectedIndex,
            icon: Icons.map,
            label: '로그확인',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 6,
            selectedIndex: selectedIndex,
            icon: Icons.map,
            label: '프리미엄 프롬프트',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 7,
            selectedIndex: selectedIndex,
            icon: Icons.touch_app,
            label: '버튼 설정',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 8,
            selectedIndex: selectedIndex,
            icon: Icons.history,
            label: '공지사항',
            onTap: onSelected,
          ),
          _MenuItem(
            index: 9,
            selectedIndex: selectedIndex,
            icon: Icons.settings,
            label: '설정',
            onTap: onSelected,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  const _MenuItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? Colors.white12 : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
