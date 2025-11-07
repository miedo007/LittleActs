import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nudge/models/milestone.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/style/palette.dart';

class MilestonePlannerScreen extends ConsumerStatefulWidget {
  const MilestonePlannerScreen({super.key});

  @override
  ConsumerState<MilestonePlannerScreen> createState() =>
      _MilestonePlannerScreenState();
}

class _MilestonePlannerScreenState
    extends ConsumerState<MilestonePlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  DateTime? _pickedDate;
  bool _repeatYearly = true;

  @override
  Widget build(BuildContext context) {
    final milestones = [...ref.watch(milestonesProvider)];
    milestones.sort((a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()));
    final isPro = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: CalmBackground(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      'Milestone Planner',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              if (!isPro)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      title: const Text('Free plan: 1 milestone'),
                      subtitle: const Text('Upgrade to add unlimited milestones.'),
                      trailing: TextButton(
                        onPressed: () => context.goNamed('paywall'),
                        child: const Text('Upgrade'),
                      ),
                    ),
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.frameOutline),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Milestone name (e.g., Birthday, Anniversary)',
                          labelStyle: TextStyle(color: AppColors.bodyMuted),
                          hintStyle: TextStyle(color: AppColors.bodyMuted),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.frameOutline),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.calendar_month, color: AppColors.icon),
                              label: Text(
                                _pickedDate == null
                                    ? 'Pick date'
                                    : DateFormat.yMMMMd().format(_pickedDate!),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _pickedDate ?? now,
                                  firstDate: DateTime(now.year - 50),
                                  lastDate: DateTime(now.year + 50),
                                );
                                if (picked != null) {
                                  setState(() => _pickedDate = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: _repeatYearly,
                                onChanged: (v) => setState(() => _repeatYearly = v ?? true),
                                side: const BorderSide(color: AppColors.frameOutline),
                                checkColor: AppColors.surface,
                                activeColor: AppColors.button,
                              ),
                              const Text('Repeat yearly'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _pickedDate != null) {
                            if (!isPro && milestones.isNotEmpty) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Premium required for more milestones.'),
                                  action: SnackBarAction(
                                    label: 'Upgrade',
                                    onPressed: () => context.goNamed('paywall'),
                                  ),
                                ),
                              );
                              return;
                            }
                            final m = Milestone(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: _nameCtrl.text.trim(),
                              date: _pickedDate!,
                              repeatYearly: _repeatYearly,
                            );
                            await ref.read(milestonesProvider.notifier).add(m);
                            setState(() {
                              _nameCtrl.clear();
                              _pickedDate = null;
                              _repeatYearly = true;
                            });
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Milestone added')),
                            );
                          }
                        },
                        child: const Text('Add milestone'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: milestones.isEmpty
                    ? const Center(
                        child: Text(
                          'No milestones yet.\nAdd a birthday, anniversary, or any date.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: milestones.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final m = milestones[i];
                          final next = m.nextOccurrence();
                          final today = DateTime.now();
                          final d0 = DateTime(today.year, today.month, today.day);
                          final d1 = DateTime(next.year, next.month, next.day);
                          final diff = d1.difference(d0).inDays;
                          String chipText;
                          if (diff == 0) {
                            chipText = 'Today 🎉';
                          } else if (diff > 0) {
                            chipText = 'In $diff day${diff == 1 ? '' : 's'}';
                          } else {
                            chipText = '${diff.abs()} day${diff == -1 ? '' : 's'} ago';
                          }
                          return Dismissible(
                            key: ValueKey(m.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => ref.read(milestonesProvider.notifier).remove(m.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.frameOutline),
                              ),
                              child: ListTile(
                                title: Text(
                                  m.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  m.repeatYearly
                                      ? 'Next: ${DateFormat.yMMMMd().format(next)}'
                                      : 'Date: ${DateFormat.yMMMMd().format(m.date)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.button.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.button),
                                  ),
                                  child: Text(
                                    chipText,
                                    style: const TextStyle(color: AppColors.button, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
