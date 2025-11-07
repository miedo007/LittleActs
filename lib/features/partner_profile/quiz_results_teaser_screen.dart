import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/style/palette.dart';

class QuizResultsTeaserScreen extends ConsumerWidget {
  const QuizResultsTeaserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final isPro = ref.watch(premiumProvider);
    final primary = partner?.loveLanguagePrimary ?? 'Love Language';
    final cs = Theme.of(context).colorScheme;

    // Build percentages from stored 0..5 ratings, normalized so all sum ~100
    final ratings = <String, int>{
      'Words of Affirmation': (partner?.wordsOfAffirmation ?? 0).clamp(0, 5),
      'Acts of Service': (partner?.actsOfService ?? 0).clamp(0, 5),
      'Physical Touch': (partner?.physicalTouch ?? 0).clamp(0, 5),
      'Receiving Gifts': (partner?.receivingGifts ?? 0).clamp(0, 5),
      'Quality Time': (partner?.qualityTime ?? 0).clamp(0, 5),
    };
    final total = ratings.values.fold<int>(0, (a, b) => a + b);
    final Map<String, int> percentages = total > 0
        ? {
            for (final e in ratings.entries)
              e.key: ((e.value / total) * 100).round(),
          }
        : {for (final e in ratings.entries) e.key: 0};
    final sorted = percentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    const Map<String, Color> colors = {
      'Words of Affirmation': Color(0xFF6C63FF),
      'Acts of Service': Color(0xFF00B894),
      'Physical Touch': Color(0xFFFF7675),
      'Receiving Gifts': Color(0xFFFDCB6E),
      'Quality Time': Color(0xFF0984E3),
    };
    const Map<String, String> desc = {
      'Words of Affirmation': 'They feel most loved when they hear it. Verbal appreciation, encouragement, and kind words reassure them that they’re valued and seen.',
      'Acts of Service': 'Actions speak louder than words for them. They feel cared for when you make their life easier — through help, effort, or small thoughtful tasks.',
      'Quality Time': 'They feel loved when you give them your full attention. What matters most is being truly present — shared moments mean everything.',
      'Receiving Gifts': 'They feel appreciated when love takes a tangible form. A small, thoughtful gift says “I was thinking of you.”',
      'Physical Touch': 'They feel connected through closeness. Holding hands, a hug, or gentle touch communicates warmth and safety.',
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: CalmBackground(
        decorative: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: Text(
                    'Results Are In!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Primary Love Language',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),
                if (sorted.isNotEmpty)
                  _PrimaryCard(
                    label: sorted.first.key,
                    percent: sorted.first.value,
                    color: colors[sorted.first.key] ?? cs.primary,
                    description: desc[sorted.first.key] ?? '',
                  ),
                const SizedBox(height: 28),
                if (sorted.length > 1) ...[
                  Center(
                    child: Text(
                      'Unlock Your Full Profile & Deeper Insights',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'See how your other love languages stack up\nfor a more complete picture of you.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < sorted.length - 1; i++)
                    _FadeSlideIn(
                      delayMs: 120 + 80 * i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _BlurredRow(
                          label: sorted[i + 1].key,
                          percent: sorted[i + 1].value,
                          color: colors[sorted[i + 1].key] ?? cs.primary,
                        ),
                      ),
                    ),
                ],
              ]
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.button,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            onPressed: () {
              if (isPro) {
                context.goNamed('home');
              } else {
                context.goNamed('paywall');
              }
            },
            child: const Text('Reveal the results'),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  final String description;
  const _PrimaryCard({required this.label, required this.percent, required this.color, required this.description});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    final size = screenW - 64; // leave horizontal padding
    // another ~10% smaller
    final double ringSize = ((size * 0.35).clamp(150.0, 240.0)).toDouble();
    final double stroke = ((ringSize * 0.10).clamp(14.0, 24.0)).toDouble();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: stroke,
                    valueColor: AlwaysStoppedAnimation(color.withOpacity(0.18)),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: (percent.clamp(0, 100)) / 100.0),
                    duration: const Duration(milliseconds: 1300),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: stroke,
                      valueColor: AlwaysStoppedAnimation(color),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35, color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BlurredRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  const _BlurredRow({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: cs.onSurface.withOpacity(0.4)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_outline),
                SizedBox(width: 6),
                Text('Unlock to see'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _FadeSlideIn({required this.child, this.delayMs = 0});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs)).then((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        child: widget.child,
      ),
    );
  }
}
