import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _skipToPlans() {
    _controller.animateToPage(3, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          if (_index < 3)
            TextButton(onPressed: _skipToPlans, child: const Text('Skip')),
        ],
      ),
      body: CalmBackground(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _PerkPage(
                    title: 'Tiny gestures, big impact',
                    subtitle: 'Get a simple weekly nudge tailored to your relationship.',
                    icon: Icons.favorite_rounded,
                  ),
                  _PerkPage(
                    title: 'Celebrate what matters',
                    subtitle: 'Plan milestones and never miss the moments that count.',
                    icon: Icons.cake_rounded,
                  ),
                  _PerkPage(
                    title: 'Build a healthy rhythm',
                    subtitle: 'Track streaks and see your connection grow over time.',
                    icon: Icons.auto_graph_rounded,
                  ),
                  _PlansPage(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Dots(index: _index, count: 4),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_index < 3)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _skipToPlans,
                        child: const Text('See plans'),
                      ),
                    ),
                  if (_index < 3) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _index < 3
                          ? _next
                          : () async {
                              await ref.read(premiumProvider.notifier).upgrade();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Premium activated')),
                              );
                              context.goNamed('partnerProfile');
                            },
                      child: Text(_index < 3 ? 'Continue' : 'Start Premium'),
                    ),
                  ),
                ],
              ),
            ),
            if (_index == 3)
              TextButton(
                onPressed: () => context.goNamed('partnerProfile'),
                child: const Text('Continue free'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PerkPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _PerkPage({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(icon, size: 72, color: cs.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          _CardBullet(text: 'Thoughtful ideas that fit real life'),
          const SizedBox(height: 8),
          _CardBullet(text: 'Personalized by your milestones'),
          const SizedBox(height: 8),
          _CardBullet(text: 'Designed to reduce friction'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PlansPage extends ConsumerWidget {
  const _PlansPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Make it yours', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Premium includes unlimited milestones, weekly nudges, and streak tracking.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          _PlanTile(label: 'Weekly', price: r'$2.49/week'),
          const SizedBox(height: 8),
          const _PlanTile(label: 'Yearly', price: r'$29.99/year', highlight: true),
          const SizedBox(height: 8),
          Text('Prices are examples. Tap Start Premium to continue.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  const _PlanTile({required this.label, required this.price, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8)),
              child: Text('Best value', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onPrimary)),
            ),
        ],
      ),
    );
  }
}

class _CardBullet extends StatelessWidget {
  final String text;
  const _CardBullet({required this.text});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int index;
  final int count;
  const _Dots({required this.index, required this.count});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: active ? 18 : 6,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
