import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_analytics_service.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';
import 'package:flutter_plantiva/widgets/disease_distribution_icon.dart';
import 'package:flutter_plantiva/widgets/healthy_scan_rate_card.dart';

class ScanAnalyticsScreen extends StatefulWidget {
  const ScanAnalyticsScreen({super.key});

  @override
  State<ScanAnalyticsScreen> createState() => _ScanAnalyticsScreenState();
}

class _ScanAnalyticsScreenState extends State<ScanAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  static const _periods = [
    AnalyticsPeriod.week,
    AnalyticsPeriod.month,
    AnalyticsPeriod.allTime,
  ];

  final _service = ScanAnalyticsService();
  AnalyticsPeriod _period = AnalyticsPeriod.month;
  bool _loading = true;
  String? _error;
  List<ScanRecord> _allScans = [];
  late final AnimationController _animation;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic);
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final scans = await _service.fetchScans();
      if (!mounted) return;
      setState(() {
        _allScans = scans;
        _loading = false;
      });
      _animation.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Unable to load scan analytics. Check your connection and try again.';
      });
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  ScanAnalyticsData get _data => _service.buildAnalytics(_allScans, _period);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F1),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
            : _error != null
                ? _buildError()
                : FadeTransition(
                    opacity: _fade,
                    child: _buildContent(_data),
                  ),
      ),
    );
  }

  Widget _buildContent(ScanAnalyticsData data) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              HealthyScanRateCard(
                healthyCount: data.healthyCount,
                totalScans: data.totalScans,
                healthyRate: data.healthyRate,
              ),
              const SizedBox(height: 16),
              _buildSummary(data),
              const SizedBox(height: 24),
              _sectionTitle(
                'Disease Distribution',
                'Share of your recorded scans in this period',
              ),
              const SizedBox(height: 12),
              _buildDistribution(data),
              const SizedBox(height: 24),
              _sectionTitle(
                'Detection Trends',
                'Healthy and non-healthy results from actual scan dates',
              ),
              const SizedBox(height: 12),
              _buildTrend(data),
              const SizedBox(height: 24),
              _sectionTitle(
                'Recorded Scan Insights',
                'Observations based only on saved scan results',
              ),
              const SizedBox(height: 12),
              ...data.insights.map(_buildInsightCard),
              if (data.hasData) ...[
                const SizedBox(height: 14),
                _sectionTitle('Recommended Actions', null),
                const SizedBox(height: 12),
                ...data.recommendations.map(_buildRecommendationCard),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 10, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Analytics',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183C24),
                  ),
                ),
                Text(
                  'A summary of your recorded banana leaf scans',
                  maxLines: 2,
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh analytics',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _periods.map((period) {
            final selected = period == _period;
            return ChoiceChip(
              label: Text(period.label),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _period = period);
                _animation.forward(from: 0);
              },
              selectedColor: const Color(0xFFDCECDD),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? AppColors.green : const Color(0xFFDDE4DD),
              ),
              labelStyle: TextStyle(
                color: selected ? AppColors.green : AppColors.mutedText,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSummary(ScanAnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 340;
        final halfWidth =
            narrow ? constraints.maxWidth : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: halfWidth,
              icon: Icons.document_scanner_outlined,
              value: '${data.totalScans}',
              label: 'Total Scans',
            ),
            _SummaryCard(
              width: halfWidth,
              icon: Icons.warning_amber_rounded,
              value: '${data.diseasedCount}',
              label: 'Disease Detections',
              accent: const Color(0xFFB65A2B),
            ),
            _SummaryCard(
              width: constraints.maxWidth,
              icon: Icons.stacked_bar_chart_rounded,
              value: _displayCategory(data.mostCommonDisease),
              label: 'Most Detected Condition',
              horizontal: true,
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202622),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDistribution(ScanAnalyticsData data) {
    if (!data.hasData) return _emptyCard();

    final entries = DiseaseLabels.categories
        .map((category) => MapEntry(category, data.distribution[category] ?? 0))
        .toList()
      ..sort((a, b) {
        final countComparison = b.value.compareTo(a.value);
        return countComparison != 0
            ? countComparison
            : DiseaseLabels.categories
                .indexOf(a.key)
                .compareTo(DiseaseLabels.categories.indexOf(b.key));
      });

    return _surface(
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _DistributionRow(
              category: entries[i].key,
              count: entries[i].value,
              total: data.totalScans,
            ),
            if (i != entries.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text(
            'Percentages describe recorded scans only and do not represent farm-wide disease prevalence.',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrend(ScanAnalyticsData data) {
    if (data.trend.isEmpty) return _emptyCard();

    final highest = data.trend.fold<int>(0, (current, point) {
      return math.max(
        current,
        math.max(point.healthyCount, point.nonHealthyCount),
      );
    });

    return _surface(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      child: Column(
        children: [
          const Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Legend(color: AppColors.green, label: 'Healthy'),
              _Legend(color: Color(0xFFB65A2B), label: 'Non-healthy'),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = math.max(
                constraints.maxWidth,
                data.trend.length * 58.0,
              );
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: 230,
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: math.max(1, highest).toDouble() + 1,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0xFFE8ECE8),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, _) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (value, meta) {
                              if (value != value.roundToDouble()) {
                                return const SizedBox.shrink();
                              }
                              final index = value.toInt();
                              if (index < 0 || index >= data.trend.length) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  data.trend[index].label,
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
                      barGroups: List.generate(data.trend.length, (index) {
                        final point = data.trend[index];
                        return BarChartGroupData(
                          x: index,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: point.healthyCount.toDouble(),
                              width: 10,
                              color: AppColors.green,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: point.nonHealthyCount.toDouble(),
                              width: 10,
                              color: const Color(0xFFB65A2B),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    duration: const Duration(milliseconds: 500),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7DE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.insights_outlined, color: AppColors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF414743),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    ({String title, String body, String iconKey}) recommendation,
  ) {
    final icon = switch (recommendation.iconKey) {
      'warning' => Icons.warning_amber_rounded,
      'scan' => Icons.document_scanner_outlined,
      'clean' => Icons.cleaning_services_outlined,
      _ => Icons.lightbulb_outline_rounded,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7DE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: const TextStyle(
                    color: Color(0xFF252A27),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.body,
                  style: const TextStyle(
                    color: AppColors.mutedText,
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

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE7DE)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyCard() {
    return _surface(
      child: const Column(
        children: [
          Icon(Icons.query_stats_rounded, color: Color(0xFF9AA39C), size: 36),
          SizedBox(height: 10),
          Text(
            'No scan data yet',
            style: TextStyle(
              color: Color(0xFF2D332F),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Scan banana leaves to start seeing trends.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
              height: 1.4,
            ),
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

  String _displayCategory(String? category) {
    if (category == null) return '-';
    return category == 'Insect Pest' ? 'Insect Pest Damage' : category;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    this.accent = AppColors.green,
    this.horizontal = false,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      maxLines: horizontal ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF252A27),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
    final labelText = Text(
      label,
      maxLines: 2,
      style: const TextStyle(
        color: AppColors.mutedText,
        fontSize: 12,
        height: 1.25,
      ),
    );

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7DE)),
      ),
      child: horizontal
          ? Row(
              children: [
                _SummaryIcon(icon: icon, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [valueText, const SizedBox(height: 5), labelText],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryIcon(icon: icon, color: accent),
                const SizedBox(height: 12),
                valueText,
                const SizedBox(height: 3),
                labelText,
              ],
            ),
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  const _SummaryIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.category,
    required this.count,
    required this.total,
  });

  final String category;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    final percentage = (fraction * 100).round();
    final color = DiseaseLabels.colorFor(category);
    final label = category == 'Insect Pest' ? 'Insect Pest Damage' : category;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DiseaseDistributionIcon(
              category: category,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF303632),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count  |  $percentage%',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFFEDF1ED)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: ColoredBox(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
