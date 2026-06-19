import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import '../services/classifier_service.dart';
import 'scan_loading_screen.dart';

enum _ModelPhase { loading, ready, error }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  final ClassifierService _classifier = ClassifierService();
  late final AnimationController _pulse;
  late final AnimationController _sweep;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _sweepAnim;

  _ModelPhase _phase = _ModelPhase.loading;
  final bool _inferencing = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _sweepAnim = CurvedAnimation(parent: _sweep, curve: Curves.linear);
    _bootstrapModel();
  }

  Future<void> _bootstrapModel() async {
    setState(() => _phase = _ModelPhase.loading);
    await _classifier.loadModel();
    if (!mounted) return;
    if (_classifier.isReady) {
      setState(() => _phase = _ModelPhase.ready);
    } else {
      setState(() => _phase = _ModelPhase.error);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_phase != _ModelPhase.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _phase == _ModelPhase.loading
                ? 'AI model is still loading…'
                : 'Fix the model issue before scanning.',
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 88,
    );

    if (pickedFile == null || !mounted) return;

    HapticFeedback.lightImpact();
    await Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => ScanLoadingScreen(
          imagePath: pickedFile.path,
          classifier: _classifier,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showTipsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.52,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        builder: (_, scroll) => _GlassSheet(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            children: const [
              _SheetTitle('Capture tips', Icons.tips_and_updates_outlined),
              SizedBox(height: 14),
              _TipRow(
                icon: Icons.wb_sunny_outlined,
                text:
                    'Use natural daylight or soft white light. Avoid harsh shadows on the leaf.',
              ),
              _TipRow(
                icon: Icons.center_focus_strong,
                text:
                    'Fill the frame with one leaf. Focus on spots, streaks, or yellowing.',
              ),
              _TipRow(
                icon: Icons.blur_off,
                text: 'Hold steady — blur confuses the model.',
              ),
              _TipRow(
                icon: Icons.collections_outlined,
                text:
                    'On emulator, use Gallery with a clear banana-leaf photo if camera is unavailable.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModelSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GlassSheet(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetTitle('On-device AI', Icons.psychology_outlined),
              const SizedBox(height: 10),
              Text(
                _phase == _ModelPhase.ready
                    ? 'TensorFlow Lite model is loaded on this phone — no internet required for diagnosis.'
                    : _classifier.loadError ??
                        'Model could not be loaded. Check assets/models.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Classes (${_classifier.classCount})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ..._kBananaClasses.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.brightGreen.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13.5,
                            height: 1.35,
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
      ),
    );
  }

  static const _kBananaClasses = <String>[
    'Black Sigatoka',
    'Bract Mosaic Virus',
    'Healthy leaf',
    'Insect pest damage',
    'Moko disease',
    'Panama disease',
    'Yellow Sigatoka',
  ];

  @override
  void dispose() {
    _pulse.dispose();
    _sweep.dispose();
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061208),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient mesh gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.85),
                radius: 1.15,
                colors: [
                  AppColors.green.withValues(alpha: 0.45),
                  const Color(0xFF061208),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, 0.35),
                radius: 1.0,
                colors: [
                  AppColors.brightGreen.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          const Text(
                            'PLANTIVA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _StatusChip(phase: _phase),
                        ],
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                        onPressed: _showModelSheet,
                        icon: const Icon(Icons.info_outline_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.offline_bolt_rounded,
                              color:
                                  AppColors.brightGreen.withValues(alpha: 0.95),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _phase == _ModelPhase.ready
                                    ? 'Offline TFLite — same 224×224 pipeline as your Python trainer.'
                                    : _phase == _ModelPhase.loading
                                        ? 'Loading banana leaf model…'
                                        : 'Model error — tap retry or copy .tflite into assets.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (_phase == _ModelPhase.error)
                              TextButton(
                                onPressed: _bootstrapModel,
                                child: const Text('Retry'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_pulseAnim, _sweepAnim]),
                      builder: (context, _) {
                        final glow = 0.35 + 0.35 * _pulseAnim.value;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brightGreen
                                    .withValues(alpha: 0.15 * glow),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.brightGreen.withValues(
                                          alpha:
                                              0.25 + 0.35 * _pulseAnim.value),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.35),
                                ),
                                // Sweep line
                                LayoutBuilder(
                                  builder: (context, c) {
                                    final y = 24 +
                                        (c.maxHeight - 48) * _sweepAnim.value;
                                    return Positioned(
                                      top: y.clamp(12.0, c.maxHeight - 24),
                                      left: 18,
                                      right: 18,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppColors.brightGreen
                                                  .withValues(alpha: 0.9),
                                              Colors.transparent,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.brightGreen
                                                  .withValues(alpha: 0.6),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.eco_rounded,
                                        size: 56,
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _inferencing
                                            ? 'Analyzing leaf…'
                                            : 'Ready to scan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Banana leaf diseases',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.55),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_inferencing)
                                  const Center(
                                    child: SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: AppColors.brightGreen,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  child: Text(
                    'Capture one clear leaf — the AI matches it to your trained classes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundAction(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        enabled: !_inferencing,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                      _ShutterButton(
                        enabled: _phase == _ModelPhase.ready && !_inferencing,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      _RoundAction(
                        icon: Icons.lightbulb_outline_rounded,
                        label: 'Tips',
                        enabled: !_inferencing,
                        onTap: _showTipsSheet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.phase});

  final _ModelPhase phase;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color bg;
    late final Color fg;
    switch (phase) {
      case _ModelPhase.loading:
        text = 'LOADING MODEL';
        bg = Colors.amber.withValues(alpha: 0.2);
        fg = Colors.amberAccent;
      case _ModelPhase.ready:
        text = 'ON-DEVICE AI READY';
        bg = AppColors.brightGreen.withValues(alpha: 0.2);
        fg = AppColors.brightGreen;
      case _ModelPhase.error:
        text = 'MODEL ISSUE';
        bg = Colors.red.withValues(alpha: 0.2);
        fg = Colors.redAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (phase == _ModelPhase.loading)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.amberAccent,
              ),
            )
          else
            Icon(
              phase == _ModelPhase.ready
                  ? Icons.verified_rounded
                  : Icons.error_outline,
              size: 14,
              color: fg,
            ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap, required this.enabled});

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brightGreen.withValues(alpha: 0.35),
                AppColors.green.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brightGreen.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.photo_camera_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1A12).withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.brightGreen, size: 26),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brightGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.45,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
