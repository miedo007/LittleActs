import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/glass_card.dart';

enum _Plan { monthly, yearly }

final _planProvider = StateProvider<_Plan>((ref) => _Plan.yearly);

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example prices for display + savings calc
    const double monthlyPrice = 7.99;
    const double yearlyPrice = 29.99;
    final int yearlySavingsPct = ((1 - (yearlyPrice / (12 * monthlyPrice))) * 100).round();
    final isPro = ref.watch(premiumProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(''),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goNamed('settings'),
          ),
        ],
      ),
      body: CalmBackground(
        decorative: true,
        intensityLight: 0.14,
        intensityDark: 0.30,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unlock Premium', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Support your relationship with more guidance and room to grow.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _FeatureRow(text: 'Unlimited milestones'),
                      SizedBox(height: 8),
                      _FeatureRow(text: 'Personalized weekly gestures'),
                      SizedBox(height: 8),
                      _FeatureRow(text: 'Streak tracking & progress'),
                      SizedBox(height: 8),
                      _FeatureRow(text: 'Couple sharing (coming soon)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choose your plan', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SegmentedButton<_Plan>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: _Plan.monthly, label: Text('Monthly')),
                          ButtonSegment(value: _Plan.yearly, label: Text('Yearly')),
                        ],
                        selected: {ref.watch(_planProvider)},
                        onSelectionChanged: (s) => ref.read(_planProvider.notifier).state = s.first,
                      ),
                      const SizedBox(height: 12),
                      Builder(builder: (_) {
                        final plan = ref.watch(_planProvider);
                        if (plan == _Plan.monthly) {
                          return const _PlanTile(
                            label: 'Monthly',
                            price: r'$7.99/month',
                            highlight: true,
                          );
                        }
                        return _PlanTile(
                          label: 'Yearly',
                          price: r'$29.99/year',
                          highlight: true,
                          note: 'Save $yearlySavingsPct% vs monthly',
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: isPro
                    ? null
                    : () async {
                        await ref.read(premiumProvider.notifier).upgrade();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Free trial started')),
                        );
                        context.pop();
                      },
                child: Text(isPro ? 'Premium active' : 'Try for Free'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await ref.read(premiumProvider.notifier).restore();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore attempted')),
                  );
                },
                child: const Text('Restore purchase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.check_circle, color: cs.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  final String? note;
  const _PlanTile({required this.label, required this.price, this.highlight = false, this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? cs.primary : cs.outlineVariant),
        color: highlight ? cs.primary.withValues(alpha: 0.06) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(price, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(note!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.primary)),
                ]
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Best value', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onPrimary)),
            ),
        ],
      ),
    );
  }
}
