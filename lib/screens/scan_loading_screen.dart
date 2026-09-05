import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/result_screen.dart';
import 'package:flutter_plantiva/services/classifier_service.dart';
import 'package:flutter_plantiva/services/image_quality_service.dart';
import 'package:flutter_plantiva/services/input_validator_service.dart';
import 'package:flutter_plantiva/services/scan_history_service.dart';
import 'package:flutter_plantiva/services/scan_input_pipeline.dart';

const _loadingBackground = Color(0xFFF5F7F2);
const _loadingInk = Color(0xFF173722);
const _loadingMuted = Color(0xFF68736B);
const _loadingBorder = Color(0xFFDDE7DC);

class ScanLoadingScreen extends StatefulWidget {
  const ScanLoadingScreen({
    super.key,
    required this.imagePath,
    required this.classifier,
    required this.inputValidator,
  });

  final String imagePath;
  final ClassifierService classifier;
  final InputValidatorService inputValidator;

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  final ImageQualityService _qualityService = ImageQualityService();

  String? _error;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runScan());
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runScan() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      final imageFile = File(widget.imagePath);
      final pipeline = await ScanInputPipeline.run(
        qualityCheck: () => _qualityService.analyze(imageFile),
        semanticCheck: () => widget.inputValidator.validate(imageFile),
        diseaseClassification: () => widget.classifier.classify(imageFile),
      );
      final result = pipeline.result;
      if (!mounted) return;

      String? savedScanId;
      if (pipeline.passedInputGates &&
          result['validation_status'] == 'validDiagnosis') {
        try {
          savedScanId = await ScanHistoryService.recordScan(
            result,
            imagePath: widget.imagePath,
          );
        } catch (e) {
          debugPrint('PLANTIVA scan save failed after classification: $e');
          savedScanId = null;
        }
      }

      if (!mounted) return;
      await Navigator.of(context).pushReplacement<String?, void>(
        PageRouteBuilder<String?>(
          pageBuilder: (_, __, ___) => ResultScreen(
            imagePath: widget.imagePath,
            result: result,
            savedScanId: savedScanId,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            'Scan failed. Please try again with a clearer banana leaf image.';
      });
    } finally {
      _isRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _loadingBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;
            final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                compact ? 14 : 22,
                horizontalPadding,
                24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - (compact ? 38 : 46))
                      .clamp(0, double.infinity),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LoadingHeader(),
                        SizedBox(height: compact ? 16 : 24),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _scanController,
                            _pulseController,
                          ]),
                          builder: (_, __) => _LoadingCard(
                            imagePath: widget.imagePath,
                            scanProgress: _scanController.value,
                            pulse: _pulse.value,
                            compact: compact,
                            error: _error,
                            onScanAgain: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFE8F2E7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_outlined, color: AppColors.green, size: 23),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Checking your image',
                style: TextStyle(
                  color: _loadingInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Keep this screen open while Plantiva analyzes the leaf.',
                style: TextStyle(
                  color: _loadingMuted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.imagePath,
    required this.scanProgress,
    required this.pulse,
    required this.compact,
    required this.error,
    required this.onScanAgain,
  });

  final String imagePath;
  final double scanProgress;
  final double pulse;
  final bool compact;
  final String? error;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _loadingBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF234C2F).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: compact ? 1.24 : 1.08,
            child: _LeafScanner(
              imagePath: imagePath,
              progress: scanProgress,
            ),
          ),
          SizedBox(height: compact ? 16 : 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: error == null
                ? _AnalyzingState(pulse: pulse)
                : _LoadingError(
                    message: error!,
                    onScanAgain: onScanAgain,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingState extends StatelessWidget {
  const _AnalyzingState({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('analyzing'),
      children: [
        Transform.scale(
          scale: 0.96 + (pulse * 0.04),
          child: const _LeafProgress(),
        ),
        const SizedBox(height: 14),
        const Text(
          'Analyzing leaf...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _loadingInk,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Checking image quality and visible leaf patterns.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _loadingMuted,
            height: 1.4,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _LoadingError extends StatelessWidget {
  const _LoadingError({required this.message, required this.onScanAgain});

  final String message;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('error'),
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF2DF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB45309),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We could not complete the scan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _loadingInk,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _loadingMuted,
            height: 1.4,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onScanAgain,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Scan Again'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeafScanner extends StatelessWidget {
  const _LeafScanner({required this.imagePath, required this.progress});

  final String imagePath;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFFE8F2E7),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.green,
                size: 44,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: 12 + ((constraints.maxHeight - 24) * progress),
                    left: 14,
                    right: 14,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF78B47D).withValues(alpha: 0.82),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.18),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LeafProgress extends StatelessWidget {
  const _LeafProgress();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox(
          width: 54,
          height: 54,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.green,
            backgroundColor: Color(0xFFE3EBE2),
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F2E7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_outlined,
            color: AppColors.green,
            size: 21,
          ),
        ),
      ],
    );
  }
}
