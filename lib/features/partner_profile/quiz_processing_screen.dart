import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/style/palette.dart';

class QuizProcessingScreen extends ConsumerStatefulWidget {
  const QuizProcessingScreen({super.key});

  @override
  ConsumerState<QuizProcessingScreen> createState() => _QuizProcessingScreenState();
}

class _QuizProcessingScreenState extends ConsumerState<QuizProcessingScreen> {
  final List<Timer> _timers = [];
  int _visibleLines = 0;

  static const _lineDelays = [
    Duration(milliseconds: 300),
    Duration(milliseconds: 1700),
    Duration(milliseconds: 3100),
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _lineDelays.length; i++) {
      _timers.add(Timer(_lineDelays[i], () {
        if (!mounted) return;
        setState(() => _visibleLines = i + 1);
      }));
    }
    _timers.add(Timer(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      context.goNamed('quizTeaser');
    }));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partner = ref.watch(partnerProvider);
    final name = (partner?.name ?? '').trim();
    final titleName = name.isEmpty ? 'your partner' : name;
    final steps = const [
      'Analyzing your answers',
      'Finding the gestures that mean the most',
      'Almost ready',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: CalmBackground(
        decorative: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Learning what makes $titleName feel loved…',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.title),
                ),
                const SizedBox(height: 24),
                for (int i = 0; i < steps.length; i++)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _visibleLines >= i + 1 ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: _visibleLines >= i + 1
                                ? const CircularProgressIndicator(strokeWidth: 2, color: AppColors.icon)
                                : const SizedBox.shrink(),
                          ),
                          if (_visibleLines >= i + 1) const SizedBox(width: 8),
                          Text(
                            steps[i],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.bodyMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
