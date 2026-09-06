import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/data/treatment_guidance_data.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/models/treatment_guidance.dart';
import 'package:flutter_plantiva/screens/disease_guide/disease_guide_screen.dart';
import 'package:flutter_plantiva/screens/homepage.dart';
import 'package:flutter_plantiva/screens/scanner_screen.dart';
import 'package:flutter_plantiva/services/disease_guide_service.dart';
import 'package:flutter_plantiva/utils/plantiva_feedback.dart';
import 'package:flutter_plantiva/widgets/scan_image_widget.dart';

class TreatmentRecommendationScreen extends StatefulWidget {
  const TreatmentRecommendationScreen({
    super.key,
    required this.label,
    required this.confidence,
    required this.summary,
    required this.recommendation,
    required this.isHealthy,
    this.imagePath,
    this.imageUrl,
    this.imageBase64,
    this.savedScanId,
    this.resourceLauncher,
  });

  final String label;
  final String confidence;

  // Preserved for route compatibility. Recognized classes use reviewed local
  // guidance so historical Firestore text cannot override current safety copy.
  final String summary;
  final String recommendation;
  final bool isHealthy;
  final String? imagePath;
  final String? imageUrl;
  final String? imageBase64;
  final String? savedScanId;
  final DiseaseGuideResourceLauncher? resourceLauncher;

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
  late final TreatmentGuidance _guidance;
  late final DiseaseGuideResourceLauncher _resourceLauncher;

  @override
  void initState() {
    super.initState();
    _guidance = TreatmentGuidanceData.resolve(widget.label);
    _resourceLauncher =
        widget.resourceLauncher ?? DiseaseGuideResourceLauncher();
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

  Future<void> _openSource(DiseaseSource source) async {
    final opened = await _resourceLauncher.open(source.uri);
    if (!mounted || opened) return;
    PlantivaFeedback.show(
      context,
      message: 'Unable to open this source. Check your internet connection.',
      type: PlantivaFeedbackType.error,
    );
  }

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
    final isHealthy = _guidance.isHealthy;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F1),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: CustomScrollView(
              key: const Key('treatment-guidance-scroll'),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    label: _guidance.normalizedClass,
                    imagePath: widget.imagePath,
                    imageUrl: widget.imageUrl,
                    imageBase64: widget.imageBase64,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        _guidance.title,
                        style: const TextStyle(
                          color: Color(0xFF173B29),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_guidance.summary, style: _body),
                      if (_guidance.isBroadCategory) ...[
                        const SizedBox(height: 14),
                        const _NoticeCard(
                          icon: Icons.manage_search_rounded,
                          title: 'Broad damage category',
                          message:
                              'The exact pest species was not identified. Inspect and confirm the pest before selecting a targeted control.',
                        ),
                      ],
                      const SizedBox(height: 14),
                      _MetricCard(
                        value: '${confidenceValue.toStringAsFixed(0)}%',
                        progress: confidenceValue / 100,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(2, 8, 2, 14),
                        child: Text(
                          'Classification confidence shows the model match. It does not measure disease severity or change this guidance.',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      _GuidanceSection(
                        title:
                            isHealthy ? 'Keep Monitoring' : 'Immediate Actions',
                        icon: isHealthy
                            ? Icons.visibility_outlined
                            : Icons.flag_outlined,
                        items: _guidance.immediateActions,
                      ),
                      _GuidanceSection(
                        title: isHealthy ? 'Good Practices' : 'Management',
                        icon: isHealthy
                            ? Icons.eco_outlined
                            : Icons.agriculture_outlined,
                        items: _guidance.management,
                      ),
                      _GuidanceSection(
                        title: 'Prevention',
                        icon: Icons.shield_outlined,
                        items: _guidance.prevention,
                      ),
                      _GuidanceSection(
                        title: isHealthy
                            ? 'When to Seek Advice'
                            : 'When to Seek Help',
                        icon: Icons.support_agent_outlined,
                        items: _guidance.whenToSeekHelp,
                      ),
                      _NoticeCard(
                        icon: Icons.info_outline_rounded,
                        title: 'Important Note',
                        message: _guidance.importantNote,
                      ),
                      if (_guidance.sources.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SourcesCard(
                          sources: _guidance.sources,
                          onOpen: _openSource,
                        ),
                      ],
                      const SizedBox(height: 14),
                      _SavedStatus(savedScanId: widget.savedScanId),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 350;
                          final buttons = [
                            OutlinedButton.icon(
                              onPressed: _scanAgain,
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Scan Again'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _backHome,
                              icon: const Icon(Icons.home_outlined),
                              label: const Text('Back Home'),
                            ),
                          ];
                          if (narrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buttons[0],
                                const SizedBox(height: 10),
                                buttons[1],
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: buttons[0]),
                              const SizedBox(width: 10),
                              Expanded(child: buttons[1]),
                            ],
                          );
                        },
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
                    ]),
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
    required this.imageBase64,
  });

  final String label;
  final String? imagePath;
  final String? imageUrl;
  final String? imageBase64;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = (width * 0.72).clamp(225.0, 300.0);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ScanImageWidget(
            imagePath: imagePath,
            imageUrl: imageUrl,
            imageBase64: imageBase64,
            width: width,
            height: height,
            borderRadius: 0,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.76),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 8,
            child: IconButton.filledTonal(
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.92),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'IMAGE-BASED SCREENING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width < 350 ? 22 : 26,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Reviewed educational guidance for banana farmers',
                  maxLines: 2,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.progress});

  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Classification Confidence',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    color: AppColors.green,
                    backgroundColor: const Color(0xFFDCEADE),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  const _GuidanceSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, icon: icon),
          const SizedBox(height: 12),
          _BulletList(items: items),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7D6A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B6508)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5F470E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(message, style: _TreatmentRecommendationScreenState._body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({required this.sources, required this.onOpen});

  final List<DiseaseSource> sources;
  final ValueChanged<DiseaseSource> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Sources',
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 6),
          const Text(
            'Guidance text is available offline. Opening a source requires an internet connection.',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ...sources.map(
            (source) => ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 8,
              title: Text(
                source.name,
                style: const TextStyle(
                  color: Color(0xFF244D36),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(
                Icons.open_in_new_rounded,
                size: 20,
                color: AppColors.green,
              ),
              onTap: () => onOpen(source),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedStatus extends StatelessWidget {
  const _SavedStatus({required this.savedScanId});

  final String? savedScanId;

  @override
  Widget build(BuildContext context) {
    final saved = savedScanId != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Icon(
            saved ? Icons.bookmark_added : Icons.bookmark_border,
            color: AppColors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              saved
                  ? 'This classification result is saved in your scan history.'
                  : 'This scan was not confirmed as saved.',
              style: _TreatmentRecommendationScreenState._body,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      color: AppColors.brightGreen,
                      size: 7,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: _TreatmentRecommendationScreenState._body,
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

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: const Color(0xFFDDE7DF)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.035),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);
