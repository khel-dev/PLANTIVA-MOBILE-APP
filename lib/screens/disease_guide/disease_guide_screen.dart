import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/data/disease_guide_data.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/screens/disease_guide/disease_detail_screen.dart';
import 'package:flutter_plantiva/services/disease_guide_service.dart';
import 'package:flutter_plantiva/utils/page_transitions.dart';
import 'package:flutter_plantiva/widgets/disease_guide/disease_card.dart';
import 'package:flutter_plantiva/widgets/plantiva_decorated_background.dart';

enum _GuideScope { all, scanSupported, educational, saved }

class DiseaseGuideScreen extends StatefulWidget {
  const DiseaseGuideScreen({super.key});

  @override
  State<DiseaseGuideScreen> createState() => _DiseaseGuideScreenState();
}

class _DiseaseGuideScreenState extends State<DiseaseGuideScreen> {
  final _search = TextEditingController();
  final _service = DiseaseGuideService();
  DiseaseCategory? _filter;
  _GuideScope _scope = _GuideScope.all;
  Set<String> _bookmarks = {};
  Set<String> _viewed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
    _search.addListener(() => setState(() {}));
  }

  Future<void> _loadState() async {
    final b = await _service.getBookmarks();
    final v = await _service.getViewed();
    if (mounted) {
      setState(() {
        _bookmarks = b;
        _viewed = v;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DiseaseGuideItem> get _filtered {
    var list = DiseaseGuideData.all;
    final q = _search.text.trim().toLowerCase();

    if (_scope == _GuideScope.saved) {
      list = list.where((d) => _bookmarks.contains(d.id)).toList();
    } else if (_scope == _GuideScope.scanSupported) {
      list = list.where((d) => d.isAiDetectable).toList();
    } else if (_scope == _GuideScope.educational) {
      list = list.where((d) => !d.isAiDetectable).toList();
    }

    if (_filter != null) {
      list = list.where((d) => d.category == _filter).toList();
    }

    if (q.isNotEmpty) {
      list = list.where((d) {
        if (d.name.toLowerCase().contains(q)) return true;
        if (d.shortName.toLowerCase().contains(q)) return true;
        if (d.summary.toLowerCase().contains(q)) return true;
        for (final kw in d.searchKeywords) {
          if (kw.contains(q)) return true;
        }
        for (final s in d.symptoms) {
          if (s.title.toLowerCase().contains(q)) return true;
        }
        return false;
      }).toList();
    }

    return list;
  }

  Future<void> _openDetail(DiseaseGuideItem disease) async {
    await Navigator.of(context).push(
      AppTransitions.fadeSlide(
        DiseaseDetailScreen(
          disease: disease,
          onStateChanged: _loadState,
        ),
      ),
    );
    await _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final guideIds = DiseaseGuideData.all.map((d) => d.id).toSet();
    final explored = _viewed.intersection(guideIds).length;
    final saved = _bookmarks.intersection(guideIds).length;
    final total = DiseaseGuideData.all.length;

    return PlantivaDecoratedBackground(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disease Guide',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                            color: Color(0xFF202422),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Learn to identify, prevent, and manage banana diseases',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _progressCard(explored, saved, total),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _search,
                          decoration: InputDecoration(
                            hintText: 'Search diseases, symptoms, keywords...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChip(
                                'All',
                                _scope == _GuideScope.all && _filter == null,
                                () {
                                  setState(() {
                                    _filter = null;
                                    _scope = _GuideScope.all;
                                  });
                                },
                              ),
                              _filterChip(
                                'Scanner Supported',
                                _scope == _GuideScope.scanSupported,
                                () => setState(() {
                                  _scope = _GuideScope.scanSupported;
                                  _filter = null;
                                }),
                                icon: Icons.document_scanner_outlined,
                              ),
                              _filterChip(
                                'Educational',
                                _scope == _GuideScope.educational,
                                () => setState(() {
                                  _scope = _GuideScope.educational;
                                  _filter = null;
                                }),
                                icon: Icons.menu_book_outlined,
                              ),
                              _filterChip(
                                'Saved',
                                _scope == _GuideScope.saved,
                                () => setState(() {
                                  _scope = _GuideScope.saved;
                                  _filter = null;
                                }),
                                icon: Icons.bookmark_outline,
                              ),
                              ...DiseaseCategory.values.map(
                                (c) => _filterChip(
                                  c.label,
                                  _filter == c,
                                  () => setState(() {
                                    _filter = c;
                                    _scope = _GuideScope.all;
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => DiseaseCard(
                          disease: filtered[i],
                          isBookmarked: _bookmarks.contains(filtered[i].id),
                          isViewed: _viewed.contains(filtered[i].id),
                          animationDelay: (i % 4) * 60,
                          onTap: () => _openDetail(filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _progressCard(int explored, int saved, int total) {
    final pct = total == 0 ? 0.0 : explored / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E8D9)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_outlined, color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Guides viewed',
                        style: TextStyle(
                          color: Color(0xFF202422),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '$explored / $total',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0, 1),
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE7EFE8),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.brightGreen),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$saved saved ${saved == 1 ? 'guide' : 'guides'}',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    bool active,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: icon != null
            ? Icon(icon, size: 16, color: active ? AppColors.green : null)
            : null,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.green.withValues(alpha: 0.15),
        checkmarkColor: AppColors.green,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _scope == _GuideScope.saved
                  ? Icons.bookmark_border
                  : Icons.menu_book_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _scope == _GuideScope.saved
                  ? 'No saved guides yet'
                  : 'No diseases match your search',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _scope == _GuideScope.saved
                  ? 'Bookmark disease guides while reading to find them here.'
                  : 'Search for a disease or symptom to begin learning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
