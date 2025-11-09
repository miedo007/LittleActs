import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/style/palette.dart';
import 'package:nudge/shared/widgets/premium_lock_card.dart';

class ProfileInsightsScreen extends ConsumerWidget {
  const ProfileInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final cs = Theme.of(context).colorScheme;
    final isPremium = ref.watch(premiumProvider);

    final entries = <_LangInfo>[
      _LangInfo('Words of Affirmation', partner?.wordsOfAffirmation ?? 0, const Color(0xFF6C63FF),
          'They feel most loved when they hear it. Thoughtful compliments, appreciation, and encouragement matter.'),
      _LangInfo('Acts of Service', partner?.actsOfService ?? 0, const Color(0xFF00B894),
          'Actions speak louder than words. Helpful tasks and small efforts reduce friction in their day.'),
      _LangInfo('Physical Touch', partner?.physicalTouch ?? 0, const Color(0xFFFF7675),
          'Warm closeness—hugs, holding hands, or a gentle shoulder touch—communicates comfort and care.'),
      _LangInfo('Receiving Gifts', partner?.receivingGifts ?? 0, const Color(0xFFFDCB6E),
          'Tangible tokens of care, big or small, say “I thought of you.” The meaning is in the thoughtfulness.'),
      _LangInfo('Quality Time', partner?.qualityTime ?? 0, const Color(0xFF0984E3),
          'Focused presence and shared moments—without distractions—help them feel deeply connected.'),
    ];

    final total = entries.fold<int>(0, (a, e) => a + e.score.clamp(0, 5));
    final withPct = entries
        .map((e) => e.copyWith(percent: total == 0 ? 0 : ((e.score.clamp(0, 5) / total) * 100).round()))
        .toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: CalmBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      'Profile Insights',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
          if (partner != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(partner.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    if (partner.togetherSince != null)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.favorite, color: AppColors.button),
                              SizedBox(width: 6),
                              Text('Together for', style: TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _togetherFor(partner.togetherSince!),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text('Love Language Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (withPct.isEmpty)
            const PremiumLockCard(
              title: 'No data yet',
              description: 'Complete the quiz to unlock insights.',
            )
          else if (isPremium)
            for (final e in withPct) _LangTile(entry: e, colorScheme: cs)
          else ...[
            _LangTile(entry: withPct.first, colorScheme: cs),
            const PremiumLockCard(
              title: 'Full insights are Premium',
              description: 'Unlock the rest of the love-language profile.',
            ),
          ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Keep it up to date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit partner basics or retake the quiz any time.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.pushNamed('partnerProfile'),
                      child: const Text('Edit Partner Details'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.pushNamed('loveLanguageQuiz'),
                      child: const Text('Retake Quiz'),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangInfo {
  final String label;
  final int score; // 0..5
  final Color color;
  final String description;
  final int percent;
  const _LangInfo(this.label, this.score, this.color, this.description, {this.percent = 0});
  _LangInfo copyWith({int? percent}) => _LangInfo(label, score, color, description, percent: percent ?? this.percent);
}

class _LangTile extends StatelessWidget {
  final _LangInfo entry;
  final ColorScheme colorScheme;
  const _LangTile({required this.entry, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: entry.color.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('${entry.percent}%'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

String _togetherFor(DateTime since) {
  final now = DateTime.now();
  int years = now.year - since.year;
  int months = now.month - since.month;
  int days = now.day - since.day;
  if (days < 0) {
    final prevMonth = DateTime(now.year, now.month, 0).day;
    days += prevMonth;
    months -= 1;
  }
  if (months < 0) {
    months += 12;
    years -= 1;
  }
  final parts = <String>[];
  if (years > 0) parts.add('$years year${years == 1 ? '' : 's'}');
  if (months > 0) parts.add('$months month${months == 1 ? '' : 's'}');
  if (days > 0 || parts.isEmpty) parts.add('$days day${days == 1 ? '' : 's'}');
  return parts.join(', ');
}
