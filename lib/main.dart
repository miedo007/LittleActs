import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/App/router.dart';
import 'package:nudge/App/theme.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Defer notifications init to after first frame to avoid startup jank
  runApp(const ProviderScope(child: NudgeApp()));
}

class NudgeApp extends StatelessWidget {
  const NudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Little Acts',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => _AppWarmup(child: child!),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppWarmup extends ConsumerStatefulWidget {
  final Widget child;
  const _AppWarmup({required this.child});
  @override
  ConsumerState<_AppWarmup> createState() => _AppWarmupState();
}

class _AppWarmupState extends ConsumerState<_AppWarmup> {
  bool _started = false;
  @override
  void initState() {
    super.initState();
    // Pre-initialize providers and SharedPreferences after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _started) return;
      _started = true;
      // Touch providers to lazily initialize and load data off the UI isolate
      // so navigation later doesn't incur jank.
      ref.read(partnerProvider);
      ref.read(milestonesProvider);
      ref.read(weeklyGesturesProvider);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
