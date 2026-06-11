import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';

class DiseaseThumbnail extends StatelessWidget {
  const DiseaseThumbnail({
    super.key,
    required this.disease,
    required this.height,
    this.borderRadius = 16,
    this.heroTag,
  });

  final DiseaseGuideItem disease;
  final double height;
  final double borderRadius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: disease.imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Image.asset(
          disease.fallbackAsset,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        errorWidget: (_, __, ___) => Image.asset(
          disease.fallbackAsset,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: image);
    }
    return image;
  }
}
