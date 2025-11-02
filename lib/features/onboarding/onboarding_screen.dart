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
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 4) {
      _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CalmBackground(
            padding: const EdgeInsets.all(16),
            decorative: true,
            intensityLight: 0.14,
            intensityDark: 0.30,
            child: Column(children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: const [
                    _SplashPage(),
                    _PerkPage(
                      title: 'Love thrives on the little things',
                      subtitle: "Research shows couples who stay strong respond to each other's small bids for connection far more often than those who don't.",
                      icon: Icons.favorite_rounded,
                    ),
                    _PerkPage(
                      title: 'Life gets loud. Love gets crowded out.',
                      subtitle: 'We forget dates. We miss chances. Not because we don’t care—because our brains are full.',
                      icon: Icons.cake_rounded,
                    ),
                    _PerkPage(
                      title: 'Small acts, repeated, change everything.',
                      subtitle: 'Tiny kindnesses boost happiness for both giver and receiver and most of us underestimate their impact.',
                      icon: Icons.auto_graph_rounded,
                    ),
                    _PlansPage(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Dots(index: _index, count: 5),
              const SizedBox(height: 12),
              Row(children: [
                if (_index < 4)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _controller.animateToPage(4, duration: const Duration(milliseconds: 260), curve: Curves.easeOut),
                      style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                      child: const Text('See plans'),
                    ),
                  ),
                if (_index < 4) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(shape: const StadiumBorder(), minimumSize: const Size.fromHeight(52)),
                    onPressed: _index < 4
                        ? _next
                        : () async {
                            await ref.read(premiumProvider.notifier).upgrade();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Free trial started')));
                            context.goNamed('partnerProfile');
                          },
                    child: Text(_index < 4 ? 'Next' : 'Try for Free'),
                  ),
                ),
              ]),
            ]),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => context.goNamed('partnerProfile'),
              ),
            ),
          ),
        ],
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
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: -40,
          child: IgnorePointer(
            child: SizedBox(
              width: 260,
              height: 160,
              child: CustomPaint(painter: _BranchPainter(color: const Color(0xFF232443))),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800, fontSize: 28, color: const Color(0xFF232443)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: const Color(0xFF232443), fontSize: 18, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 220, height: 130, child: CustomPaint(painter: _IntertwinedLogoPainter(color: cs.onSurface))),
        const SizedBox(height: 24),
        Text(
          'Little Acts',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                fontSize: 54,
                color: const Color(0xFF232443),
              ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Love needs a nudge.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF232443),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Small acts. Big love.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF232443),
                  fontSize: 16,
                ),
          ),
        ),
      ]),
    );
  }
}

class _IntertwinedLogoPainter extends CustomPainter {
  final Color color;
  _IntertwinedLogoPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final left = Path()
      ..moveTo(size.width * 0.05, size.height * 0.70)
      ..cubicTo(size.width * 0.25, size.height * 0.30, size.width * 0.45, size.height * 0.30, size.width * 0.50, size.height * 0.55)
      ..cubicTo(size.width * 0.55, size.height * 0.80, size.width * 0.75, size.height * 0.80, size.width * 0.95, size.height * 0.45);
    final right = Path()
      ..moveTo(size.width * 0.95, size.height * 0.70)
      ..cubicTo(size.width * 0.75, size.height * 0.30, size.width * 0.55, size.height * 0.30, size.width * 0.50, size.height * 0.55)
      ..cubicTo(size.width * 0.45, size.height * 0.80, size.width * 0.25, size.height * 0.80, size.width * 0.05, size.height * 0.45);
    final loop = Path()..addArc(Rect.fromCenter(center: Offset(size.width * 0.50, size.height * 0.52), width: size.width * 0.22, height: size.height * 0.22), 0, 3.14159);
    canvas.drawPath(left, stroke);
    canvas.drawPath(right, stroke);
    canvas.drawPath(loop, stroke..strokeWidth = stroke.strokeWidth * 0.7);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Decorative branch painter for onboarding pages
class _BranchPainter extends CustomPainter {
  final Color color;
  _BranchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final branch = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    // Main branch
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.9)
      ..cubicTo(size.width * 0.35, size.height * 0.6, size.width * 0.6, size.height * 0.5, size.width * 0.95, size.height * 0.2);
    canvas.drawPath(path, branch);

    // Twigs
    void twig(Offset from, Offset to) {
      final p = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo((from.dx + to.dx) / 2, from.dy - 12, to.dx, to.dy);
      canvas.drawPath(p, branch..strokeWidth = 3.5);
    }
    twig(Offset(size.width * 0.55, size.height * 0.55), Offset(size.width * 0.75, size.height * 0.45));
    twig(Offset(size.width * 0.7, size.height * 0.4), Offset(size.width * 0.88, size.height * 0.35));
    twig(Offset(size.width * 0.45, size.height * 0.65), Offset(size.width * 0.62, size.height * 0.6));

    // Blossoms
    final blossom = Paint()..color = const Color(0xFFFFB6C1);
    for (final o in [
      Offset(size.width * 0.62, size.height * 0.58),
      Offset(size.width * 0.78, size.height * 0.43),
      Offset(size.width * 0.9, size.height * 0.32),
      Offset(size.width * 0.7, size.height * 0.36),
      Offset(size.width * 0.58, size.height * 0.62),
    ]) {
      canvas.drawCircle(o, 3, blossom);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlansPage extends ConsumerWidget {
  const _PlansPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    const double monthlyPrice = 7.99;
    const double yearlyPrice = 29.99;
    final int yearlySavingsPct = ((1 - (yearlyPrice / (12 * monthlyPrice))) * 100).round();
    const green = Color(0xFF53D476);
    Widget perk(String t) => Row(
          children: [
            const Icon(Icons.check_circle, color: green, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(t)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Make it yours', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              perk('Unlimited milestones'),
              const SizedBox(height: 6),
              perk('Personalized weekly gestures'),
              const SizedBox(height: 6),
              perk('Streak tracking & progress'),
              const SizedBox(height: 6),
              perk('Couple sharing (coming soon)'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _planTile(context, cs, 'Monthly', r'$7.99/month'),
        const SizedBox(height: 8),
        _planTile(context, cs, 'Yearly', r'$29.99/year', highlight: true, note: 'Save $yearlySavingsPct% vs monthly'),
        const SizedBox(height: 8),
        Text('Prices are examples. Tap Try for Free to continue.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ]),
    );
  }

  Widget _planTile(BuildContext context, ColorScheme cs, String label, String price, {bool highlight = false, String? note}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0F3066),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(price, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            if (note != null) ...[
              const SizedBox(height: 2),
              Text(note, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF53D476), fontWeight: FontWeight.w700)),
            ],
          ]),
        ),
        if (highlight)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF53D476), borderRadius: BorderRadius.circular(8)),
            child: Text('Best value', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
          ),
      ]),
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
          decoration: BoxDecoration(color: active ? cs.primary : cs.outlineVariant, borderRadius: BorderRadius.circular(6)),
        );
      }),
    );
  }
}
