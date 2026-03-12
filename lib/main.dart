import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';
import 'app/admin_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  runApp(const AdminApp());
}
