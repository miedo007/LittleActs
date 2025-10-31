import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nudge/models/weekly_gesture.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WeeklyGesture> gestures = ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final isPro = ref.watch(premiumProvider);

    final sorted = [...gestures]..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    final s = notifier.streak();

    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Streak')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: isPro ? Text('$s') : const Icon(Icons.lock_outline),
              ),
              title: Text(isPro ? '$s-week streak' : 'Streaks are Premium'),
              subtitle: const Text('Consistency creates connection.'),
              trailing: isPro
                  ? null
                  : TextButton(
                      onPressed: () => context.goNamed('paywall'),
                      child: const Text('Upgrade'),
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sorted.isEmpty
                  ? const Center(
                      child: Text(
                        "No gestures yet.\nComplete this week's nudge!",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final g = sorted[i];
                        return Card(
                          child: ListTile(
                            title: Text(g.title),
                            subtitle: Text('Week of ${DateFormat.yMMMEd().format(g.weekStart)} • ${g.category}'),
                            trailing: g.completed
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.radio_button_unchecked),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

