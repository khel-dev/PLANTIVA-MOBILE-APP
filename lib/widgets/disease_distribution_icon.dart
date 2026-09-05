import 'package:flutter/material.dart';

enum DiseaseDistributionIconKind {
  blackSigatoka,
  bractMosaic,
  bunchyTop,
  healthyLeaf,
  insectPest,
  moko,
  panamaWilt,
  yellowSigatoka,
  unknown,
}

class DiseaseDistributionIcon extends StatelessWidget {
  const DiseaseDistributionIcon({
    super.key,
    required this.category,
    required this.color,
    this.size = 18,
  });

  final String category;
  final Color color;
  final double size;

  static DiseaseDistributionIconKind kindFor(String category) {
    return switch (category) {
      'Black Sigatoka' => DiseaseDistributionIconKind.blackSigatoka,
      'Bract Mosaic Virus' => DiseaseDistributionIconKind.bractMosaic,
      'Bunchy Top Disease' => DiseaseDistributionIconKind.bunchyTop,
      'Healthy Leaf' => DiseaseDistributionIconKind.healthyLeaf,
      'Insect Pest' ||
      'Insect Pest Damage' =>
        DiseaseDistributionIconKind.insectPest,
      'Moko Disease' => DiseaseDistributionIconKind.moko,
      'Panama Disease' => DiseaseDistributionIconKind.panamaWilt,
      'Yellow Sigatoka' => DiseaseDistributionIconKind.yellowSigatoka,
      _ => DiseaseDistributionIconKind.unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: '$category condition icon',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _DiseaseDistributionIconPainter(
            kind: kindFor(category),
            color: color,
          ),
        ),
      ),
    );
  }
}

class _DiseaseDistributionIconPainter extends CustomPainter {
  const _DiseaseDistributionIconPainter({
    required this.kind,
    required this.color,
  });

  final DiseaseDistributionIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (kind) {
      case DiseaseDistributionIconKind.blackSigatoka:
        _drawLeaf(canvas, stroke);
        _drawLesions(canvas, stroke, fill, streaks: false);
      case DiseaseDistributionIconKind.yellowSigatoka:
        _drawLeaf(canvas, stroke);
        _drawLesions(canvas, stroke, fill, streaks: true);
      case DiseaseDistributionIconKind.bractMosaic:
        _drawLeaf(canvas, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(7, 15)
            ..lineTo(10, 12)
            ..lineTo(12, 14)
            ..lineTo(15, 10)
            ..lineTo(18, 11),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(9, 9)
            ..lineTo(11, 10.5)
            ..lineTo(14, 7.5),
          stroke,
        );
      case DiseaseDistributionIconKind.bunchyTop:
        _drawBunchyTop(canvas, stroke);
      case DiseaseDistributionIconKind.healthyLeaf:
        _drawLeaf(canvas, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(8, 13)
            ..lineTo(10.5, 15.5)
            ..lineTo(16.5, 9),
          stroke,
        );
      case DiseaseDistributionIconKind.insectPest:
        _drawInsect(canvas, stroke);
      case DiseaseDistributionIconKind.moko:
        _drawWiltedLeaf(canvas, stroke, roots: false);
        canvas.drawCircle(const Offset(14.5, 12.5), 1.2, fill);
        canvas.drawCircle(const Offset(17.5, 14.5), 0.9, fill);
        canvas.drawCircle(const Offset(13, 16), 0.8, fill);
      case DiseaseDistributionIconKind.panamaWilt:
        _drawWiltedLeaf(canvas, stroke, roots: true);
        canvas.drawPath(
          Path()
            ..moveTo(13, 11)
            ..quadraticBezierTo(15, 14, 14, 17),
          stroke,
        );
      case DiseaseDistributionIconKind.unknown:
        canvas.drawCircle(const Offset(12, 12), 8, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(10, 9)
            ..quadraticBezierTo(12, 6.5, 14, 9)
            ..quadraticBezierTo(14, 11, 12, 12.5)
            ..lineTo(12, 14),
          stroke,
        );
        canvas.drawCircle(const Offset(12, 17.5), 0.9, fill);
    }

    canvas.restore();
  }

  void _drawLeaf(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(4, 19)
        ..cubicTo(3.5, 11, 8, 4.5, 20, 4)
        ..cubicTo(20, 12.5, 14.5, 19, 4, 19)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(4.5, 19)
        ..quadraticBezierTo(11, 12, 19, 5),
      paint,
    );
  }

  void _drawLesions(
    Canvas canvas,
    Paint stroke,
    Paint fill, {
    required bool streaks,
  }) {
    if (streaks) {
      canvas.drawLine(const Offset(9, 11), const Offset(13, 10), stroke);
      canvas.drawLine(const Offset(11, 15), const Offset(15.5, 13.5), stroke);
      canvas.drawLine(const Offset(13.5, 8), const Offset(16.5, 7.5), stroke);
      return;
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(10, 14), width: 3.2, height: 1.5),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(14, 10), width: 3.5, height: 1.5),
      fill,
    );
    canvas.drawCircle(const Offset(15, 14.5), 1, fill);
  }

  void _drawBunchyTop(Canvas canvas, Paint paint) {
    const base = Offset(12, 20);
    final leaves = [
      (const Offset(12, 4), const Offset(9.5, 11)),
      (const Offset(6, 7), const Offset(9, 13)),
      (const Offset(18, 7), const Offset(15, 13)),
      (const Offset(5, 12), const Offset(9, 16)),
      (const Offset(19, 12), const Offset(15, 16)),
    ];
    for (final leaf in leaves) {
      final tip = leaf.$1;
      final middle = leaf.$2;
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(middle.dx - 2, middle.dy, tip.dx, tip.dy)
          ..quadraticBezierTo(middle.dx + 2, middle.dy, base.dx, base.dy),
        paint,
      );
    }
    canvas.drawLine(const Offset(8, 20), const Offset(16, 20), paint);
  }

  void _drawWiltedLeaf(Canvas canvas, Paint paint, {required bool roots}) {
    canvas.drawPath(
      Path()
        ..moveTo(9, 20)
        ..lineTo(10.5, 10)
        ..cubicTo(13, 7, 18.5, 8, 20, 10.5)
        ..cubicTo(19, 16.5, 15.5, 19, 11, 16.5),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(11, 16.5)
        ..quadraticBezierTo(15, 13, 19.5, 10.5),
      paint,
    );
    if (roots) {
      canvas.drawLine(const Offset(9, 20), const Offset(5.5, 22), paint);
      canvas.drawLine(const Offset(9, 20), const Offset(9, 23), paint);
      canvas.drawLine(const Offset(9, 20), const Offset(12, 22.5), paint);
    } else {
      canvas.drawLine(const Offset(6, 21), const Offset(12, 21), paint);
    }
  }

  void _drawInsect(Canvas canvas, Paint paint) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 13), width: 8, height: 10),
      paint,
    );
    canvas.drawCircle(const Offset(12, 6), 2.5, paint);
    canvas.drawLine(const Offset(10.5, 4), const Offset(8.5, 2), paint);
    canvas.drawLine(const Offset(13.5, 4), const Offset(15.5, 2), paint);
    canvas.drawLine(const Offset(8, 10), const Offset(4, 8), paint);
    canvas.drawLine(const Offset(8, 13), const Offset(3.5, 13), paint);
    canvas.drawLine(const Offset(8.5, 16), const Offset(5, 19), paint);
    canvas.drawLine(const Offset(16, 10), const Offset(20, 8), paint);
    canvas.drawLine(const Offset(16, 13), const Offset(20.5, 13), paint);
    canvas.drawLine(const Offset(15.5, 16), const Offset(19, 19), paint);
    canvas.drawLine(const Offset(12, 8.5), const Offset(12, 18), paint);
  }

  @override
  bool shouldRepaint(covariant _DiseaseDistributionIconPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
  }
}
