import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Navy-to-blue gradient with soft glows and a thin red accent strip.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDeep, AppColors.navy, Color(0xFF123A7A)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // Soft bright-blue glow, top right.
        Positioned(
          top: -220,
          right: -180,
          child: _Glow(
            diameter: 560,
            color: AppColors.brightBlue.withValues(alpha: 0.28),
          ),
        ),
        // Very subtle red glow, bottom left.
        Positioned(
          bottom: -260,
          left: -200,
          child: _Glow(
            diameter: 560,
            color: AppColors.americanRed.withValues(alpha: 0.16),
          ),
        ),
        child,
        // Thin red accent strip along the bottom edge.
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 4,
          child: ColoredBox(color: AppColors.americanRed),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
