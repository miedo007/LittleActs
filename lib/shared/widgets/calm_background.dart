import 'package:flutter/material.dart';

class CalmBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const CalmBackground({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = isDark ? const Color(0xFF0B1220) : scheme.surface;
    final end = isDark
        ? Color.alphaBlend(scheme.primary.withValues(alpha: 0.18), start)
        : Color.alphaBlend(scheme.primary.withValues(alpha: 0.06), start);
    return Container
      (
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [start, end],
        ),
      ),
      child: SafeArea(child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child)),
    );
  }
}
