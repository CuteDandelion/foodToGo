import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodbegood/config/routes.dart';
import 'package:foodbegood/shared/widgets/app_card.dart';

/// QR Code display page with countdown timer
class QRCodePage extends StatefulWidget {
  final String pickupId;
  final String? qrData;
  final DateTime? expiresAt;
  final String? studentName;
  final List<String> orderItems;
  final String? pickupTime;

  const QRCodePage({
    super.key,
    required this.pickupId,
    this.qrData,
    this.expiresAt,
    this.studentName,
    this.orderItems = const [],
    this.pickupTime,
  });

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _warningPulseController;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;
  bool get _isWarning =>
      !_isExpired && _remaining.inSeconds > 0 && _remaining.inSeconds <= 60;

  @override
  void initState() {
    super.initState();
    _warningPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    if (widget.expiresAt == null) return;

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.expiresAt == null) return;

    final now = DateTime.now();
    final remaining = widget.expiresAt!.difference(now);

    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
      _isExpired = remaining.isNegative;
    });

    if (_isExpired) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _warningPulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes =
        _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goStudentDashboard();
            }
          },
        ),
        title: const Text('Your QR Code'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0.r),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: _isExpired
                        ? colorScheme.error.withValues(alpha: 0.1)
                        : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isExpired ? Icons.timer_off : Icons.timer,
                        size: 32.r,
                        color: _isExpired
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _isExpired ? 'Code Expired' : 'Code Expires In',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AnimatedBuilder(
                        animation: _warningPulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _isWarning
                                ? (0.5 + (_warningPulseController.value * 0.5))
                                : 1,
                            child: child,
                          );
                        },
                        child: Text(
                          _formattedTime,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: (_isExpired || _isWarning)
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // QR Code
                Center(
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // QR Code placeholder - in production, use qr_flutter package
                        Container(
                          width: 250.w,
                          height: 250.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isExpired
                                  ? colorScheme.error
                                  : colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: _isExpired
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.block,
                                        size: 64.r,
                                        color: colorScheme.error,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'EXPIRED',
                                        style:
                                            textTheme.headlineSmall?.copyWith(
                                          color: colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Simulated QR code pattern
                                    CustomPaint(
                                      size: const Size(220, 220),
                                      painter: _QRCodePainter(
                                        seed: widget.pickupId.hashCode,
                                      ),
                                    ),
                                    // Center logo
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 32.r,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        SizedBox(height: 24.h),

                        if (widget.studentName != null &&
                            widget.studentName!.trim().isNotEmpty) ...[
                          Text(
                            widget.studentName!,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                        ],

                        // Pickup ID
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ID: ${widget.pickupId.substring(0, widget.pickupId.length > 8 ? 8 : widget.pickupId.length)}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: widget.pickupId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Pickup ID copied to clipboard'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy,
                                  size: 16.r,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Instructions
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20.r,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Show this code to the canteen staff',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'The QR code will expire in 5 minutes. Make sure to collect your meal before it expires.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                if (widget.orderItems.isNotEmpty ||
                    widget.pickupTime != null) ...[
                  AppCard(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 20.r,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Order Summary',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (widget.orderItems.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          ...widget.orderItems.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8.r,
                                    color: colorScheme.primary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (widget.pickupTime != null &&
                            widget.pickupTime!.trim().isNotEmpty) ...[
                          Divider(height: 24.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18.r,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Pickup Time: ${widget.pickupTime}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Action buttons
                if (_isExpired)
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.goStudentDashboard();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Create New Pickup',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.goStudentDashboard();
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Dashboard'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // Share functionality would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sharing coming soon!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to simulate QR code pattern
class _QRCodePainter extends CustomPainter {
  const _QRCodePainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 25;

    // Draw finder patterns (corners)
    _drawFinderPattern(
        canvas, paint, Offset(2 * cellSize, 2 * cellSize), cellSize * 7);
    _drawFinderPattern(canvas, paint,
        Offset(size.width - 9 * cellSize, 2 * cellSize), cellSize * 7);
    _drawFinderPattern(canvas, paint,
        Offset(2 * cellSize, size.height - 9 * cellSize), cellSize * 7);

    // Draw deterministic data modules using pickup-specific seed
    for (var row = 0; row < 25; row++) {
      for (var col = 0; col < 25; col++) {
        // Skip finder pattern areas
        if ((row < 9 && col < 9) ||
            (row < 9 && col > 15) ||
            (row > 15 && col < 9)) {
          continue;
        }

        // Create a pattern based on position
        if ((row + col + seed) % 3 == 0 || (row * col) % 7 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize - 1,
              cellSize - 1,
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(
      Canvas canvas, Paint paint, Offset offset, double size) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size, size),
      paint,
    );

    // White inner square
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size * 0.15, offset.dy + size * 0.15,
          size * 0.7, size * 0.7),
      whitePaint,
    );

    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size * 0.3, offset.dy + size * 0.3, size * 0.4,
          size * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
