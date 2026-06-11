import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/data/disease_guide_data.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/services/disease_guide_service.dart';
import 'package:flutter_plantiva/utils/page_transitions.dart';
import 'package:flutter_plantiva/widgets/disease_guide/disease_card.dart';
import 'package:flutter_plantiva/widgets/disease_guide/disease_thumbnail.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (mounted) setState(() => _bookmarked = !_bookmarked);
    widget.onStateChanged?.call();
  }

  Future<void> _markStudied() async {
    await _service.markStudied(widget.disease.id);
    if (mounted) setState(() => _studied = true);
    widget.onStateChanged?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as studied — great work!')),
      );
    }
  }

  Future<void> _openVideo(DiseaseVideo video) async {
    final uri = Uri.parse(video.watchUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.disease;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.green,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: _toggleBookmark,
                icon: Icon(
                  _bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DiseaseThumbnail(
                    disease: d,
                    height: 260,
                    borderRadius: 0,
                    heroTag: 'disease_img_${d.id}',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _chip(d.category.label, d.category.color),
                        const SizedBox(height: 8),
                        Text(
                          d.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _chip(d.risk.label, d.risk.color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  d.summary,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
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
                          color: d.risk.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: d.risk.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: d.risk.color),
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
                _sectionTitle('Visual Symptoms'),
                ...d.symptoms.map(_symptomCard),
                _sectionTitle('Causes'),
                ...d.causes.map(_causeCard),
                _sectionTitle('Prevention Guide'),
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
                _sectionTitle('Treatment & Management'),
                ...d.treatments.map(_treatmentTile),
                _sectionTitle('Learn More Through Video'),
                ...d.videos.map(_videoCard),
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
                _sectionTitle('Similar Banana Diseases'),
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
        gradient: LinearGradient(
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
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _videoCard(DiseaseVideo v) {
    return GestureDetector(
      onTap: () => _openVideo(v),
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
                Icons.play_circle_fill,
                color: AppColors.green,
                size: 44,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${v.channel} • ${v.duration}',
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
}
