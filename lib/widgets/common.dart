import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

/// Top bar with back button + centered title + optional right widget.
class ItharTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? right;
  const ItharTopBar({super.key, required this.title, this.onBack, this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          if (onBack != null)
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.tintSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
              ),
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: AppText.topBar),
          ),
          SizedBox(
            width: 40,
            child: Align(alignment: Alignment.centerLeft, child: right),
          ),
        ],
      ),
    );
  }
}

/// 4-segment onboarding progress bar.
class ItharProgress extends StatelessWidget {
  final int step;
  final int total;
  const ItharProgress({super.key, required this.step, this.total = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(left: i == total - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: i < step ? AppColors.primary : AppColors.tintSoft,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 56px pill CTA. primary or secondary (tinted) variant.
class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool secondary;
  final Widget? trailing;
  const BigButton({
    super.key,
    required this.label,
    this.onPressed,
    this.disabled = false,
    this.secondary = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = !secondary;
    final bg = disabled
        ? AppColors.disabled
        : (isPrimary ? AppColors.primary : AppColors.tintSoft);
    final fg = isPrimary ? Colors.white : AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: disabled ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: isPrimary && !disabled ? AppShadows.primaryCta : null,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppText.buttonBig.copyWith(color: fg)),
                if (isPrimary && !disabled) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Conic-gradient match ring with % inside.
class MatchRing extends StatelessWidget {
  final int value;
  final double size;
  const MatchRing({super.key, required this.value, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value),
        child: Center(
          child: Container(
            width: size - 10,
            height: size - 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$value%',
              style: AppText.chip.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int value;
  _RingPainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = AppColors.tintSoft
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, 0, 2 * pi, true, bg);
    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, -pi / 2, 2 * pi * (value / 100), true, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}

/// Status pill (pending / accepted / rejected).
class StatusPill extends StatelessWidget {
  final String status;
  final String prefix;
  const StatusPill({super.key, required this.status, this.prefix = ''});

  static const Map<String, List<Object>> _map = {
    'pending': ['قيد المراجعة', AppColors.pendingBg, AppColors.pendingFg],
    'accepted': ['مقبول', AppColors.acceptedBg, AppColors.acceptedFg],
    'rejected': ['غير مقبول', AppColors.rejectedBg, AppColors.rejectedFg],
  };

  static List<Object> _e(String status) => _map[status] ?? _map['pending']!;
  static String label(String status) => _e(status)[0] as String;
  static Color bg(String status) => _e(status)[1] as Color;
  static Color fg(String status) => _e(status)[2] as Color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg(status),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$prefix${label(status)}',
        style: AppText.chip.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg(status),
        ),
      ),
    );
  }
}

/// Small tag chip (used for NGO tag).
class TagChip extends StatelessWidget {
  final String text;
  const TagChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AppText.chip.copyWith(fontSize: 10, color: AppColors.ink2),
      ),
    );
  }
}

/// NGO logo tile (52 or 40) with first letter on a cycling color.
class NgoTile extends StatelessWidget {
  final Association? ngo;
  final double size;
  final double radius;
  final int colorIndex;
  const NgoTile({
    super.key,
    required this.ngo,
    this.size = 52,
    this.radius = 16,
    this.colorIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final letter = (ngo?.name.isNotEmpty ?? false) ? ngo!.name.characters.first : '؟';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: NgoColors.at(colorIndex),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppText.buttonBig.copyWith(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
