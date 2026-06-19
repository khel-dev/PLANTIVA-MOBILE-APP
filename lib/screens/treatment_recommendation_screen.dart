import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/disease_guide/disease_guide_screen.dart';
import 'package:flutter_plantiva/screens/homepage.dart';
import 'package:flutter_plantiva/screens/scanner_screen.dart';
import 'package:flutter_plantiva/widgets/scan_image_widget.dart';

class TreatmentRecommendationScreen extends StatefulWidget {
  const TreatmentRecommendationScreen({
    super.key,
    required this.label,
    required this.confidence,
    required this.severity,
    required this.summary,
    required this.recommendation,
    required this.isHealthy,
    this.imagePath,
    this.imageUrl,
    this.savedScanId,
  });

  final String label;
  final String confidence;
  final String severity;
  final String summary;
  final String recommendation;
  final bool isHealthy;
  final String? imagePath;
  final String? imageUrl;
  final String? savedScanId;

  @override
  State<TreatmentRecommendationScreen> createState() =>
      _TreatmentRecommendationScreenState();
}

class _TreatmentRecommendationScreenState
    extends State<TreatmentRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_fade);
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Color get _severityColor {
    switch (widget.severity) {
      case 'High':
        return const Color(0xFFD32F2F);
      case 'Moderate':
        return const Color(0xFFF57F17);
      case 'Low':
        return const Color(0xFF388E3C);
      default:
        return AppColors.green;
    }
  }

  List<String> get _careTips {
    final label = widget.label.toLowerCase();
    if (widget.isHealthy) {
      return const [
        'Continue weekly scouting and keep this result as a healthy reference.',
        'Maintain clean tools, balanced fertilization, and good drainage.',
        'Scan again after heavy rain or when new leaf symptoms appear.',
      ];
    }
    if (label.contains('panama') || label.contains('moko')) {
      return const [
        'Avoid moving soil, tools, or planting material from the affected area.',
        'Mark and isolate the suspected plant or mat while waiting for confirmation.',
        'Ask the Municipal Agriculture Office or an agriculture technician before removing plants.',
      ];
    }
    if (label.contains('sigatoka')) {
      return const [
        'Remove severely infected leaves only when safe and practical.',
        'Improve spacing and airflow so leaves dry faster after rain.',
        'Use locally approved products only as directed on the product label.',
      ];
    }
    if (label.contains('mosaic') || label.contains('virus')) {
      return const [
        'Do not use suspected infected plants as planting material.',
        'Monitor nearby plants for mosaic patterns or abnormal streaking.',
        'Manage aphids and other sap-feeding insects using local IPM guidance.',
      ];
    }
    if (label.contains('insect')) {
      return const [
        'Inspect the underside of leaves for insects, eggs, or feeding marks.',
        'Use integrated pest management before applying any pesticide.',
        'Follow product label instructions and local agriculture guidance.',
      ];
    }
    return const [
      'Document the symptoms and scan date.',
      'Keep tools clean between plants.',
      'Consult an agriculture technician if symptoms spread.',
    ];
  }

  List<String> get _expertSignals => const [
        'Symptoms are spreading to nearby banana plants.',
        'The plant shows wilting, internal browning, or rapid collapse.',
        'You are unsure which treatment is safe for your farm conditions.',
      ];

  void _openDiseaseGuide() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Disease Guide'),
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
          ),
          body: const SafeArea(child: DiseaseGuideScreen()),
        ),
      ),
    );
  }

  void _backHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  void _scanAgain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const ScannerScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final confidenceValue =
        double.tryParse(widget.confidence.replaceAll('%', '')) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    label: widget.label,
                    imagePath: widget.imagePath,
                    imageUrl: widget.imageUrl,
                    severity: widget.severity,
                    severityColor: _severityColor,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Confidence',
                                value: '${confidenceValue.toStringAsFixed(0)}%',
                                icon: Icons.speed_rounded,
                                color: AppColors.green,
                                progress: confidenceValue / 100,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                title: 'Severity',
                                value: widget.severity,
                                icon: widget.isHealthy
                                    ? Icons.check_circle_outline
                                    : Icons.warning_amber_rounded,
                                color: _severityColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Recommended Treatment',
                          icon: Icons.medical_services_outlined,
                          child: Text(widget.recommendation, style: _body),
                        ),
                        _SectionCard(
                          title: 'Prevention and Care Tips',
                          icon: Icons.shield_outlined,
                          child: _BulletList(items: _careTips),
                        ),
                        _SectionCard(
                          title: 'Farmer-Friendly Explanation',
                          icon: Icons.eco_outlined,
                          child: Text(widget.summary, style: _body),
                        ),
                        _SectionCard(
                          title: 'When to Consult an Expert',
                          icon: Icons.support_agent_outlined,
                          child: _BulletList(items: _expertSignals),
                        ),
                        _SectionCard(
                          title: 'Saved Scan',
                          icon: widget.savedScanId == null
                              ? Icons.bookmark_border
                              : Icons.bookmark_added,
                          child: Text(
                            widget.savedScanId == null
                                ? 'This recommendation can still be used, but the scan was not confirmed as saved.'
                                : 'This diagnosis is saved in your scan history.',
                            style: _body,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _scanAgain,
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: const Text('Scan Again'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _backHome,
                                icon: const Icon(Icons.home_outlined),
                                label: const Text('Back Home'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openDiseaseGuide,
                            icon: const Icon(Icons.menu_book_outlined),
                            label: const Text('Open Disease Guide'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _body = TextStyle(
    color: Color(0xFF3E4841),
    height: 1.55,
    fontSize: 14,
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.imagePath,
    required this.imageUrl,
    required this.severity,
    required this.severityColor,
  });

  final String label;
  final String? imagePath;
  final String? imageUrl;
  final String severity;
  final Color severityColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScanImageWidget(
          imagePath: imagePath,
          imageUrl: imageUrl,
          width: double.infinity,
          height: 310,
          borderRadius: 0,
        ),
        Container(
          height: 310,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.74),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 8,
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$severity severity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Treatment recommendation for banana farmers',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                color: color,
                backgroundColor: color.withValues(alpha: 0.14),
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0E9D4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1B4332),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.brightGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF3E4841),
                        height: 1.45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
