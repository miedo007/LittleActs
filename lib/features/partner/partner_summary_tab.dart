import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:intl/intl.dart';
import 'package:nudge/models/partner.dart';

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
                if (partner.togetherSince != null)
                  Text(
                    _togetherFor(partner.togetherSince!),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await _pickDateCupertino(
                        context,
                        DateTime(now.year, now.month, now.day),
                        DateTime(now.year - 20, 1, 1),
                        now,
                      );
                      if (picked != null) {
                        final notifier = ref.read(partnerProvider.notifier);
                        await notifier.savePartner(partner.copyWith(togetherSince: picked));
                      }
                    },
                    child: const Text('Set Together Since'),
                  ),
                if (partner.birthday == null)
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await _pickDateCupertino(
                        context,
                        DateTime(now.year, now.month, now.day),
                        DateTime(now.year - 80, 1, 1),
                        now,
                      );
                      if (picked != null) {
                        final notifier = ref.read(partnerProvider.notifier);
                        await notifier.savePartner(partner.copyWith(birthday: picked));
                      }
                    },
                    child: const Text('Set birthday'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Love Language', style: Theme.of(context).textTheme.titleSmall),
            TextButton(
              onPressed: () => context.pushNamed('profileInsights'),
              child: const Text('View full profile'),
            )
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: RepaintBoundary(
              child: _LoveDonut(
                pct: pct.map((k, v) => MapEntry(k, v.toDouble())),
                colorFor: colorFor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Milestones', style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => context.pushNamed('milestonePlanner'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add milestone'),
            ),
          ],
        ),
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
                  subtitle: Text('Next: ${DateFormat.yMMMMd().format(m.nextOccurrence())}'),
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

class _LoveDonut extends StatefulWidget {
  final Map<String, double> pct; // 0..100 values per language
  final Color Function(String key) colorFor;
  const _LoveDonut({required this.pct, required this.colorFor});

  @override
  State<_LoveDonut> createState() => _LoveDonutState();
}

class _LoveDonutState extends State<_LoveDonut> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.pct.isNotEmpty) {
      final sorted = widget.pct.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _selected = sorted.first.key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.pct.values.fold<double>(0, (a, b) => a + b);
    final sorted = widget.pct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, c) {
      final size = 140.0;
      return Row(
        children: [
          GestureDetector(
            onTapUp: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final center = Offset(size / 2, size / 2);
              final local = box.globalToLocal(d.globalPosition);
              final dx = local.dx - center.dx;
              final dy = local.dy - center.dy;
              final angle = (math.atan2(dy, dx) + 2 * math.pi) % (2 * math.pi);
              // Map angle to slice
              double acc = 0;
              for (final e in sorted) {
                final double sweep = total == 0 ? 0.0 : (e.value / total) * 2 * math.pi;
                if (angle >= acc && angle < acc + sweep) {
                  setState(() => _selected = e.key);
                  break;
                }
                acc += sweep;
              }
            },
            child: RepaintBoundary(
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _DonutPainter(
                    pct: widget.pct,
                    colorFor: widget.colorFor,
                    highlight: _selected,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selected ?? '',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                        if (_selected != null)
                          Text('${widget.pct[_selected!]?.round() ?? 0}%',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in sorted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: widget.colorFor(e.key), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e.key)),
                      Text('${e.value.round()}%'),
                    ]),
                  ),
              ],
            ),
          )
        ],
      );
    });
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> pct;
  final Color Function(String key) colorFor;
  final String? highlight;
  _DonutPainter({required this.pct, required this.colorFor, this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final total = pct.values.fold<double>(0, (a, b) => a + b);
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2.0 * 0.95;
    final thickness = radius * 0.28;
    final sorted = pct.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    double start = -math.pi / 2; // top
    for (final e in sorted) {
      final double sweep = total == 0 ? 0.0 : (e.value / total) * 2 * math.pi;
      final double sw = (thickness * ((e.key == highlight) ? 1.2 : 1.0)).toDouble();
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..color = colorFor(e.key);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.pct != pct || oldDelegate.highlight != highlight;
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
  return 'Together for $years years, $months months, $days days';
}

Future<DateTime?> _pickDateCupertino(
  BuildContext context,
  DateTime initialDate,
  DateTime firstDate,
  DateTime lastDate,
) async {
  DateTime temp = initialDate;
  return showModalBottomSheet<DateTime>(
    context: context,
    builder: (ctx) => SizedBox(
      height: 280,
      child: Column(children: [
        Expanded(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initialDate,
            minimumDate: firstDate,
            maximumDate: lastDate,
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, temp),
                child: const Text('Done'),
              ),
            ),
          ]),
        )
      ]),
    ),
  );
}
