import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/widgets/disease_guide/disease_thumbnail.dart';

class DiseaseCard extends StatefulWidget {
  const DiseaseCard({
    super.key,
    required this.disease,
    required this.onTap,
    this.isBookmarked = false,
    this.isViewed = false,
    this.animationDelay = 0,
  });

  final DiseaseGuideItem disease;
  final VoidCallback onTap;
  final bool isBookmarked;
  final bool isViewed;
  final int animationDelay;

  @override
  State<DiseaseCard> createState() => _DiseaseCardState();
}

class _DiseaseCardState extends State<DiseaseCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final d = widget.disease;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - v)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) => setState(() => _scale = 1),
        onTapCancel: () => setState(() => _scale = 1),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isViewed
                    ? AppColors.brightGreen.withValues(alpha: 0.35)
                    : const Color(0xFFD0E9D4),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    DiseaseThumbnail(
                      disease: d,
                      height: 110,
                      borderRadius: 22,
                      heroTag: 'disease_img_${d.id}',
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _badge(d.category.label, d.category.color),
                    ),
                    if (widget.isBookmarked)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 20,
                          shadows: [Shadow(blurRadius: 4)],
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.shortName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF1B4332),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: d.risk.color,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              d.risk.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: d.risk.color,
                              ),
                            ),
                          ),
                          if (widget.isViewed)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.green.withValues(alpha: 0.8),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
