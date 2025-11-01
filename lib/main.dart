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
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
        final colors = Theme.of(context).colorScheme;
        final start = isDark ? const Color(0xFF0B1220) : const Color(0xFF153759);
        final end = isDark
            ? Color.alphaBlend(colors.primary.withValues(alpha: 0.20), const Color(0xFF0A101A))
            : Color.alphaBlend(colors.primary.withValues(alpha: 0.15), const Color(0xFF0E2B49));
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [start, end],
            ),
          ),
          child: child,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
