import 'package:espetosystem/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://ccdrjqtyepypmwhdillk.supabase.co',
    anonKey: 'sb_secret_6Kz6OGV8dTcoQRygqpzfug_5yMZmsCb',
  );
  runApp(const MyApp());
}
