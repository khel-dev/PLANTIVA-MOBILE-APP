import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/data/disease_guide_data.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/services/disease_guide_service.dart';
import 'package:flutter_plantiva/utils/page_transitions.dart';
import 'package:flutter_plantiva/utils/plantiva_feedback.dart';
import 'package:flutter_plantiva/widgets/disease_guide/disease_card.dart';
import 'package:flutter_plantiva/widgets/disease_guide/disease_thumbnail.dart';

class DiseaseDetailScreen extends StatefulWidget {
  const DiseaseDetailScreen({
    super.key,
    required this.disease,
    this.onStateChanged,
  });

  final DiseaseGuideItem disease;
  final VoidCallback? onStateChanged;

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final _service = DiseaseGuideService();
  final _resourceLauncher = DiseaseGuideResourceLauncher();
  bool _bookmarked = false;
  bool _studied = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.markViewed(widget.disease.id);
    final b = await _service.isBookmarked(widget.disease.id);
    final studied = (await _service.getStudied()).contains(widget.disease.id);
    if (mounted) {
      setState(() {
        _bookmarked = b;
        _studied = studied;
      });
    }
    widget.onStateChanged?.call();
  }

  Future<void> _toggleBookmark() async {
    await _service.toggleBookmark(widget.disease.id);
    if (mounted) {
      final nextBookmarked = !_bookmarked;
      setState(() => _bookmarked = nextBookmarked);
      PlantivaFeedback.show(
        context,
        message: nextBookmarked
            ? 'Added to saved diseases.'
            : 'Removed from saved diseases.',
        type: nextBookmarked
            ? PlantivaFeedbackType.success
            : PlantivaFeedbackType.info,
      );
    }
    widget.onStateChanged?.call();
  }

  Future<void> _markStudied() async {
    await _service.markStudied(widget.disease.id);
    if (mounted) setState(() => _studied = true);
    widget.onStateChanged?.call();
    if (mounted) {
      PlantivaFeedback.show(
        context,
        message: 'Marked as studied - great work!',
        type: PlantivaFeedbackType.success,
      );
    }
  }

  Future<void> _openResource(Uri? uri) async {
    final opened = await _resourceLauncher.open(uri);
    if (!opened && mounted) {
      PlantivaFeedback.show(
        context,
        message: 'Unable to open this learning resource right now.',
        type: PlantivaFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.disease;
    final screen = MediaQuery.sizeOf(context);
    final heroHeight = (screen.height * 0.32).clamp(220.0, 300.0).toDouble();
    final horizontalPadding = screen.width < 350 ? 14.0 : 18.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leadingWidth: 72,
            leading: _headerButton(
              key: const ValueKey('disease_detail_back_button'),
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _headerButton(
                key: const ValueKey('disease_detail_bookmark_button'),
                onPressed: _toggleBookmark,
                icon: _bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                tooltip: _bookmarked ? 'Remove saved guide' : 'Save guide',
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DiseaseThumbnail(
                    disease: d,
                    height: heroHeight,
                    borderRadius: 0,
                    heroTag: 'disease_img_${d.id}',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.28),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.16),
                        ],
                        stops: const [0, 0.45, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              22,
              horizontalPadding,
              40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  d.name,
                  style: TextStyle(
                    color: const Color(0xFF202422),
                    fontSize: screen.width < 350 ? 25 : 29,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (d.scientificName != null &&
                    d.scientificName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    d.scientificName!,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 14,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(d.category.label, d.category.color),
                    _supportChip(d),
                  ],
                ),
                const SizedBox(height: 18),
                _card(
                  child: Text(
                    d.summary,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  d.isAiDetectable
                      ? 'PLANTIVA can screen this visual category, but field confirmation may still be needed.'
                      : 'This guide is educational only and is not identified by the PLANTIVA scanner.',
                  key: const ValueKey('disease_detail_support_note'),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                _sectionTitle('Overview'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.overview, style: _body),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                d.whyDangerous,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _sectionTitle(
                  d.category == DiseaseCategory.healthy
                      ? 'Healthy Leaf Signs'
                      : 'Common Signs',
                ),
                ...d.symptoms.map(_symptomCard),
                _sectionTitle(
                  d.category == DiseaseCategory.healthy
                      ? 'What Supports Healthy Growth'
                      : 'How It Spreads or Develops',
                ),
                ...d.causes.map(_causeCard),
                _sectionTitle('What Farmers Can Do'),
                ...d.treatments.map(_treatmentTile),
                _sectionTitle('Prevention & Management'),
                _card(
                  child: Column(
                    children: d.prevention
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.brightGreen,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(p, style: _body)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                _sectionTitle('Quick Facts'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: d.quickFacts
                      .map(
                        (f) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD0E9D4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              Text(
                                f.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Farmer Tips'),
                ...d.farmerTips.map(_tipCard),
                if (d.sources.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _sectionTitle('Sources & References'),
                  _referencesCard(d.sources),
                ],
                if (d.videos.isNotEmpty) ...[
                  _sectionTitle('Trusted Learning Resource'),
                  ...d.videos.map(_resourceCard),
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Internet connection required to open external resources.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (!_studied)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _markStudied,
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Mark as Studied'),
                    ),
                  ),
                const SizedBox(height: 20),
                _sectionTitle('Related Banana Guides'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: d.relatedIds.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final related = DiseaseGuideData.byId(d.relatedIds[i]);
                      if (related == null) return const SizedBox.shrink();
                      return SizedBox(
                        width: 160,
                        child: DiseaseCard(
                          disease: related,
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              AppTransitions.fadeSlide(
                                DiseaseDetailScreen(
                                  disease: related,
                                  onStateChanged: widget.onStateChanged,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static const _body = TextStyle(height: 1.5, fontSize: 15);

  Widget _headerButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: IconButton(
          key: key,
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF202422),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _supportChip(DiseaseGuideItem disease) {
    final supported = disease.isAiDetectable;
    final color = supported ? AppColors.green : const Color(0xFF5F6B64);

    return Container(
      key: const ValueKey('disease_detail_support_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            supported
                ? Icons.document_scanner_outlined
                : Icons.menu_book_outlined,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              supported ? 'Supported by PLANTIVA Scan' : 'Educational Guide',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _symptomCard(DiseaseSymptom s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s.icon, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  s.description,
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

  Widget _causeCard(DiseaseCause c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            AppColors.lightBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Row(
        children: [
          Icon(c.icon, color: AppColors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  c.description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _treatmentTile(DiseaseTreatment t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Text(
          t.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        children: t.steps
            .map(
              (s) => ListTile(
                dense: true,
                leading: const Icon(Icons.arrow_right, color: AppColors.green),
                title: Text(s, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _resourceCard(DiseaseVideo resource) {
    return Semantics(
      button: true,
      label: 'Open ${resource.title}. Internet connection required.',
      child: InkWell(
        onTap: () => _openResource(resource.uri),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.green,
                  size: 38,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.channel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.open_in_new, color: AppColors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipCard(String tip) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF9C4).withValues(alpha: 0.5),
            const Color(0xFFE8F5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFF57F17)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.grey.shade800,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referencesCard(List<DiseaseSource> sources) {
    return _card(
      child: Column(
        children: List.generate(
          sources.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == sources.length - 1 ? 0 : 10,
            ),
            child: Semantics(
              button: sources[index].uri != null,
              label: 'Open source: ${sources[index].name}',
              child: InkWell(
                onTap: sources[index].uri == null
                    ? null
                    : () => _openResource(sources[index].uri),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.article_outlined,
                          size: 20,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sources[index].name,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (sources[index].uri != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: AppColors.green,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
