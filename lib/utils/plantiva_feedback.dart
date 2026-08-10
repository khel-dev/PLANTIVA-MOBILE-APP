import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';

enum PlantivaFeedbackType { error, success, warning, info }

class PlantivaFeedback {
  const PlantivaFeedback._();

  static void show(
    BuildContext context, {
    required String message,
    PlantivaFeedbackType type = PlantivaFeedbackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final data = _FeedbackStyle.forType(type);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        backgroundColor: data.background,
        margin: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: duration,
        content: Row(
          children: [
            Icon(data.icon, color: data.foreground, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: data.foreground,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackStyle {
  const _FeedbackStyle({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;

  static _FeedbackStyle forType(PlantivaFeedbackType type) {
    switch (type) {
      case PlantivaFeedbackType.error:
        return const _FeedbackStyle(
          background: Color(0xFFB42318),
          foreground: Colors.white,
          icon: Icons.error_outline_rounded,
        );
      case PlantivaFeedbackType.success:
        return const _FeedbackStyle(
          background: AppColors.green,
          foreground: Colors.white,
          icon: Icons.check_circle_outline_rounded,
        );
      case PlantivaFeedbackType.warning:
        return const _FeedbackStyle(
          background: Color(0xFFB7791F),
          foreground: Colors.white,
          icon: Icons.warning_amber_rounded,
        );
      case PlantivaFeedbackType.info:
        return const _FeedbackStyle(
          background: Color(0xFF1F4E5F),
          foreground: Colors.white,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}
