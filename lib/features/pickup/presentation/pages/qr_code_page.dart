import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodbegood/config/routes.dart';

/// QR Code display page with countdown timer
class QRCodePage extends StatefulWidget {
  final String pickupId;
  final String? qrData;
  final DateTime? expiresAt;

  const QRCodePage({
    super.key,
    required this.pickupId,
    this.qrData,
    this.expiresAt,
  });

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your QR Code'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isExpired
                      ? colorScheme.error.withAlpha(26)
                      : colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isExpired ? Icons.timer_off : Icons.timer,
                      size: 32,
                      color: _isExpired ? colorScheme.error : colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isExpired ? 'Code Expired' : 'Code Expires In',
                      style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedTime,
                      style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isExpired ? colorScheme.error : colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // QR Code
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
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
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isExpired ? colorScheme.error : colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isExpired
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.block,
                                        size: 64,
                                        color: colorScheme.error,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'EXPIRED',
                                        style: textTheme.headlineSmall?.copyWith(
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
                                      painter: _QRCodePainter(),
                                    ),
                                    // Center logo
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 32,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 24),

                        // Pickup ID
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
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
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: widget.pickupId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pickup ID copied to clipboard'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy,
                                  size: 16,
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
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 8),
                    Text(
                      'The QR code will expire in 5 minutes. Make sure to collect your meal before it expires.',
                      style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(153),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              if (_isExpired)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.goStudentDashboard();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Create New Pickup',
                      style: TextStyle(
                        fontSize: 16,
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
                    const SizedBox(width: 12),
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
    );
  }
}

/// Custom painter to simulate QR code pattern
class _QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 25;

    // Draw finder patterns (corners)
    _drawFinderPattern(canvas, paint, Offset(2 * cellSize, 2 * cellSize), cellSize * 7);
    _drawFinderPattern(canvas, paint, Offset(size.width - 9 * cellSize, 2 * cellSize), cellSize * 7);
    _drawFinderPattern(canvas, paint, Offset(2 * cellSize, size.height - 9 * cellSize), cellSize * 7);

    // Draw random data modules
    final random = DateTime.now().millisecond;
    for (var row = 0; row < 25; row++) {
      for (var col = 0; col < 25; col++) {
        // Skip finder pattern areas
        if ((row < 9 && col < 9) ||
            (row < 9 && col > 15) ||
            (row > 15 && col < 9)) {
          continue;
        }

        // Create a pattern based on position
        if ((row + col + random) % 3 == 0 || (row * col) % 7 == 0) {
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

  void _drawFinderPattern(Canvas canvas, Paint paint, Offset offset, double size) {
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
      Rect.fromLTWH(offset.dx + size * 0.15, offset.dy + size * 0.15, size * 0.7, size * 0.7),
      whitePaint,
    );

    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size * 0.3, offset.dy + size * 0.3, size * 0.4, size * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
