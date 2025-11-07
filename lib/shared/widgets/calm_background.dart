import 'package:flutter/material.dart';

import '../style/palette.dart';

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
    // Fixed gradient (light): top #EDEBFC to bottom #FAFAFE
    const topColor = AppColors.gradientTop;
    const bottomColor = AppColors.gradientBottom;

    final content = SafeArea(
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );

    if (!decorative) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
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
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
          ),
        ),
        // Soft orbs
        Positioned(
          top: -60,
          left: -40,
          child: _orb(color: topColor.withValues(alpha: 0.18), size: 220),
        ),
        Positioned(
          bottom: -40,
          right: -30,
          child: _orb(color: bottomColor.withValues(alpha: 0.16), size: 180),
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
