import 'package:flutter/material.dart';

class MilestonedProgressBar extends StatelessWidget {
  const MilestonedProgressBar({
    super.key,
    required this.progress,            // 0.0–1.0
    required this.milestones,          // e.g. [0.2, 0.65]
    this.height = 16,
    this.trackColor = const Color(0xFFEFF3FF),
    this.fillColor = const Color(0xFF5B2EE0), // your purple
    this.milestoneSize = 10,
    this.borderWidth = 2,
    this.showProgressHeadDot = false,  // turn on if you also want a moving head dot
  });

  final double progress;
  final List<double> milestones;
  final double height;
  final Color trackColor;
  final Color fillColor;
  final double milestoneSize;
  final double borderWidth;
  final bool showProgressHeadDot;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final sorted = [...milestones]..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final radius = BorderRadius.circular(height / 2);

        double x(double t, double size) => (t * width - size / 2)
            .clamp(0.0, width - size);

        return SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: radius,
                ),
              ),

              // Fill
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: p,
                  child: Container(
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: radius,
                    ),
                  ),
                ),
              ),

              // Milestones (white if reached, purple if upcoming)
              for (final m in sorted)
                Positioned(
                  left: x(m.clamp(0.0, 1.0), milestoneSize),
                  top: (height - milestoneSize) / 2,
                  child: _MilestoneDot(
                    reached: p >= m,
                    size: milestoneSize,
                    fill: fillColor,
                    borderWidth: borderWidth,
                  ),
                ),

              // Optional head dot at current progress
              if (showProgressHeadDot)
                Positioned(
                  left: x(p, milestoneSize + 2),
                  top: (height - (milestoneSize + 2)) / 2,
                  child: Container(
                    width: milestoneSize + 2,
                    height: milestoneSize + 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: fillColor, width: borderWidth),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({
    required this.reached,
    required this.size,
    required this.fill,
    required this.borderWidth,
  });

  final bool reached;
  final double size;
  final Color fill;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    if (reached) {
      // White with colored border once the fill passes this point
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: fill, width: borderWidth),
        ),
      );
    } else {
      // Solid colored dot for upcoming milestone
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
        ),
      );
    }
  }
}
