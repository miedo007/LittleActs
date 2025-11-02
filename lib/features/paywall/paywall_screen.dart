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
    const double yearlyPrice = 49.99;
    final int yearlySavingsPct = 40;
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
            onPressed: () => context.pushNamed('settings'),
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
                    Text('Keep love alive, one small act at a time.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Your gentle reminder to stay thoughtful without overthinking.',
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
                      _FeatureRow(text: '💌 Weekly personalized gestures based on your partner\'s love language.'),
                      SizedBox(height: 8),
                      _FeatureRow(text: '🧠 Complete your partner\'s profile and unlock full insights.'),
                      SizedBox(height: 8),
                      _FeatureRow(text: '🔔 Smart reminders: birthdays, anniversaries, and milestones handled automatically.'),
                      SizedBox(height: 8),
                      _FeatureRow(text: '🎁 Bonus nudges & surprises: extra inspiration to go beyond the ordinary.'),
                      SizedBox(height: 8),
                      _FeatureRow(text: '❤️ Connection streak & progress tracking.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('7-day FREE trial!', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('Cancel anytime. No commitment.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              Text('How your free trial works', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _StepRow(icon: Icons.psychology_alt_outlined, title: 'Step 1 – Discover what makes them feel loved', text: 'Complete your partner\'s love language profile and unlock personalized weekly gestures built around what matters most to them.'),
              const SizedBox(height: 8),
              _StepRow(icon: Icons.mark_email_read_outlined, title: 'Step 2 – Get your first weekly nudge', text: 'Receive your first Little Act this week — a 3-minute gesture designed to strengthen your connection, effortlessly.'),
              const SizedBox(height: 8),
              _StepRow(icon: Icons.calendar_month_outlined, title: 'Step 3 – Stay close without pressure', text: 'You’ll get gentle reminders before milestones and optional bonus ideas to go beyond the basics.'),
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
                        segments: [
                          const ButtonSegment(value: _Plan.monthly, label: Text('Monthly')),
                          ButtonSegment(
                            value: _Plan.yearly,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Yearly'),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Save $yearlySavingsPct%', style: Theme.of(context).textTheme.labelSmall),
                                ),
                              ],
                            ),
                          ),
                        ],
                        selected: {ref.watch(_planProvider)},
                        onSelectionChanged: (s) => ref.read(_planProvider.notifier).state = s.first,
                      ),
                      const SizedBox(height: 12),
                      Builder(builder: (_) {
                        final plan = ref.watch(_planProvider);
                        return Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => ref.read(_planProvider.notifier).state = _Plan.monthly,
                              child: _PlanTile(
                                label: 'Monthly',
                                price: r'$7.99/month',
                                highlight: false,
                                selected: plan == _Plan.monthly,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => ref.read(_planProvider.notifier).state = _Plan.yearly,
                              child: _PlanTile(
                                label: 'Yearly',
                                price: r'$49.99/year',
                                highlight: true,
                                note: 'Save $yearlySavingsPct% vs monthly',
                                selected: plan == _Plan.yearly,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(builder: (_) {
                final plan = ref.watch(_planProvider);
                final priceText = plan == _Plan.monthly ? r'$7.99/month' : r'$49.99/year';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: Text('7 day FREE trial • Then ' + priceText,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onPrimary)),
                );
              }),
              const SizedBox(height: 10),
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
                child: Text(isPro ? 'Premium active' : 'Start your free trial'),
              ),
              const SizedBox(height: 6),
              Text('Cancel anytime, keep your progress.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Purchase appears as “iTunes Store”. No ads. No spam.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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
    const green = Color(0xFF53D476);
    return Row(
      children: [
        const Icon(Icons.check_circle, color: green, size: 20),
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
  final bool selected;
  const _PlanTile({required this.label, required this.price, this.highlight = false, this.note, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0F3066),
        border: Border.all(color: selected ? cs.primary : Colors.white, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(price, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(note!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF53D476), fontWeight: FontWeight.w700)),
                ]
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF53D476),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Best value', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _StepRow({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        )
      ],
    );
  }
}
