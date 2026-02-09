import 'package:collaby_app/models/orders_model/earnings_models.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class SummaryCard extends StatelessWidget {
  final double amount;
  final double fee;
  final BankAccount? account;
  final bool dotted;
  final bool compact;

  const SummaryCard({
    super.key,
    required this.amount,
    required this.fee,
    this.account,
    this.dotted = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: dotted ? Border.all(color: const Color(0xFFE5E7EB)) : null,
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Center(
            child: Text('withdraw_amount'.tr, style: AppTextStyles.smallText),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${amount.toStringAsFixed(2)} USD',
              style: AppTextStyles.h3,
            ),
          ),
          const SizedBox(height: 18),
          _DashedDivider(),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('transaction_fees'.tr, style: AppTextStyles.smallText),
              Text(
                '${fee.toStringAsFixed(1)} USD',
                style: AppTextStyles.normalTextMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DashedDivider(),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('deposit_to'.tr, style: AppTextStyles.smallText),
              Text(
                account != null
                    ? '${account!.bankName} (${account!.accountNumber.substring(0, math.min(10, account!.accountNumber.length))}…)'
                    : '—',
                textAlign: TextAlign.right,
                style: AppTextStyles.normalText,
              ),
            ],
          ),
          if (!compact) const SizedBox(height: 6),
        ],
      ),
    );

    return card;
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedPainter(color: const Color(0xFFE5E7EB)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  _DashedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    const dash = 6.0, gap = 4.0;
    final y = size.height / 2;
    while (x < size.width) {
      final end = math.min(x + dash, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
