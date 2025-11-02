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
    if (_index < 3) {
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

                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Dots(index: _index, count: 4),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(shape: const StadiumBorder(), minimumSize: const Size.fromHeight(52)),
                    onPressed: _index < 3
                        ? _next
                        : () async {
                            if (!context.mounted) return;
                            context.goNamed('partnerProfile');
                          },
                    child: Text(_index < 3 ? 'Next' : 'Get Started'),
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

// Plans page was removed from onboarding; see Paywall instead.

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

