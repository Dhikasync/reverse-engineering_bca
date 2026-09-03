import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBCALogo extends StatefulWidget {
  const AnimatedBCALogo({super.key});

  @override
  AnimatedBCALogoState createState() => AnimatedBCALogoState();
}

class AnimatedBCALogoState extends State<AnimatedBCALogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget logoAsset = Image.asset(
      'assets/images/logo_bca_icon.png',
      width: 50,
      height: 50,
      fit: BoxFit.contain,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return SweepGradient(
                  colors: const [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 0.45, 1.0],
                  transform: GradientRotation(_controller.value * 2 * math.pi),
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: logoAsset,
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return SweepGradient(
                  colors: const [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF005DAA),
                    Color(0xFFF2C94C),
                  ],
                  stops: const [0.0, 0.85, 0.95, 1.0],
                  transform: GradientRotation(_controller.value * 2 * math.pi),
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: logoAsset,
            ),
          ],
        );
      },
    );
  }
}
