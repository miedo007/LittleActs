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
        Text('Love Bank', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Every small act adds up to something big \u2665',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(children: [const Spacer(), _streakChip(context, s)]),
        const SizedBox(height: 16),
        RepaintBoundary(
          child: _Heatmap52(
            dates: completed.map((e) => e.completedAt ?? e.weekStart).toList(),
          ),
        ),
        const SizedBox(height: 16),
        for (final g in completed.take(5))
          Card(
            child: ListTile(
              leading: Text(_emojiGlyph(g.category), style: const TextStyle(fontSize: 20)),
              title: Text(
                g.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                DateFormat.yMMMEd().format(g.completedAt ?? g.weekStart),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Text(
                g.category.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.primary),
              ),
            ),
          ),
      ],
    );
  }

  static String _emojiGlyph(String category) {
    switch (category.toLowerCase()) {
      case 'gifts':
        return '🎁';
      case 'service':
      case 'acts of service':
        return '🧺';
      case 'time':
      case 'quality time':
        return '⏰';
      case 'touch':
        return '🤝';
      case 'affirmation':
      case 'words':
        return '💬';
      default:
        return '✨';
    }
  }

  static String _emojiFor(String category) {
    switch (category.toLowerCase()) {
      case 'gifts':
        return '🎁';
      case 'service':
      case 'acts of service':
        return '🍽️';
      case 'time':
      case 'quality time':
        return '⏰';
      case 'touch':
        return '🤝';
      case 'affirmation':
        return '💐';
      default:
        return '💗';
    }
  }

  Widget _streakChip(BuildContext context, int s) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.local_fire_department_rounded, color: cs.primary),
      label: Text('$s WEEK${s == 1 ? '' : 'S'}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      side: BorderSide(color: cs.outlineVariant),
      shape: const StadiumBorder(),
      backgroundColor: Color.alphaBlend(cs.primary.withOpacity(0.06), Colors.white),
    );
  }
}

class _Heatmap52 extends StatelessWidget {
  final List<DateTime> dates;
  const _Heatmap52({required this.dates});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    const weeks = 52;
    final Map<DateTime, int> count = {};
    for (final d in dates) {
      final key = DateTime(d.year, d.month, d.day);
      count[key] = (count[key] ?? 0) + 1;
    }
    final cols = <Widget>[];
    for (int w = weeks - 1; w >= 0; w--) {
      final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: (now.weekday % 7) + w * 7));
      final cells = <Widget>[];
      for (int i = 0; i < 7; i++) {
        final day = DateTime(weekStart.year, weekStart.month, weekStart.day).add(Duration(days: i));
        final c = (count[day] ?? 0).clamp(0, 4);
        final color = c == 0 ? cs.outlineVariant.withOpacity(0.25) : cs.primary.withOpacity(0.20 + 0.15 * c);
        cells.add(Container(width: 10, height: 10, margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))));
      }
      cols.add(Column(children: cells));
    }
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: cols));
  }
}

