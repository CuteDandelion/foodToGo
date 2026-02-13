import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'urgency_color.dart';

/// Animated countdown widget that updates every second with color-coded urgency
class AnimatedCountdown extends StatefulWidget {
  final DateTime targetTime;
  final String? label;

  const AnimatedCountdown({
    super.key,
    required this.targetTime,
    this.label,
  });

  @override
  State<AnimatedCountdown> createState() => _AnimatedCountdownState();
}

class _AnimatedCountdownState extends State<AnimatedCountdown> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.targetTime.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining = widget.targetTime.difference(DateTime.now());
          if (_timeRemaining.isNegative) {
            _timeRemaining = Duration.zero;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatCountdown() {
    if (_timeRemaining.inDays > 0) {
      return '${_timeRemaining.inDays}d ${_timeRemaining.inHours % 24}h ${_timeRemaining.inMinutes % 60}m';
    } else if (_timeRemaining.inHours > 0) {
      return '${_timeRemaining.inHours}h ${_timeRemaining.inMinutes % 60}m';
    } else {
      return '${_timeRemaining.inMinutes}m ${_timeRemaining.inSeconds % 60}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = UrgencyColor.getColor(_timeRemaining);
    final countdownText = _formatCountdown();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: urgencyColor,
          ),
          child: Text(countdownText),
        ),
        if (widget.label != null)
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 11.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
