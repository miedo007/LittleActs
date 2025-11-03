import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';
import 'package:nudge/models/weekly_gesture.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the list so UI updates when gesture changes/completes
    final gestures = ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final g = notifier.currentWeek();
    // Find bonus without mutating provider during build
    WeeklyGesture? bonus;
    if (g.id.isNotEmpty) {
      final bonusId = '${g.id}-bonus';
      final idx = gestures.indexWhere((x) => x.id == bonusId);
      if (idx >= 0) bonus = gestures[idx];
    }
    if (bonus == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(weeklyGesturesProvider.notifier).ensureBonusForCurrentWeek();
      });
    }
    final cs = Theme.of(context).colorScheme;
    final title = g.title.isEmpty ? "This week's Little Act" : g.title;
    final streak = notifier.streak();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("This week's Little Act", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F3066),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (g.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(g.category,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: g.completed
                          ? null
                          : () async {
                              await notifier.markComplete(g.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Marked as done')));
                            },
                      child: Text(g.completed ? 'Completed' : 'Mark as done'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!g.completed)
                    FutureBuilder<int>(
                      future: notifier.refreshesLeftForCurrentWeek(),
                      builder: (context, snap) {
                        final left = snap.data;
                        final subtitle = left == null ? '' : '  (${left}/2 left)';
                        return OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await notifier.refreshWithinSameCategory();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Refreshed within same category'
                                    : 'Refresh limit reached for this week'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('Refresh' + subtitle),
                        );
                      },
                    )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Bonus Act', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (bonus == null)
          Text('Generating a small extra idea…',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant))
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promote to non-null for closures
                Builder(builder: (context) {
                  final b = bonus!;
                  return Text(b.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700));
                }),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: Builder(builder: (context) {
                      final b = bonus!;
                      return OutlinedButton(
                      onPressed: b.completed
                          ? null
                          : () async {
                              await notifier.markComplete(b.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Bonus marked as done')));
                            },
                      child: Text(b.completed ? 'Completed' : 'Mark as done'),
                    );
                    }),
                  ),
                ])
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text('Progress', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            _metric(context, 'Streak', streak.toString()),
            const SizedBox(width: 12),
            _metric(context, 'Completed acts', notifier.completedActs().length.toString()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.pushNamed('milestonePlanner'),
          icon: const Icon(Icons.event_available_outlined),
          label: const Text('Add milestone'),
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}


