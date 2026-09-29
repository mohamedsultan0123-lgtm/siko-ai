import 'package:flutter/material.dart';

import 'app.dart';
import 'services/profile_store.dart';
import 'services/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProfileStore.instance.load();
  await ThemeStore.instance.load();
  runApp(const SikoApp());
}
