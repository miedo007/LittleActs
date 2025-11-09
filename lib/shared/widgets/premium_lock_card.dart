import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/style/palette.dart';

class PremiumLockCard extends StatelessWidget {
  final String title;
  final String description;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  final Color buttonColor;

  const PremiumLockCard({
    super.key,
    required this.title,
    required this.description,
    this.padding,
    this.centerContent = false,
    this.buttonColor = AppColors.button,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment:
          centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centerContent ? TextAlign.center : TextAlign.start,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: centerContent ? TextAlign.center : TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: centerContent ? Alignment.center : Alignment.centerRight,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: buttonColor,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => context.goNamed('paywall'),
            child: const Text('Unlock Premium'),
          ),
        ),
      ],
    );

    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
