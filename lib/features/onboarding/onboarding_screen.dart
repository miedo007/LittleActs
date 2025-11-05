import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'dart:math' as math;
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  @override
  void initState() {
    super.initState();
    // Precache images to avoid decode jank during first paint/animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/branch.png'), context);
      precacheImage(const AssetImage('assets/logo.png'), context);
    });
  }

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
                                    children: [
                    _SplashPage(),
                    _PerkPage(
                      title: 'Love thrives on the little things',
                      subtitle: "Research shows couples who stay strong respond to each other's small bids for connection far more often than those who don't.",
                      icon: Icons.favorite_rounded,
                      titleWeight: FontWeight.w800,
                      highlightSubphrase: 'little things',
                      highlightColor: Color(0xFFE98A39),
                    ),
                    _PerkPage(
                      title: 'Life gets loud. Love gets crowded out.',
                      subtitle: 'We forget dates. We miss chances. Not because we don\'t care — because our brains are full.',
                      icon: Icons.cake_rounded,
                      titleWeight: FontWeight.w900,
                      highlightSubphrase: 'Love gets crowded out.',
                      highlightColor: Color(0xFFDD5A54),
                    ),
                    _PerkPage(
                      title: 'Small acts, repeated, change everything.',
                      subtitle: 'Tiny kindnesses boost happiness for both giver and receiver and most of us underestimate their impact.',
                      icon: Icons.auto_graph_rounded,
                      titleWeight: FontWeight.w900,
                      highlightSubphrase: 'change everything',
                      highlightColor: Color(0xFF3666D1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Dots(index: _index, count: 4, activeColor: Color(0xFF695AD3)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF695AD3),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    onPressed: _index < 3
                        ? _next
                        : () async {
                            if (!context.mounted) return;
                            context.goNamed('partnerProfile');
                          },
                    child: Text(_index < 3 ? 'Continue' : 'Get Started'),
                  ),
                ),
              ]),
            ]),
          ),
          // Close button removed per spec
        ],
      ),
    );
  }
}

class _PerkPage extends StatelessWidget {
  final String title;
  final String? imageAsset;
  final String subtitle;
  final IconData icon;
  final FontWeight? titleWeight;
  final String? highlightSubphrase;
  final Color? highlightColor;
  const _PerkPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageAsset,
    this.titleWeight,
    this.highlightSubphrase,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -20,
          right: -50,
          child: IgnorePointer(
            child: _FloatingBranch(asset: imageAsset ?? 'assets/branch.png', width: 340),
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
                _buildTitle(context),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: const Color(0xFF232443), fontSize: 18, height: 1.45, fontWeight: FontWeight.w400),
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

extension on _PerkPage {
  Widget _buildTitle(BuildContext context) {
    final baseStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(
            fontWeight: titleWeight ?? FontWeight.w800,
            fontSize: 28,
            color: const Color(0xFF232443));

    if (highlightSubphrase == null || highlightSubphrase!.isEmpty) {
      return Text(title, textAlign: TextAlign.left, style: baseStyle);
    }

    final idx = title.toLowerCase().indexOf(highlightSubphrase!.toLowerCase());
    if (idx < 0) {
      return Text(title, textAlign: TextAlign.left, style: baseStyle);
    }

    final before = title.substring(0, idx);
    final match = title.substring(idx, idx + highlightSubphrase!.length);
    final after = title.substring(idx + highlightSubphrase!.length);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: before),
          TextSpan(text: match, style: baseStyle?.copyWith(color: highlightColor ?? const Color(0xFFFFA726))),
          TextSpan(text: after),
        ],
      ),
      textAlign: TextAlign.left,
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
        SizedBox(
          width: 260,
          height: 260,
          child: Image.asset('assets/logo.png', fit: BoxFit.contain, color: null),
        ),
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
            'Love made effortless',
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
            'Small acts. Big love',
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
class _FloatingBranch extends StatefulWidget {
  final String asset;
  final double width;
  const _FloatingBranch({required this.asset, required this.width});
  @override
  State<_FloatingBranch> createState() => _FloatingBranchState();
}

class _FloatingBranchState extends State<_FloatingBranch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final devicePx = MediaQuery.of(context).devicePixelRatio;
    return AnimatedBuilder(
      animation: _c,
      child: Image.asset(
        widget.asset,
        width: widget.width,
        fit: BoxFit.contain,
        // Downsample to the on-screen size to reduce decode/raster cost
        cacheWidth: (widget.width * devicePx).round(),
        filterQuality: FilterQuality.low,
      ),
      builder: (_, child) {
        final t = _c.value * 2 * 3.1415926; // 0..2pi
        final dy = math.sin(t) * 3; // gentle float
        final scale = 1 + math.cos(t) * 0.007;
        final angle = math.sin(t) * 0.009; // ~1.7 degrees
        return Transform.translate(
          offset: Offset(-1 + math.cos(t) * 2, dy),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
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
  final Color? activeColor;
  const _Dots({required this.index, required this.count, this.activeColor});
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
              color: active ? (activeColor ?? cs.primary) : cs.outlineVariant,
              borderRadius: BorderRadius.circular(6)),
        );
      }),
    );
  }
}
























