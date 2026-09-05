import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_analytics_service.dart';
import 'package:flutter_plantiva/widgets/healthy_scan_rate_card.dart';
import 'package:flutter_plantiva/widgets/scan_image_widget.dart';
import 'package:intl/intl.dart';

class CropWellnessScreen extends StatefulWidget {
  const CropWellnessScreen({super.key});

  @override
  State<CropWellnessScreen> createState() => _CropWellnessScreenState();
}

class _CropWellnessScreenState extends State<CropWellnessScreen>
    with SingleTickerProviderStateMixin {
  final _service = ScanAnalyticsService();
  bool _loading = true;
  String? _error;
  List<ScanRecord> _allScans = [];
  AnalyticsPeriod _trendPeriod = AnalyticsPeriod.month;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final scans = await _service.fetchScans();
      if (!mounted) return;
      setState(() {
        _allScans = scans;
        _loading = false;
      });
      _anim.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load crop wellness data. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  List<ScanRecord> get _healthyScans =>
      _allScans.where((s) => s.isHealthy).toList();

  @override
  Widget build(BuildContext context) {
    final analytics =
        _service.buildAnalytics(_allScans, AnalyticsPeriod.allTime);
    final fmt = DateFormat('MMM d, yyyy - h:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F1),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : FadeTransition(
                    opacity: _anim,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeader()),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildHero(analytics),
                              const SizedBox(height: 20),
                              _buildSection('Healthy Scan Gallery'),
                              const SizedBox(height: 12),
                              _buildGallery(fmt),
                              const SizedBox(height: 20),
                              _buildSection('Healthy Trend Analytics'),
                              const SizedBox(height: 12),
                              _buildTrendChart(),
                              const SizedBox(height: 20),
                              _buildSection('Recorded Scan Insights'),
                              const SizedBox(height: 12),
                              ..._wellnessInsights(analytics)
                                  .map(_glassInsight),
                              const SizedBox(height: 20),
                              _buildSection(
                                  'Recommended Healthy Farming Practices'),
                              const SizedBox(height: 12),
                              ..._practiceCards(),
                              const SizedBox(height: 20),
                              _buildSection('Recent Healthy Activity'),
                              const SizedBox(height: 12),
                              _buildTimeline(fmt),
                              const SizedBox(height: 20),
                              _buildSection('Achievements'),
                              const SizedBox(height: 12),
                              _buildAchievements(),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crop Wellness',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332),
                  ),
                ),
                Text(
                  'A summary of your recorded banana leaf scans',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(ScanAnalyticsData analytics) {
    return HealthyScanRateCard(
      healthyCount: analytics.healthyCount,
      totalScans: analytics.totalScans,
      healthyRate: analytics.healthyRate,
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF202422),
      ),
    );
  }

  Widget _buildGallery(DateFormat fmt) {
    if (_healthyScans.isEmpty) return _emptyState();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth * 0.48).clamp(150.0, 190.0).toDouble();
        final itemCount = _healthyScans.length > 12 ? 12 : _healthyScans.length;
        return SizedBox(
          height: 212,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 4),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final s = _healthyScans[i];
              return _HealthyScanCard(scan: s, fmt: fmt, width: cardWidth);
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendChart() {
    const periods = [
      AnalyticsPeriod.week,
      AnalyticsPeriod.month,
      AnalyticsPeriod.allTime,
    ];
    final analytics = _service.buildAnalytics(_allScans, _trendPeriod);
    final points = analytics.trend;

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: periods.map((period) {
            final active = _trendPeriod == period;
            return ChoiceChip(
              label: Text(period.label),
              selected: active,
              showCheckmark: false,
              onSelected: (_) => setState(() => _trendPeriod = period),
              selectedColor: const Color(0xFFDDF4E7),
              backgroundColor: Colors.white,
              checkmarkColor: AppColors.green,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (points.isEmpty)
          _emptyState(
            msg: 'No scan data yet. Scan banana leaves to start seeing trends.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final chartHeight =
                  (constraints.maxWidth * 0.58).clamp(190.0, 240.0).toDouble();
              final chartWidth =
                  (points.length * 76.0).clamp(constraints.maxWidth, 1600.0);
              return Container(
                height: chartHeight,
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE1E8E3)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: points.length == 1
                            ? 1
                            : (points.length - 1).toDouble(),
                        minY: 0,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                if (value != value.roundToDouble()) {
                                  return const SizedBox.shrink();
                                }
                                final index = value.toInt();
                                if (index < 0 || index >= points.length) {
                                  return const SizedBox.shrink();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    points[index].label,
                                    style: const TextStyle(
                                      color: AppColors.mutedText,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              points.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                points[index].healthyCount.toDouble(),
                              ),
                            ),
                            isCurved: false,
                            color: AppColors.green,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.green.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  List<String> _wellnessInsights(ScanAnalyticsData analytics) {
    if (!analytics.hasData) {
      return const [
        'No scan data yet. Scan banana leaves to start building your recorded-scan summary.',
      ];
    }
    final verb = analytics.totalScans == 1 ? 'was' : 'were';
    return <String>[
      '${analytics.healthyCount} of ${analytics.totalScans} recorded scans '
          '$verb classified as Healthy Leaf.',
      if (analytics.mostCommonDisease != null)
        '${_displayCategory(analytics.mostCommonDisease!)} was the most '
            'frequently recorded non-healthy condition.',
      if (analytics.totalScans < 5)
        'This summary uses a small sample. Record more scans over time for a clearer monitoring history.'
      else
        'Continue regular scanning to compare recorded results over time.',
    ];
  }

  Widget _glassInsight(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: const Color(0xFF128C7E).withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_rounded, color: Color(0xFF128C7E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _practiceCards() {
    const practices = [
      (
        Icons.visibility_outlined,
        'Inspect leaves regularly',
        'Check both sides of banana leaves for early signs of disease.',
      ),
      (
        Icons.cleaning_services_outlined,
        'Maintain field sanitation',
        'Remove fallen leaves and debris to reduce pathogen spread.',
      ),
      (
        Icons.wb_sunny_outlined,
        'Monitor environmental conditions',
        'Track humidity and rainfall - key drivers of fungal diseases.',
      ),
      (
        Icons.document_scanner_outlined,
        'Continue routine scanning',
        'Weekly AI scans help catch issues before they spread.',
      ),
    ];

    return practices
        .map(
          (p) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD0E9D4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.$1, color: const Color(0xFFB7791F)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.$2,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.$3,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildTimeline(DateFormat fmt) {
    if (_healthyScans.isEmpty) return _emptyState();

    return Column(
      children: _healthyScans.take(6).map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _scanThumb(s, 56, 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Healthy Leaf',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      s.createdAt != null ? fmt.format(s.createdAt!) : 'Recent',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievements() {
    final count = _healthyScans.length;
    final badges = [
      ('First Healthy Detection', count >= 1, Icons.emoji_events_outlined),
      ('10 Healthy Scans', count >= 10, Icons.forest_outlined),
      (
        'Consistent Weekly Scanner',
        _allScans.length >= 4,
        Icons.calendar_month
      ),
      ('Crop Wellness Advocate', count >= 5, Icons.volunteer_activism_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 340
            ? constraints.maxWidth
            : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: badges.map((b) {
            final unlocked = b.$2;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: cardWidth,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: unlocked ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFF128C7E).withValues(alpha: 0.35)
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    b.$3,
                    size: 32,
                    color: unlocked
                        ? const Color(0xFF128C7E)
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    b.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: unlocked ? const Color(0xFF232625) : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _emptyState({String? msg}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            msg ??
                'No healthy scans yet. Scan banana leaves to populate your wellness gallery.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedText, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _displayCategory(String category) =>
      category == 'Insect Pest' ? 'Insect Pest Damage' : category;
}

class _HealthyScanCard extends StatelessWidget {
  const _HealthyScanCard({
    required this.scan,
    required this.fmt,
    required this.width,
  });

  final ScanRecord scan;
  final DateFormat fmt;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: _scanThumb(scan, width, 110),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Healthy',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  scan.createdAt != null
                      ? fmt.format(scan.createdAt!)
                      : 'Recent',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _scanThumb(ScanRecord scan, double width, double height) {
  return ScanImageWidget(
    imagePath: scan.imagePath,
    imageUrl: scan.imageUrl,
    imageBase64: scan.imageBase64,
    width: width,
    height: height,
  );
}
