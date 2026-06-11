import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_history_service.dart';
import 'package:flutter_plantiva/widgets/recent_scan_card.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final _search = TextEditingController();
  String _filter = 'All';
  bool _newestFirst = true;
  List<ScanRecord> _scans = [];
  bool _loading = true;

  static const _filters = [
    'All',
    'Healthy',
    'Black Sigatoka',
    'Panama Disease',
    'Yellow Sigatoka',
    'Moko Disease',
    'Bract Mosaic Virus',
    'Insect Pest',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final scans = await ScanHistoryService.fetchScans(limit: 200);
    if (mounted) {
      setState(() {
        _scans = scans;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ScanRecord> get _filtered {
    var list = List<ScanRecord>.from(_scans);
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((s) => s.label.toLowerCase().contains(q))
          .toList();
    }
    if (_filter != 'All') {
      list = list.where((s) {
        final l = s.label.toLowerCase();
        switch (_filter) {
          case 'Healthy':
            return s.isHealthy;
          case 'Black Sigatoka':
            return l.contains('black sigatoka');
          case 'Panama Disease':
            return l.contains('panama');
          case 'Yellow Sigatoka':
            return l.contains('yellow sigatoka');
          case 'Moko Disease':
            return l.contains('moko');
          case 'Bract Mosaic Virus':
            return l.contains('bract mosaic') || l.contains('mosaic');
          case 'Insect Pest':
            return l.contains('insect');
          default:
            return true;
        }
      }).toList();
    }
    list.sort((a, b) {
      final da = a.createdAt ?? DateTime(2000);
      final db = b.createdAt ?? DateTime(2000);
      return _newestFirst ? db.compareTo(da) : da.compareTo(db);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan History',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202422),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _newestFirst = !_newestFirst),
                    icon: Icon(
                      _newestFirst
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                    ),
                    tooltip: _newestFirst ? 'Newest first' : 'Oldest first',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search by disease name…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final active = _filter == f;
                  return FilterChip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    selected: active,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.green.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.green,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: RecentScansEmptyState())
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) => RecentScanCard(
                              scan: filtered[i],
                              animationDelay: (i % 5) * 40,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
