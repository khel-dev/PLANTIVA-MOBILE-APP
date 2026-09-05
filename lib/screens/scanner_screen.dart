import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/services/classifier_service.dart';
import 'package:flutter_plantiva/services/input_validator_service.dart';
import 'package:flutter_plantiva/utils/plantiva_feedback.dart';
import 'package:image_picker/image_picker.dart';

import 'scan_loading_screen.dart';

enum _ModelPhase { loading, ready, error }

const _scannerBackground = Color(0xFFF5F7F2);
const _scannerInk = Color(0xFF173722);
const _scannerMuted = Color(0xFF68736B);
const _scannerBorder = Color(0xFFDDE7DC);
const _scannerSoftGreen = Color(0xFFE8F2E7);

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  final ClassifierService _classifier = ClassifierService();
  final InputValidatorService _inputValidator = InputValidatorService();
  late final AnimationController _pulse;
  late final AnimationController _sweep;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _sweepAnim;

  _ModelPhase _phase = _ModelPhase.loading;
  bool _inferencing = false;

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
    if (mounted) setState(() => _phase = _ModelPhase.loading);
    await Future.wait([
      _classifier.loadModel(),
      _inputValidator.loadModel(),
    ]);
    if (!mounted) return;
    setState(() {
      _phase = _classifier.isReady && _inputValidator.isReady
          ? _ModelPhase.ready
          : _ModelPhase.error;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_phase != _ModelPhase.ready) {
      PlantivaFeedback.show(
        context,
        message: _phase == _ModelPhase.loading
            ? 'The scanner is still getting ready.'
            : 'The scanner is unavailable. Please try again.',
        type: PlantivaFeedbackType.warning,
      );
      return;
    }
    if (_inferencing) return;

    setState(() => _inferencing = true);
    String? retrySource;
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 88,
      );
      if (pickedFile == null || !mounted) return;

      HapticFeedback.lightImpact();
      retrySource = await Navigator.push<String?>(
        context,
        PageRouteBuilder<String?>(
          pageBuilder: (_, __, ___) => ScanLoadingScreen(
            imagePath: pickedFile.path,
            classifier: _classifier,
            inputValidator: _inputValidator,
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
    } finally {
      if (mounted) setState(() => _inferencing = false);
    }

    if (!mounted || retrySource == null) return;
    await _pickImage(
      retrySource == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
  }

  void _showTipsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScannerSheet(
        icon: Icons.tips_and_updates_outlined,
        title: 'Photo tips',
        subtitle: 'A clear image helps Plantiva give a more reliable result.',
        child: Column(
          children: [
            _TipRow(
              icon: Icons.wb_sunny_outlined,
              title: 'Use good lighting',
              text: 'Use daylight when possible and avoid strong glare.',
            ),
            _TipRow(
              icon: Icons.center_focus_strong_rounded,
              title: 'Keep the leaf in focus',
              text: 'Hold the phone steady and wait for a clear image.',
            ),
            _TipRow(
              icon: Icons.eco_outlined,
              title: 'Show one banana leaf',
              text: 'Keep the leaf clearly visible inside the frame.',
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportedConditionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScannerSheet(
        icon: Icons.fact_check_outlined,
        title: 'Supported conditions',
        subtitle: 'Plantiva can check clear banana leaf images for:',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth < 340
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: _kBananaClasses
                  .map(
                    (condition) => SizedBox(
                      width: itemWidth,
                      child: _ConditionItem(label: condition),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  static const _kBananaClasses = <String>[
    'Black Sigatoka',
    'Bract Mosaic Virus',
    'Bunchy Top Disease',
    'Healthy Leaf',
    'Insect Pest Damage',
    'Moko Disease',
    'Panama Disease',
    'Yellow Sigatoka',
  ];

  @override
  void dispose() {
    _pulse.dispose();
    _sweep.dispose();
    _classifier.close();
    _inputValidator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scannerBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;
            final compact = constraints.maxHeight < 680;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                compact ? 10 : 16,
                horizontalPadding,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ScannerHeader(
                        onBack: () => Navigator.pop(context),
                        onInfo: _showSupportedConditionsSheet,
                      ),
                      SizedBox(height: compact ? 18 : 24),
                      AnimatedBuilder(
                        animation: Listenable.merge([_pulseAnim, _sweepAnim]),
                        builder: (_, __) => _ScannerPreview(
                          phase: _phase,
                          pulse: _pulseAnim.value,
                          sweep: _sweepAnim.value,
                          compact: compact,
                          onRetry: _bootstrapModel,
                        ),
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      const _GuidanceCard(),
                      SizedBox(height: compact ? 16 : 22),
                      _ScannerActions(
                        enabled: _phase == _ModelPhase.ready && !_inferencing,
                        busy: _inferencing,
                        onCamera: () => _pickImage(ImageSource.camera),
                        onGallery: () => _pickImage(ImageSource.gallery),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _inferencing ? null : _showTipsSheet,
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: const Text('View photo tips'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.green,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
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

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader({required this.onBack, required this.onInfo});

  final VoidCallback onBack;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _scannerInk,
            minimumSize: const Size(48, 48),
            side: const BorderSide(color: _scannerBorder),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan Banana Leaf',
                maxLines: 2,
                style: TextStyle(
                  color: _scannerInk,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Capture or upload a clear banana leaf for analysis.',
                style: TextStyle(
                  color: _scannerMuted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Supported conditions',
          onPressed: onInfo,
          style: IconButton.styleFrom(
            backgroundColor: _scannerSoftGreen,
            foregroundColor: AppColors.green,
            minimumSize: const Size(48, 48),
          ),
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
    );
  }
}

class _ScannerPreview extends StatelessWidget {
  const _ScannerPreview({
    required this.phase,
    required this.pulse,
    required this.sweep,
    required this.compact,
    required this.onRetry,
  });

  final _ModelPhase phase;
  final double pulse;
  final double sweep;
  final bool compact;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: compact ? 1.22 : 1.10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEDF3E9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _scannerBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF234C2F).withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -42,
                bottom: -56,
                width: compact ? 190 : 240,
                child: Opacity(
                  opacity: 0.13,
                  child: Image.asset('assets/images/banana-leaf.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 24 : 30),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.crop_free_rounded,
                  size: compact ? 150 : 188,
                  color: AppColors.green.withValues(alpha: 0.20),
                ),
              ),
              if (phase == _ModelPhase.ready)
                Align(
                  alignment: Alignment(0, -0.84 + (1.68 * sweep)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38),
                    child: Container(
                      height: 2,
                      color: AppColors.green.withValues(alpha: 0.20),
                    ),
                  ),
                ),
              Center(
                child: _PreviewState(
                  phase: phase,
                  pulse: pulse,
                  onRetry: onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewState extends StatelessWidget {
  const _PreviewState({
    required this.phase,
    required this.pulse,
    required this.onRetry,
  });

  final _ModelPhase phase;
  final double pulse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (phase == _ModelPhase.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB45309),
              size: 36,
            ),
            const SizedBox(height: 10),
            const Text(
              'Scanner could not start',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _scannerInk,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(
                  alpha: phase == _ModelPhase.loading
                      ? 0.08 + (pulse * 0.08)
                      : 0.08,
                ),
                blurRadius: 18,
              ),
            ],
          ),
          child: phase == _ModelPhase.loading
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.green,
                  ),
                )
              : const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.green,
                  size: 30,
                ),
        ),
        const SizedBox(height: 14),
        Text(
          phase == _ModelPhase.loading
              ? 'Preparing scanner...'
              : 'Keep the leaf clearly visible',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _scannerInk,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          phase == _ModelPhase.loading
              ? 'This will only take a moment.'
              : 'Place one banana leaf inside the frame.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _scannerMuted,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _scannerBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For a clearer scan',
            style: TextStyle(
              color: _scannerInk,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GuidanceItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Good lighting',
                ),
              ),
              Expanded(
                child: _GuidanceItem(
                  icon: Icons.center_focus_strong_rounded,
                  label: 'Clear focus',
                ),
              ),
              Expanded(
                child: _GuidanceItem(
                  icon: Icons.eco_outlined,
                  label: 'Leaf in frame',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuidanceItem extends StatelessWidget {
  const _GuidanceItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.green),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _scannerMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ScannerActions extends StatelessWidget {
  const _ScannerActions({
    required this.enabled,
    required this.busy,
    required this.onCamera,
    required this.onGallery,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: enabled ? onCamera : null,
          icon: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.photo_camera_rounded),
          label: Text(busy ? 'Opening camera...' : 'Capture Leaf'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFC7D4C8),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: enabled ? onGallery : null,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose from Gallery'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            foregroundColor: AppColors.green,
            side: const BorderSide(color: Color(0xFFB8CCB9)),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerSheet extends StatelessWidget {
  const _ScannerSheet({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFCFDFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DED6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _scannerSoftGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _scannerInk,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _scannerMuted,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _scannerBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.green, size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _scannerInk,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: const TextStyle(
                      color: _scannerMuted,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  const _ConditionItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _scannerBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.green,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _scannerInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
