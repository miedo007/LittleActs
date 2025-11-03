import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';

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
      appBar: AppBar(
        title: const Text('Love Language Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: CalmBackground(
        decorative: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your partner’s primary love language is…",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(primary, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (sorted.isNotEmpty)
              _PrimaryCard(
                label: sorted.first.key,
                percent: sorted.first.value,
                color: colors[sorted.first.key] ?? cs.primary,
                description: desc[sorted.first.key] ?? '',
              ),
            const SizedBox(height: 16),
            if (sorted.length > 1) ...[
              Text('Other results (locked)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final e in sorted.skip(1))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BlurredRow(
                    label: e.key,
                    percent: e.value,
                    color: colors[e.key] ?? cs.primary,
                  ),
                ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: () {
                if (isPro) {
                  context.goNamed('home');
                } else {
                  context.goNamed('paywall');
                }
              },
              child: Text(isPro ? 'Continue' : 'See full results & weekly gestures'),
            ),
            const SizedBox(height: 8),
            if (!isPro)
              Text(
                'Pricing and trials are examples for now.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: color),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text('$percent%', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
          )
        ]),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35)),
      ]),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.35,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(color: color.withOpacity(0.6)),
            ),
            child: Row(children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                child: Text('$percent%', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
              )
            ]),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock_outline),
            SizedBox(width: 6),
            Text('Subscribe to see'),
          ],
        )
      ],
    );
  }
}
