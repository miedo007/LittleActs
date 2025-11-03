import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:intl/intl.dart';

class PartnerSummaryTab extends ConsumerWidget {
  const PartnerSummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final cs = Theme.of(context).colorScheme;

    if (partner == null) {
      return Center(
        child: Text('No partner yet. Add one in Settings.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant)),
      );
    }

    final ratings = <String, int>{
      'Quality Time': (partner.qualityTime ?? 0).clamp(0, 5),
      'Words of Affirmation': (partner.wordsOfAffirmation ?? 0).clamp(0, 5),
      'Acts of Service': (partner.actsOfService ?? 0).clamp(0, 5),
      'Physical Touch': (partner.physicalTouch ?? 0).clamp(0, 5),
      'Receiving Gifts': (partner.receivingGifts ?? 0).clamp(0, 5),
    };
    final total = ratings.values.fold<int>(0, (a, b) => a + b);
    final pct = total > 0
        ? {for (final e in ratings.entries) e.key: ((e.value / total) * 100).round()}
        : {for (final e in ratings.entries) e.key: 0};

    Color colorFor(String key) {
      switch (key) {
        case 'Words of Affirmation':
          return const Color(0xFF6C63FF);
        case 'Acts of Service':
          return const Color(0xFF00B894);
        case 'Physical Touch':
          return const Color(0xFFFF7675);
        case 'Receiving Gifts':
          return const Color(0xFFFDCB6E);
        case 'Quality Time':
          return const Color(0xFF0984E3);
        default:
          return cs.primary;
      }
    }

    final milestones = [...ref.watch(milestonesProvider)];
    milestones.sort((a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Partner', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.name ?? 'Partner',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  if (partner.loveLanguagePrimary != null)
                    _chip(context, 'Primary: ${partner.loveLanguagePrimary}')
                  else
                    const SizedBox.shrink(),
                  if (partner.loveLanguageSecondary != null)
                    _chip(context, 'Secondary: ${partner.loveLanguageSecondary}')
                  else
                    const SizedBox.shrink(),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Love Language Results', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final entry in pct.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.key)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorFor(entry.key),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${entry.value}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Milestones', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        if (milestones.isEmpty)
          Text('No milestones yet. Add birthdays, anniversaries, and more.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant))
        else
          Column(
            children: [
              for (final m in milestones.take(3))
                ListTile(
                  leading: const Icon(Icons.event_rounded),
                  title: Text(m.name),
                  subtitle: Text('Next: ' + DateFormat.yMMMMd().format(m.nextOccurrence())),
                ),
            ],
          ),
      ],
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Chip(label: Text(text));
  }
}
