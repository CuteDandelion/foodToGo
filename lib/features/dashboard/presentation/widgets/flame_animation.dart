import 'package:flutter/material.dart';

/// Animated flame streaks widget for streak card
class FlameAnimation extends StatefulWidget {
  final double size;

  const FlameAnimation({
    super.key,
    this.size = 28.0,
  });

  @override
  State<FlameAnimation> createState() => _FlameAnimationState();
}

class _FlameAnimationState extends State<FlameAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFFFF6B35).withValues(
                  alpha: 0.3 + 0.4 * _animation.value,
                ),
                const Color(0xFFFF6B35),
                const Color(0xFFFFD93D),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Icon(
            Icons.local_fire_department,
            size: widget.size,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
