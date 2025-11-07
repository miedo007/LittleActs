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

    final totalActs = completed.length;
    final longest = notifier.longestStreak();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Love Bank',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Every small act adds up to something big \u2665',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _metricCard(context, 'Total Acts', totalActs.toString()),
          const SizedBox(width: 12),
          _metricCard(context, 'Longest Streak', '$longest'),
        ]),
        const SizedBox(height: 16),
        RepaintBoundary(
          child: _Heatmap52(
            dates: completed.map((e) => e.completedAt ?? e.weekStart).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Last thoughtful moments',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
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
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _loveColor(context, g.category)),
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

}

class _Heatmap52 extends StatelessWidget {
  final List<DateTime> dates;
  const _Heatmap52({required this.dates});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    const weeks = 52;

    DateTime startOfWeek(DateTime d) {
      final base = DateTime(d.year, d.month, d.day);
      final weekday = base.weekday % 7; // Sunday => 0
      final start = base.subtract(Duration(days: weekday));
      return DateTime(start.year, start.month, start.day);
    }

    // Count completions per week start
    final Map<DateTime, int> weekCount = {};
    for (final d in dates) {
      final ws = startOfWeek(d);
      weekCount[ws] = (weekCount[ws] ?? 0) + 1;
    }

    // Helper: Sundays inside the given month
    List<DateTime> weeksInMonth(int year, int month) {
      final first = DateTime(year, month, 1);
      final last = DateTime(year, month + 1, 0);
      DateTime cur = first;
      while (cur.weekday % 7 != 0) {
        cur = cur.add(const Duration(days: 1));
      }
      final list = <DateTime>[];
      while (!cur.isAfter(last)) {
        list.add(cur);
        cur = cur.add(const Duration(days: 7));
      }
      return list;
    }

    return LayoutBuilder(builder: (context, constraints) {
      const monthsPerRow = 3;
      const monthGap = 12.0;
      const dotSize = 14.0;
      const dotGap = 6.0;
      final width = constraints.maxWidth;
      final monthWidth = ((width - (monthsPerRow - 1) * monthGap) / monthsPerRow).clamp(120.0, 9999.0);

      Widget buildMonth(int year, int month) {
        final weeks = weeksInMonth(year, month);
        return SizedBox(
          width: monthWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              ['January','February','March','April','May','June','July','August','September','October','November','December'][month - 1],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Row(children: [
              for (int i = 0; i < weeks.length; i++) ...[
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: (weekCount[weeks[i]] ?? 0) > 0 ? cs.primary : cs.outlineVariant.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(dotSize / 2),
                  ),
                ),
                if (i != weeks.length - 1) const SizedBox(width: dotGap),
              ]
            ])
          ]),
        );
      }

      final year = now.year;
      final months = <Widget>[for (int m = 1; m <= 12; m++) buildMonth(year, m)];

      // Legend
      Widget legendBox(Color color) => Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: monthGap,
            runSpacing: 12,
            children: months,
          ),
          const SizedBox(height: 12),
          Row(children: [
            legendBox(cs.outlineVariant.withOpacity(0.35)),
            const SizedBox(width: 6),
            Text('Incomplete', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(width: 16),
            legendBox(cs.primary),
            const SizedBox(width: 6),
            Text('Completed', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ])
        ],
      );
    });
  }
}

Color _loveColor(BuildContext context, String category) {
  switch (category.toLowerCase()) {
    case 'words':
    case 'affirmation':
      return const Color(0xFF6C63FF);
    case 'service':
    case 'acts of service':
      return const Color(0xFF00B894);
    case 'touch':
      return const Color(0xFFFF7675);
    case 'gifts':
      return const Color(0xFFFDCB6E);
    case 'time':
    case 'quality time':
      return const Color(0xFF0984E3);
    default:
      return Theme.of(context).colorScheme.primary;
  }
}
 
Widget _metricCard(BuildContext context, String label, String value) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Text('🔥 $value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}
