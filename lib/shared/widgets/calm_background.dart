import 'package:flutter/material.dart';

class CalmBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool decorative; // adds subtle orbs
  final double? intensityLight; // 0-1 blend amount with primary
  final double? intensityDark; // 0-1 blend amount with primary
  const CalmBackground({
    super.key,
    required this.child,
    this.padding,
    this.decorative = false,
    this.intensityLight,
    this.intensityDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = isDark ? const Color(0xFF0B1220) : scheme.surface;
    final lightBlend = intensityLight ?? 0.12;
    final darkBlend = intensityDark ?? 0.28;
    final end = isDark
        ? Color.alphaBlend(scheme.primary.withValues(alpha: darkBlend), start)
        : Color.alphaBlend(scheme.primary.withValues(alpha: lightBlend), start);

    final content = SafeArea(
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );

    if (!decorative) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [start, end],
          ),
        ),
        child: content,
      );
    }

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [start, end],
            ),
          ),
        ),
        // Soft orbs
        Positioned(
          top: -60,
          left: -40,
          child: _orb(color: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.10), size: 220),
        ),
        Positioned(
          bottom: -40,
          right: -30,
          child: _orb(color: scheme.secondary.withValues(alpha: isDark ? 0.16 : 0.08), size: 180),
        ),
        content,
      ],
    );
  }

  Widget _orb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
