import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:nudge/models/weekly_gesture.dart";
import "package:nudge/shared/widgets/Providers/gesture_provider.dart";

class LoveBankTab extends ConsumerWidget {
  const LoveBankTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WeeklyGesture> gestures = ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final completed = notifier.completedActs();
    final s = notifier.streak();
    final cs = Theme.of(context).colorScheme;

    if (completed.isEmpty) {
      return Center(
        child: Text(
          "No completed acts yet. Mark this week's act as done to start your streak!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              'Love Bank',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            _streakChip(context, s),
          ],
        ),
        const SizedBox(height: 8),
        for (final g in completed)
          Card(
            child: ListTile(
              title: Text(
                g.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Completed: ${DateFormat.yMMMEd().format(g.completedAt ?? g.weekStart)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Text(
                g.category.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: cs.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _streakChip(BuildContext context, int s) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.local_fire_department_rounded, color: cs.primary),
      label: Text(
        '${s}-day streak',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      side: BorderSide(color: cs.outlineVariant),
      shape: const StadiumBorder(),
      backgroundColor: Color.alphaBlend(cs.primary.withOpacity(0.06), Colors.white),
    );
  }
}
