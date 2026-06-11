import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_analytics_service.dart';
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
  List<ScanRecord> _allScans = [];
  String _trendFilter = 'Monthly';
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
    setState(() => _loading = true);
    final scans = await _service.fetchScans();
    if (!mounted) return;
    setState(() {
      _allScans = scans;
      _loading = false;
    });
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  List<ScanRecord> get _healthyScans =>
      _allScans.where((s) => s.isHealthy).toList();

  double get _healthyRate {
    if (_allScans.isEmpty) return 0;
    return (_healthyScans.length / _allScans.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _service.buildAnalytics(_allScans, AnalyticsPeriod.month);
    final fmt = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
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
                          _buildSection('Healthy Plant Gallery'),
                          const SizedBox(height: 12),
                          _buildGallery(fmt),
                          const SizedBox(height: 20),
                          _buildSection('Healthy Trend Analytics'),
                          const SizedBox(height: 12),
                          _buildTrendChart(),
                          const SizedBox(height: 20),
                          _buildSection('AI Wellness Insights'),
                          const SizedBox(height: 12),
                          ..._wellnessInsights(analytics).map(_glassInsight),
                          const SizedBox(height: 20),
                          _buildSection('Recommended Healthy Farming Practices'),
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
                  'Celebrate and maintain healthy banana crops',
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
    final rate = _healthyRate;
    final delta = analytics.monthlyHealthyDelta;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B6D2A), Color(0xFF2FBF4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            color: AppColors.green.withValues(alpha: 0.35),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: rate / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${rate.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Healthy',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_healthyScans.length} healthy plants detected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                delta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                delta >= 0
                    ? '+${delta.abs().round()}% vs last month'
                    : '${delta.round()}% vs last month',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
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

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _healthyScans.length.clamp(0, 12),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = _healthyScans[i];
          return _HealthyScanCard(scan: s, fmt: fmt);
        },
      ),
    );
  }

  Widget _buildTrendChart() {
    final healthy = _healthyScans;
    if (healthy.length < 2) {
      return _emptyState(msg: 'Scan more healthy leaves to see trends.');
    }

    final buckets = <String, int>{};
    for (final s in healthy) {
      final d = s.createdAt;
      if (d == null) continue;
      final key = _trendFilter == 'Weekly'
          ? 'W${d.day ~/ 7}'
          : _trendFilter == 'Yearly'
              ? '${d.year}'
              : '${d.month}/${d.year}';
      buckets[key] = (buckets[key] ?? 0) + 1;
    }

    final keys = buckets.keys.toList();
    final spots = <FlSpot>[];
    for (var i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), buckets[keys[i]]!.toDouble()));
    }

    return Column(
      children: [
        Row(
          children: ['Weekly', 'Monthly', 'Yearly'].map((f) {
            final active = _trendFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: active,
                onSelected: (_) => setState(() => _trendFilter = f),
                selectedColor: AppColors.green.withValues(alpha: 0.15),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: Colors.grey.shade200,
                ),
              ),
              titlesData: const FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF2E7D32),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _wellnessInsights(ScanAnalyticsData analytics) {
    if (_healthyScans.isEmpty) {
      return const [
        'No healthy scans yet. Scan banana leaves to build your wellness profile.',
      ];
    }
    return [
      if (analytics.monthlyHealthyDelta > 0)
        'Healthy detections increased this month.',
      'Your crops show stable health conditions across recent scans.',
      'Regular scanning contributes to early disease prevention.',
      'Continue current monitoring practices to maintain crop wellness.',
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
            color: AppColors.green.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_rounded, color: AppColors.green),
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
        'Track humidity and rainfall — key drivers of fungal diseases.',
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
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.$1, color: AppColors.green),
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
              _scanThumb(s, 56),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${s.confidenceValue.round()}%',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
      ('10 Healthy Plants', count >= 10, Icons.forest_outlined),
      ('Consistent Weekly Scanner', _allScans.length >= 4, Icons.calendar_month),
      ('Crop Wellness Advocate', count >= 5, Icons.volunteer_activism_outlined),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: badges.map((b) {
        final unlocked = b.$2;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: (MediaQuery.of(context).size.width - 52) / 2,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unlocked
                  ? AppColors.brightGreen.withValues(alpha: 0.4)
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                b.$3,
                size: 32,
                color: unlocked ? AppColors.green : Colors.grey.shade400,
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
            msg ?? 'No healthy scans yet. Scan banana leaves to populate your wellness gallery.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _HealthyScanCard extends StatelessWidget {
  const _HealthyScanCard({required this.scan, required this.fmt});

  final ScanRecord scan;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
            child: _scanThumb(scan, 110),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  '${scan.confidenceValue.round()}% confidence',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
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

Widget _scanThumb(ScanRecord scan, double size) {
  return ScanImageWidget(
    imagePath: scan.imagePath,
    imageUrl: scan.imageUrl,
    width: size,
    height: size,
  );
}
