import 'package:flutter/material.dart';
import 'package:flutter_plantiva/widgets/logo_badge.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({
    super.key,
    required this.image,
    required this.curveHeight,
    required this.logoSize,
    this.imageHeight = 240,
    this.logoWithBackground = true,
  });

  final String image;
  final double curveHeight;
  final double logoSize;
  // Bagong control para ma-adjust mo ang taas ng image per screen.
  final double imageHeight;
  // Bagong control para kung may white bilog sa likod ng logo o wala.
  final bool logoWithBackground;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipPath(
          clipper: _BottomCurveClipper(curveHeight),
          child: SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Image.asset(image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: -logoSize / 2.5,
          child: LogoBadge(size: logoSize, withBackground: logoWithBackground),
        ),
      ],
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  _BottomCurveClipper(this.curveDepth);

  final double curveDepth;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - curveDepth)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curveDepth,
        size.width,
        size.height - curveDepth,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
