import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_analytics_service.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = ScanAnalyticsService();
  bool _loading = true;
  List<_NotifItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scans = await _service.fetchScans(limit: 30);
    if (!mounted) return;
    setState(() {
      _items = _buildNotifications(scans);
      _loading = false;
    });
  }

  List<_NotifItem> _buildNotifications(List<ScanRecord> scans) {
    final items = <_NotifItem>[];
    final fmt = DateFormat('MMM d, h:mm a');

    if (scans.isEmpty) {
      items.add(
        const _NotifItem(
          title: 'Welcome to PLANTIVA Alerts',
          body: 'Scan your first banana leaf to receive disease alerts and crop health updates.',
          icon: Icons.eco_rounded,
          color: AppColors.green,
          isNew: true,
        ),
      );
      items.add(
        const _NotifItem(
          title: 'Weekly scan reminder',
          body: 'Regular scanning helps detect Black Sigatoka and Panama disease early.',
          icon: Icons.notifications_active_rounded,
          color: Color(0xFF2E7D32),
          isNew: false,
        ),
      );
      return items;
    }

    for (final s in scans.take(8)) {
      final ts = s.createdAt;
      if (s.isHealthy) {
        items.add(
          _NotifItem(
            title: 'Healthy leaf detected',
            body:
                'Confidence ${s.confidenceValue.round()}% — ${ts != null ? fmt.format(ts) : 'Recent'}',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF2E7D32),
            isNew: items.length < 2,
          ),
        );
      } else {
        items.add(
          _NotifItem(
            title: '${s.category} alert',
            body:
                'Detected with ${s.confidenceValue.round()}% confidence. Review treatment options in the Diseases guide.',
            icon: Icons.warning_amber_rounded,
            color: DiseaseLabels.colorFor(s.category),
            isNew: items.length < 3,
          ),
        );
      }
    }

    final diseased = scans.where((s) => !s.isHealthy).length;
    if (diseased >= 3) {
      items.insert(
        0,
        _NotifItem(
          title: 'Field attention needed',
          body:
              '$diseased disease detections in your recent scans. Consider increasing inspection frequency.',
          icon: Icons.agriculture_rounded,
          color: const Color(0xFFEF6C00),
          isNew: true,
        ),
      );
    }

    items.add(
      const _NotifItem(
        title: 'Keep scanning this week',
        body: 'Consistent monitoring improves early detection and protects your banana yield.',
        icon: Icons.calendar_today_rounded,
        color: AppColors.green,
        isNew: false,
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Field Alerts',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        Text(
                          'Crop health updates & scan reminders',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_items.where((i) => i.isNew).length} new',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final n = _items[i];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 350 + i * 60),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: n.isNew
                                    ? AppColors.brightGreen.withValues(alpha: 0.4)
                                    : const Color(0xFFD0E9D4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 16,
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: n.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(n.icon, color: n.color),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: Color(0xFF232625),
                                              ),
                                            ),
                                          ),
                                          if (n.isNew)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.brightGreen,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        n.body,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          height: 1.45,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifItem {
  const _NotifItem({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.isNew,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final bool isNew;
}
