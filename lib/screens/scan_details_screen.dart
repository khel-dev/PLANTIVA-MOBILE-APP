import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_history_service.dart';
import 'package:flutter_plantiva/utils/scan_diagnosis_helper.dart';
import 'package:flutter_plantiva/widgets/scan_image_widget.dart';

class ScanDetailsScreen extends StatefulWidget {
  const ScanDetailsScreen({super.key, required this.scan});

  final ScanRecord scan;

  @override
  State<ScanDetailsScreen> createState() => _ScanDetailsScreenState();
}

class _ScanDetailsScreenState extends State<ScanDetailsScreen> {
  List<ScanRecord> _related = [];
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    final related = await ScanHistoryService.relatedScans(
      widget.scan.category,
      excludeId: widget.scan.id,
    );
    if (mounted) {
      setState(() {
        _related = related;
        _loadingRelated = false;
      });
    }
  }

  ScanRecord get scan => widget.scan;

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High':
        return const Color(0xFFD32F2F);
      case 'Moderate':
        return const Color(0xFFB8860B);
      case 'Low':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF388E3C);
    }
  }

  Future<void> _shareReport() async {
    final date = scan.createdAt != null
        ? DateFormat('MMM d, yyyy h:mm a').format(scan.createdAt!)
        : 'Unknown date';
    final text = '''
PLANTIVA Diagnosis Report
━━━━━━━━━━━━━━━━━━━━
Disease: ${scan.label}
Confidence: ${scan.confidence}
Severity: ${scan.effectiveSeverity}
Scanned: $date

Summary:
${scan.effectiveSummary}

Recommendations:
${scan.effectiveRecommendations}
''';
    await Share.share(text, subject: 'PLANTIVA Scan Report — ${scan.label}');
  }

  Future<void> _savePdf() async {
    final pdf = pw.Document();
    final date = scan.createdAt != null
        ? DateFormat('MMMM d, yyyy • h:mm a').format(scan.createdAt!)
        : 'Unknown';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'PLANTIVA Diagnosis Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Disease: ${scan.label}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('Confidence: ${scan.confidence}'),
          pw.Text('Severity: ${scan.effectiveSeverity}'),
          pw.Text('Scanned: $date'),
          pw.SizedBox(height: 16),
          pw.Text('Summary',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(scan.effectiveSummary),
          pw.SizedBox(height: 12),
          pw.Text('Recommendations',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(scan.effectiveRecommendations),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'plantiva_scan_${scan.id}',
    );
  }

  Future<void> _deleteScan() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this scan?'),
        content: const Text(
          'This diagnosis report will be permanently removed.',
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
    if (ok != true || !mounted) return;
    await ScanHistoryService.deleteScan(scan.id, imageUrl: scan.imageUrl);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = scan.label;
    final confidence = scan.confidence;
    final isHealthy = scan.isHealthy;
    final severity = scan.effectiveSeverity;
    final severityColor = _severityColor(severity);
    final confidenceValue = scan.confidenceValue;
    final dateStr = scan.createdAt != null
        ? DateFormat('EEEE, MMM d, yyyy • h:mm a').format(scan.createdAt!)
        : 'Date unavailable';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ScanImageWidget(
                          imagePath: scan.imagePath,
                          imageUrl: scan.imageUrl,
                          width: MediaQuery.of(context).size.width,
                          height: 260,
                          borderRadius: 0,
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _CircleBtn(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _CircleBtn(
                            icon: Icons.share_outlined,
                            onTap: _shareReport,
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isHealthy
                                      ? Icons.check_circle
                                      : Icons.warning_amber_rounded,
                                  color: isHealthy
                                      ? const Color(0xFF2E7D32)
                                      : Colors.orange.shade800,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isHealthy ? 'HEALTHY' : 'DETECTED',
                                  style: TextStyle(
                                    color: isHealthy
                                        ? const Color(0xFF2E7D32)
                                        : Colors.orange.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  confidence,
                                  style: const TextStyle(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Analysis'),
                          _card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _metricBox(
                                        'Confidence',
                                        '${confidenceValue.toStringAsFixed(0)}%',
                                        AppColors.green,
                                        confidenceValue / 100,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _metricBox(
                                        'Severity',
                                        severity,
                                        severityColor,
                                        null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  ScanDiagnosisHelper.severityAction(severity),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  scan.effectiveSummary,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Recommendations'),
                          _card(
                            child: Text(
                              scan.effectiveRecommendations,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Related History'),
                          if (_loadingRelated)
                            const Center(child: CircularProgressIndicator())
                          else if (_related.isEmpty)
                            _card(
                              child: Text(
                                'No other scans of ${scan.category} yet.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          else
                            ..._related.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _relatedTile(r),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF202422),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _metricBox(
    String label,
    String value,
    Color color,
    double? progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _relatedTile(ScanRecord r) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          ScanImageWidget(
            imagePath: r.imagePath,
            imageUrl: r.imageUrl,
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortDiseaseName(r.label),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  relativeScanTime(r.createdAt),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            r.confidence,
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _savePdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('PDF'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _deleteScan,
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }
}
