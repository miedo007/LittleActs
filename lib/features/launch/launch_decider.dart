import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/constants/storage_keys.dart';

class LaunchDeciderScreen extends StatefulWidget {
  const LaunchDeciderScreen({super.key});

  @override
  State<LaunchDeciderScreen> createState() => _LaunchDeciderScreenState();
}

class _LaunchDeciderScreenState extends State<LaunchDeciderScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('has_completed_setup') ?? false;
    final isPremium =
        prefs.getBool(PremiumNotifier.entitlementPrefsKey) ?? false;
    final softUnlocked = prefs.getBool(StorageKeys.paywallSoftUnlock) ?? false;
    if (!mounted) return;
    if (!done) {
      context.goNamed('onboarding');
      return;
    }
    if (!isPremium && !softUnlocked) {
      context.goNamed('paywall');
      return;
    }
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
