import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Animated progress bar with gradient fill
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? color;
  final List<Color>? gradientColors;
  final Duration animationDuration;
  final bool showGlow;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.color,
    this.gradientColors,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showGlow = true,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = widget.color ?? theme.colorScheme.primary;
    final bgColor = widget.backgroundColor ??
        progressColor.withValues(alpha: 0.2);

    return ClipRRect(
      borderRadius: BorderRadius.circular((widget.height / 2).r),
      child: Container(
        height: widget.height.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular((widget.height / 2).r),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _animation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.gradientColors != null
                      ? LinearGradient(
                          colors: widget.gradientColors!,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : LinearGradient(
                          colors: [
                            progressColor,
                            progressColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  borderRadius: BorderRadius.circular((widget.height / 2).r),
                  boxShadow: widget.showGlow
                      ? [
                          BoxShadow(
                            color: progressColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: widget.showGlow
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 4.w,
                          height: widget.height.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Segmented progress bar for milestones
class SegmentedProgressBar extends StatelessWidget {
  final double progress;
  final int segments;
  final double height;
  final Color? backgroundColor;
  final Color? color;
  final List<Color>? gradientColors;
  final double gap;

  const SegmentedProgressBar({
    super.key,
    required this.progress,
    this.segments = 5,
    this.height = 8,
    this.backgroundColor,
    this.color,
    this.gradientColors,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ??
        progressColor.withValues(alpha: 0.2);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(segments, (index) {
            final segmentProgress = (progress * segments) - index;
            final isFilled = segmentProgress >= 1;
            final isPartial = segmentProgress > 0 && segmentProgress < 1;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < segments - 1 ? gap.w : 0,
                ),
                height: height.h,
                decoration: BoxDecoration(
                  color: isFilled ? null : bgColor,
                  gradient: isFilled && gradientColors != null
                      ? LinearGradient(
                          colors: gradientColors!,
                        )
                      : isFilled
                          ? LinearGradient(
                              colors: [
                                progressColor,
                                progressColor.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                  borderRadius: BorderRadius.circular((height / 2).r),
                ),
                child: isPartial
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular((height / 2).r),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: segmentProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: gradientColors != null
                                  ? LinearGradient(colors: gradientColors!)
                                  : LinearGradient(
                                      colors: [
                                        progressColor,
                                        progressColor.withValues(alpha: 0.8),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}

/// Circular progress indicator with animated value
class AnimatedCircularProgress extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? color;
  final List<Color>? gradientColors;
  final Duration animationDuration;
  final Widget? child;

  const AnimatedCircularProgress({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.color,
    this.gradientColors,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.child,
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = widget.color ?? theme.colorScheme.primary;

    return SizedBox(
      width: widget.size.w,
      height: widget.size.w,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size.w, widget.size.w),
            painter: _CircularProgressPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth.w,
              backgroundColor: widget.backgroundColor ??
                  progressColor.withValues(alpha: 0.2),
              color: progressColor,
              gradientColors: widget.gradientColors,
            ),
            child: widget.child != null
                ? Center(child: widget.child)
                : null,
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color color;
  final List<Color>? gradientColors;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.color,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null && gradientColors!.length >= 2) {
      final gradient = SweepGradient(
        colors: gradientColors!,
        startAngle: -90 * (3.14159 / 180),
        endAngle: (360 * progress - 90) * (3.14159 / 180),
      );
      progressPaint.shader = gradient.createShader(rect);
    } else {
      progressPaint.color = color;
    }

    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180),
      360 * progress * (3.14159 / 180),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
