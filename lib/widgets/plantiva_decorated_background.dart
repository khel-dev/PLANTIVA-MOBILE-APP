import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlantivaDecoratedBackground extends StatelessWidget {
  const PlantivaDecoratedBackground({
    super.key,
    required this.child,
    this.showTopLeaf = true,
    this.showBottomLeaf = true,
    this.backgroundColor = const Color(0xFFF7F6F1),
  });

  static const _leaf = AssetImage('assets/images/banana-leaf.png');

  final Widget child;
  final bool showTopLeaf;
  final bool showBottomLeaf;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;
            final leafSize = math
                .min(width * 0.58, height * 0.31)
                .clamp(150.0, 250.0)
                .toDouble();

            return Stack(
              fit: StackFit.expand,
              children: [
                if (showTopLeaf)
                  Positioned(
                    top: -leafSize * 0.33,
                    right: -leafSize * 0.22,
                    width: leafSize,
                    height: leafSize,
                    child: const _DecorativeLeaf(
                      image: _leaf,
                      angle: -0.32,
                    ),
                  ),
                if (showBottomLeaf)
                  Positioned(
                    bottom: -leafSize * 0.38,
                    left: -leafSize * 0.25,
                    width: leafSize,
                    height: leafSize,
                    child: const _DecorativeLeaf(
                      image: _leaf,
                      angle: 2.82,
                    ),
                  ),
                child,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DecorativeLeaf extends StatelessWidget {
  const _DecorativeLeaf({required this.image, required this.angle});

  final ImageProvider image;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Opacity(
          opacity: 0.045,
          child: Transform.rotate(
            angle: angle,
            child: Image(
              image: image,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}
