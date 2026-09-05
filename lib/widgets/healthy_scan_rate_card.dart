import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';

class HealthyScanRateCard extends StatelessWidget {
  const HealthyScanRateCard({
    super.key,
    required this.healthyCount,
    required this.totalScans,
    required this.healthyRate,
  });

  final int healthyCount;
  final int totalScans;
  final double? healthyRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE7DE)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: const Color(0xFF183C24).withValues(alpha: 0.07),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;
          final ringSize = compact ? 112.0 : 128.0;
          final copy = _MetricCopy(
            healthyCount: healthyCount,
            totalScans: totalScans,
          );
          final ring = _RateRing(rate: healthyRate, size: ringSize);
          final text = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'Healthy Scan Rate',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF183C24),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                copy.primary,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF343A36),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your recorded PLANTIVA scans.',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                ring,
                const SizedBox(height: 16),
                text,
              ],
            );
          }
          return Row(
            children: [
              ring,
              const SizedBox(width: 20),
              Expanded(child: text),
            ],
          );
        },
      ),
    );
  }
}

class _RateRing extends StatelessWidget {
  const _RateRing({required this.rate, required this.size});

  final double? rate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: rate == null ? 0 : rate! / 100,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFE5EEE6),
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rate == null ? '-' : '${rate!.round()}%',
                style: const TextStyle(
                  color: Color(0xFF183C24),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                rate == null ? 'No data' : 'Healthy',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCopy {
  const _MetricCopy({required this.healthyCount, required this.totalScans});

  final int healthyCount;
  final int totalScans;

  String get primary {
    if (totalScans == 0) {
      return 'No scan data yet. Scan banana leaves to start seeing trends.';
    }
    final verb = totalScans == 1 ? 'was' : 'were';
    return '$healthyCount of $totalScans recorded scans $verb classified as '
        'Healthy Leaf.';
  }
}
