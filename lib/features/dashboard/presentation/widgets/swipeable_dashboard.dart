import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../config/routes.dart';

/// Swipeable dashboard with QR code access on left swipe
class SwipeableDashboard extends StatefulWidget {
  final Widget dashboardContent;
  final String? pickupId;
  final String? qrData;
  final DateTime? expiresAt;

  const SwipeableDashboard({
    super.key,
    required this.dashboardContent,
    this.pickupId,
    this.qrData,
    this.expiresAt,
  });

  @override
  State<SwipeableDashboard> createState() => _SwipeableDashboardState();
}

class _SwipeableDashboardState extends State<SwipeableDashboard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    
    // Provide haptic feedback when switching pages
    if (page == 1) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            // Main dashboard page
            widget.dashboardContent,
            // QR code quick access page
            _QRCodeQuickAccess(
              pickupId: widget.pickupId,
              qrData: widget.qrData,
              expiresAt: widget.expiresAt,
              onBack: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
        // Swipe hint indicator
        if (_currentPage == 0)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: _SwipeHint(),
          ),
        // Page indicator
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(0),
              const SizedBox(width: 8),
              _buildPageIndicator(1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int page) {
    final isActive = _currentPage == page;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Swipe hint widget with animation
class _SwipeHint extends StatefulWidget {
  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
        return Opacity(
          opacity: 0.5 + 0.5 * _animation.value,
          child: Column(
            children: [
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                'QR Code',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// QR Code quick access page
class _QRCodeQuickAccess extends StatelessWidget {
  final String? pickupId;
  final String? qrData;
  final DateTime? expiresAt;
  final VoidCallback onBack;

  const _QRCodeQuickAccess({
    this.pickupId,
    this.qrData,
    this.expiresAt,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final hasActivePickup = pickupId != null && qrData != null && expiresAt != null;
    
    if (!hasActivePickup) {
      return _NoActivePickup(onBack: onBack);
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: onBack,
                  ),
                  const Expanded(
                    child: Text(
                      'Quick QR Access',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            const Spacer(),
            
            // QR Code display
            GestureDetector(
              onTap: () {
                context.goQRCode(
                  pickupId: pickupId!,
                  qrData: qrData!,
                  expiresAt: expiresAt!,
                  items: const [],
                );
              },
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // QR Code placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 150,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to view full QR Code',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Instructions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Show this QR code to the canteen staff',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget shown when there's no active pickup
class _NoActivePickup extends StatelessWidget {
  final VoidCallback onBack;

  const _NoActivePickup({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: onBack,
                  ),
                  const Expanded(
                    child: Text(
                      'Quick QR Access',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.qr_code_scanner_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Pickup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a pickup to get your QR code',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Builder(
              builder: (context) {
                return ElevatedButton.icon(
                  onPressed: () {
                    onBack();
                    // Navigate to pickup after a short delay
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (context.mounted) {
                        context.goPickup();
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Pickup'),
                );
              }
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
