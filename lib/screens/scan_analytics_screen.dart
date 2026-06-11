import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_analytics_service.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';

class ScanAnalyticsScreen extends StatefulWidget {
  const ScanAnalyticsScreen({super.key});

  @override
  State<ScanAnalyticsScreen> createState() => _ScanAnalyticsScreenState();
}

class _ScanAnalyticsScreenState extends State<ScanAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final _service = ScanAnalyticsService();
  AnalyticsPeriod _period = AnalyticsPeriod.month;
  bool _loading = true;
  List<ScanRecord> _allScans = [];
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
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
    _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  ScanAnalyticsData get _data =>
      _service.buildAnalytics(_allScans, _period);

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: SafeArea(
        child: _loading
            ? _buildSkeleton()
            : FadeTransition(
                opacity: _fade,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSummaryGrid(data),
                          const SizedBox(height: 20),
                          _buildHealthScore(data),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Disease Distribution'),
                          const SizedBox(height: 12),
                          _buildBarChart(data),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Detection Trends'),
                          const SizedBox(height: 12),
                          _buildLineChart(data),
                          const SizedBox(height: 20),
                          _buildSectionTitle('AI Insights'),
                          const SizedBox(height: 12),
                          ...data.insights.map(_buildInsightCard),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Recommended Actions'),
                          const SizedBox(height: 12),
                          ...data.recommendations.map(_buildRecCard),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'Scan Analytics',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    Text(
                      'Insights from your banana crop monitoring activities',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showFilterSheet,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD0E9D4)),
                  ),
                  child: const Icon(Icons.tune_rounded, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: AnalyticsPeriod.values.map((p) {
                final active = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(p.label),
                    selected: active,
                    onSelected: (_) {
                      setState(() => _period = p);
                      _anim.forward(from: 0);
                    },
                    selectedColor: AppColors.green.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.green,
                    labelStyle: TextStyle(
                      color: active ? AppColors.green : AppColors.mutedText,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Period',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...AnalyticsPeriod.values.map((p) {
              return ListTile(
                leading: Icon(
                  _period == p
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.green,
                ),
                title: Text(p.label),
                onTap: () {
                  setState(() => _period = p);
                  _anim.forward(from: 0);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(ScanAnalyticsData data) {
    final cards = [
      ('Total Scans', '${data.totalScans}', Icons.qr_code_scanner_rounded),
      ('Healthy', '${data.healthyCount}', Icons.eco_rounded),
      ('Diseased', '${data.diseasedCount}', Icons.coronavirus_outlined),
      (
        'Top Disease',
        data.mostCommonDisease == 'None' ? '—' : data.mostCommonDisease.split(' ').first,
        Icons.analytics_outlined,
      ),
      (
        'Avg Confidence',
        '${data.avgConfidence.round()}%',
        Icons.speed_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + i * 80),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.scale(scale: 0.92 + 0.08 * v, child: child),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(c.$3, color: AppColors.green, size: 22),
                const Spacer(),
                Text(
                  c.$2,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222522),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  c.$1,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthScore(ScanAnalyticsData data) {
    final score = data.cropHealthScore;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green,
            AppColors.brightGreen.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: AppColors.green.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crop Health Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.totalScans == 0
                      ? 'Start scanning to generate your crop health score.'
                      : 'Your monitored banana crops show ${score >= 70 ? "generally healthy" : "concerning"} conditions with ${data.diseasedCount > 0 ? "isolated disease occurrences requiring attention" : "strong wellness indicators"}.',
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF202422),
      ),
    );
  }

  Widget _buildBarChart(ScanAnalyticsData data) {
    if (data.totalScans == 0) return _emptyCard('No scan data for this period.');

    final entries = DiseaseLabels.categories
        .map((c) => MapEntry(c, data.distribution[c] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      entries.addAll(
        DiseaseLabels.categories.map((c) => MapEntry(c, 0)),
      );
    }

    final maxVal = entries.map((e) => e.value).fold(1, (a, b) => a > b ? a : b);
    final topDisease = entries.isNotEmpty ? entries.first.key : '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        children: entries.map((e) {
          final pct = data.totalScans == 0
              ? 0
              : ((e.value / data.totalScans) * 100).round();
          final isTop = e.key == topDisease && e.value > 0;
          final color = DiseaseLabels.colorFor(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isTop ? color : const Color(0xFF232625),
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isTop ? color : AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: e.value / maxVal),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: isTop ? 12 : 10,
                      backgroundColor: const Color(0xFFE8F5E9),
                      valueColor: AlwaysStoppedAnimation(
                        isTop
                            ? color
                            : color.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(ScanAnalyticsData data) {
    if (data.scans.length < 2) {
      return _emptyCard('More scans needed to show disease trends.');
    }

    final byWeek = <int, int>{};
    for (final s in data.scans.where((s) => !s.isHealthy)) {
      final d = s.createdAt;
      if (d == null) continue;
      final w = d.day ~/ 7 + d.month * 4;
      byWeek[w] = (byWeek[w] ?? 0) + 1;
    }

    final spots = <FlSpot>[];
    final keys = byWeek.keys.toList()..sort();
    for (var i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), (byWeek[keys[i]] ?? 0).toDouble()));
    }
    if (spots.isEmpty) {
      spots.addAll([const FlSpot(0, 0), const FlSpot(1, 0)]);
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.brightGreen.withValues(alpha: 0.25),
                    AppColors.brightGreen.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                height: 1.45,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecCard(({String title, String body, String iconKey}) rec) {
    final icon = switch (rec.iconKey) {
      'warning' => Icons.warning_amber_rounded,
      'scan' => Icons.document_scanner_outlined,
      'clean' => Icons.cleaning_services_outlined,
      'water' => Icons.water_drop_outlined,
      _ => Icons.lightbulb_outline_rounded,
    };
    return Container(
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
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.body,
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
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Column(
        children: [
          Icon(Icons.insights_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
        (i) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
