import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/Services/notification_service.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/glass_card.dart';
import 'package:url_launcher/url_launcher.dart';

enum _Plan { weekly, yearly }

final _planProvider = StateProvider<_Plan>((ref) => _Plan.weekly);
final _purchasingProvider = StateProvider<bool>((ref) => false);
final _trialEnabledProvider = StateProvider<bool>((ref) => true);

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(premiumProductsProvider);
    final isPro = ref.watch(premiumProvider);
    final purchasing = ref.watch(_purchasingProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen<bool>(premiumProvider, (prev, next) async {
      if (prev != true && next == true) {
        // Ask for notification permission only after the user subscribes
        await NotificationService().requestPermissions();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium activated')),
        );
        Navigator.of(context).maybePop();
      }
    });

    return Scaffold(
      body: CalmBackground(
        decorative: true,
        intensityLight: 0.14,
        intensityDark: 0.30,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    const _PulseLogo(size: 120),
                    const SizedBox(height: 12),
                    Text(
                      'Unlimited Access',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _FeatureRow(icon: Icons.psychology_rounded, text: 'Love-language insights: understand them deeply.'),
                    SizedBox(height: 8),
                    _FeatureRow(icon: Icons.favorite_rounded, text: 'Weekly gestures: small acts, big impact.'),
                    SizedBox(height: 8),
                    _FeatureRow(icon: Icons.notifications_active_rounded, text: 'Smart reminders: never miss a moment.'),
                    SizedBox(height: 8),
                    _FeatureRow(icon: Icons.emoji_events_rounded, text: 'Progress & extras: stay consistent effortlessly.'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Removed 'Choose your plan' title
                      const SizedBox(height: 4),
                      Builder(builder: (_) {
                        final plan = ref.watch(_planProvider);
                        final weekly = products.maybeWhen(
                          data: (p) => p.weekly?.price,
                          orElse: () => null,
                        );
                        final yearly = products.maybeWhen(
                          data: (p) => p.yearly?.price,
                          orElse: () => null,
                        );
                        final weeklyRaw = products.maybeWhen(
                          data: (p) => p.weekly?.rawPrice,
                          orElse: () => null,
                        );
                        final yearlyRaw = products.maybeWhen(
                          data: (p) => p.yearly?.rawPrice,
                          orElse: () => null,
                        );
                        String? yearlyNote;
                        if (weeklyRaw != null && yearlyRaw != null && weeklyRaw > 0) {
                          final annualAtWeekly = weeklyRaw * 52.0;
                          final pct = ((1 - (yearlyRaw / annualAtWeekly)) * 100).round();
                          if (pct > 0) yearlyNote = 'Save $pct%';
                        }
                        return Column(
                          children: [
                            // Yearly on top
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => ref.read(_planProvider.notifier).state = _Plan.yearly,
                              child: _PlanTile(
                                label: 'Yearly',
                                price: '${yearly ?? r'$49.99'}/year',
                                highlight: true,
                                note: yearlyNote ?? 'Best value',
                                selected: plan == _Plan.yearly,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => ref.read(_planProvider.notifier).state = _Plan.weekly,
                              child: _PlanTile(
                                label: 'Weekly',
                                price: '${weekly ?? r'$5.99'}/week',
                                highlight: false,
                                selected: plan == _Plan.weekly,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.transparent),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Free trial enabled',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  const Spacer(),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: Switch(
                                      value: ref.watch(_trialEnabledProvider),
                                      onChanged: (v) => ref.read(_trialEnabledProvider.notifier).state = v,
                                      activeTrackColor: const Color(0xFF53D476),
                                      activeThumbColor: Colors.white, // white thumb when ON
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'No payment required today',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFF695AD3),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                onPressed: isPro || purchasing
                    ? null
                    : () async {
                        try {
                          ref.read(_purchasingProvider.notifier).state = true;
                          final plan = ref.read(_planProvider);
                          if (plan == _Plan.weekly) {
                            await ref.read(premiumProvider.notifier).buyWeekly();
                          } else {
                            await ref.read(premiumProvider.notifier).buyYearly();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Purchase failed. Please try again.')),
                            );
                          }
                        } finally {
                          ref.read(_purchasingProvider.notifier).state = false;
                        }
                      },
                child: purchasing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text('Processing...'),
                        ],
                      )
                    : Text(isPro ? 'Premium active' : 'Continue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: purchasing
                    ? null
                    : () async {
                        try {
                          ref.read(_purchasingProvider.notifier).state = true;
                          await ref.read(premiumProvider.notifier).restore();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Restore requested')),
                            );
                          }
                        } finally {
                          ref.read(_purchasingProvider.notifier).state = false;
                        }
                      },
                child: const Text('Restore Purchases'),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final uri = Uri.parse('https://docs.google.com/document/d/1GGduvRVdPEk4ASX04e5As3OERoDEkq9NyKAhaqj2nJg/edit?usp=sharing');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'Privacy Policy',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final uri = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'Terms of Use',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = Theme.of(context).textTheme.bodyLarge; // larger text
    final parts = text.split(':');
    final lead = parts.isNotEmpty ? parts.first.trim() : text;
    final rest = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: base?.copyWith(color: cs.onSurface, height: 1.25),
              children: [
                TextSpan(text: lead, style: base?.copyWith(fontWeight: FontWeight.w700)),
                if (rest.isNotEmpty) const TextSpan(text: ': '),
                if (rest.isNotEmpty) TextSpan(text: rest),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseLogo extends StatefulWidget {
  final double size;
  const _PulseLogo({required this.size});
  @override
  State<_PulseLogo> createState() => _PulseLogoState();
}

class _PulseLogoState extends State<_PulseLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) => Transform.scale(scale: _a.value, child: child),
      child: Image.asset('assets/logo.png', width: widget.size, height: widget.size),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  final String? note;
  final bool selected;
  const _PlanTile({
    required this.label,
    required this.price,
    this.highlight = false,
    this.note,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: selected
            ? Color.alphaBlend(cs.primary.withOpacity(0.06), Colors.white)
            : Colors.white,
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note!,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: const Color(0xFF53D476), fontWeight: FontWeight.w700),
                  ),
                ]
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Save 90%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
            ),
          const SizedBox(width: 8),
          if (selected)
            const Icon(Icons.check_circle, color: Color(0xFF695AD3)),
        ],
      ),
    );
  }
}


