import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/App/router.dart';
import 'package:nudge/App/theme.dart';
import 'package:nudge/shared/Services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const ProviderScope(child: NudgeApp()));
}

class NudgeApp extends StatelessWidget {
  const NudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nudge',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => child!,
      debugShowCheckedModeBanner: false,
    );
  }
}
