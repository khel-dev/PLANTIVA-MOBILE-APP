import 'package:flutter/material.dart';

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, required this.size, this.withBackground = true});

  final double size;
  // Kapag false, transparent lang ang likod ng logo (walang puting bilog).
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'plantiva_logo',
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: withBackground ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: withBackground
                  ? [
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: 2,
                        color: Colors.black.withValues(alpha: 0.16),
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(withBackground ? size * 0.16 : 0),
              child: Image.asset(
                'assets/images/plantiva_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
