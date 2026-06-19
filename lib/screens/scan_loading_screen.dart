import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/result_screen.dart';
import 'package:flutter_plantiva/services/classifier_service.dart';
import 'package:flutter_plantiva/services/scan_history_service.dart';

class ScanLoadingScreen extends StatefulWidget {
  const ScanLoadingScreen({
    super.key,
    required this.imagePath,
    required this.classifier,
  });

  final String imagePath;
  final ClassifierService classifier;

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  Timer? _statusTimer;

  final _messages = const [
    'Analyzing banana leaf...',
    'Checking disease patterns...',
    'Reading leaf texture...',
    'Preparing diagnosis...',
  ];

  int _messageIndex = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCubic,
    );
    _statusTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _runScan());
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runScan() async {
    try {
      final result = await widget.classifier.classify(File(widget.imagePath));
      if (!mounted) return;

      String? savedScanId;
      try {
        savedScanId = await ScanHistoryService.recordScan(
          result,
          imagePath: widget.imagePath,
        );
      } catch (_) {
        savedScanId = null;
      }

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061208),
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.9),
                radius: 1.2,
                colors: [
                  AppColors.green.withValues(alpha: 0.45),
                  const Color(0xFF061208),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
              child: Column(
                children: [
                  const Text(
                    'PLANTIVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _scanController,
                          _pulseController,
                        ]),
                        builder: (context, _) {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 430),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: AppColors.brightGreen.withValues(
                                  alpha: 0.25 + (_pulse.value * 0.25),
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brightGreen.withValues(
                                    alpha: 0.14 + (_pulse.value * 0.12),
                                  ),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _LeafScanner(
                                  imagePath: widget.imagePath,
                                  progress: _scanController.value,
                                ),
                                const SizedBox(height: 22),
                                if (_error == null) ...[
                                  const _LeafProgress(),
                                  const SizedBox(height: 16),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Text(
                                      _messages[_messageIndex],
                                      key: ValueKey(_messageIndex),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please wait while the on-device AI checks the captured leaf.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.68),
                                      height: 1.45,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                    size: 42,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    label: const Text('Scan Again'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafScanner extends StatelessWidget {
  const _LeafScanner({
    required this.imagePath,
    required this.progress,
  });

  final String imagePath;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.92,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(imagePath), fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.16)),
            LayoutBuilder(
              builder: (context, c) {
                final y = 18 + (c.maxHeight - 36) * progress;
                return Positioned(
                  top: y,
                  left: 14,
                  right: 14,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.brightGreen.withValues(alpha: 0.95),
                          Colors.white,
                          AppColors.brightGreen.withValues(alpha: 0.95),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brightGreen.withValues(alpha: 0.8),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: AppColors.brightGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scanning leaf symptoms',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
          width: 62,
          height: 62,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            color: AppColors.brightGreen,
            backgroundColor: Colors.white24,
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white),
        ),
      ],
    );
  }
}
