import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (!mounted) return;
    if (done) {
      context.goNamed('home');
    } else {
      context.goNamed('onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

