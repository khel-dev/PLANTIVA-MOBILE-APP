import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/screens/scan_details_screen.dart';
import 'package:flutter_plantiva/services/scan_history_service.dart';
import 'package:flutter_plantiva/utils/page_transitions.dart';
import 'package:flutter_plantiva/widgets/scan_image_widget.dart';

class RecentScanCard extends StatefulWidget {
  const RecentScanCard({
    super.key,
    required this.scan,
    this.enableSwipeDelete = true,
    this.animationDelay = 0,
  });

  final ScanRecord scan;
  final bool enableSwipeDelete;
  final int animationDelay;

  @override
  State<RecentScanCard> createState() => _RecentScanCardState();
}

class _RecentScanCardState extends State<RecentScanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete scan?'),
        content: const Text(
          'This diagnosis report will be permanently removed from your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ScanHistoryService.deleteScan(
        widget.scan.id,
        imageUrl: widget.scan.imageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan deleted.')),
        );
      }
    }
  }

  void _openDetails() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      AppTransitions.fadeSlide(
        ScanDetailsScreen(scan: widget.scan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    final chips = chipsForScanLabel(scan.label);
    final time = relativeScanTime(scan.createdAt);

    final card = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1),
        onTapCancel: () => setState(() => _scale = 1),
        onTap: _openDetails,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD0E9D4)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(19),
                  ),
                  child: ScanImageWidget(
                    imagePath: scan.imagePath,
                    imageUrl: scan.imageUrl,
                    width: 96,
                    height: 96,
                    borderRadius: 0,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shortDiseaseName(scan.label),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF232625),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: chips.chipColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                scan.isHealthy ? 'Healthy' : 'Detected',
                                style: TextStyle(
                                  color: chips.chipTextColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.speed_rounded,
                              size: 14,
                              color: AppColors.green.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              scan.confidence.isEmpty
                                  ? '—'
                                  : scan.confidence,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB0B5B2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.enableSwipeDelete) return card;

    return Dismissible(
      key: ValueKey(scan.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: card,
      ),
    );
  }
}

class RecentScansEmptyState extends StatelessWidget {
  const RecentScansEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              size: 36,
              color: AppColors.green.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No scans yet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF232625),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the scan button to analyze a banana leaf.\nYour diagnosis reports will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
