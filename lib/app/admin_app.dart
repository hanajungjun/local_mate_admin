import 'package:flutter/material.dart';
import 'package:local_mate_admin/features/auth/admin_auth_gate.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminAuthGate(), // 🔐 절대 바꾸지 마
    );
  }
}
