import 'package:flutter/material.dart';
import 'package:local_mate_admin/features/auth/admin_login_page.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Memoir Admin',
      home: AdminLoginPage(), // ✅ 바로 로그인 페이지
    );
  }
}
