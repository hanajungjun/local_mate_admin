import 'package:flutter/material.dart';
import 'package:local_mate_admin/widgets/admin_side_menu.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final int selectedIndex;
  final void Function(int) onMenuSelected;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.selectedIndex,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Row(
          children: [
            AdminSideMenu(
              selectedIndex: selectedIndex,
              onSelected: onMenuSelected, // ✅ 여기만 바뀜
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
