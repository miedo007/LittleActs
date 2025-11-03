import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nudge/models/weekly_gesture.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';

class LoveBankTab extends ConsumerWidget {
  const LoveBankTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WeeklyGesture> gestures = ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final completed = notifier.completedActs();
    final s = notifier.streak();

    if (completed.isEmpty) {
      return Center(
        child: Text(
          "No completed acts yet. Mark this week's act as done to start your streak!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Love Bank', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            _streakChip(context, s),
          ],
        ),
        const SizedBox(height: 8),
        for (final g in completed)
          Card(
            child: ListTile(
              title: Text(g.title),
              subtitle: Text('Completed: ${DateFormat.yMMMEd().format(g.completedAt ?? g.weekStart)}'),
              trailing: Text(g.category.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
      ],
    );
  }

  Widget _streakChip(BuildContext context, int s) {
    return Chip(
      avatar: const Icon(Icons.whatshot, color: Colors.orange),
      label: Text('${s}× streak'),
    );
  }
}

