import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../config/routes.dart';
import '../../domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';

/// Unified Login Page - Single login for both Student and Canteen
/// Features:
/// - Logo design from logo.dart (exact HTML design)
/// - Gyroscope-sensitive bubble background
/// - Pop-up animations with haptic feedback
/// - Professional, modern form design
/// - Fixed input styling (no dark mode effect)
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // Animation controllers
  late AnimationController _logoPopController;
  late AnimationController _formPopController;
  late AnimationController _bubbleController;

  // Gyroscope values for bubble movement
  double _gyroX = 0.0;
  double _gyroY = 0.0;

  @override
  void initState() {
    super.initState();

    // Logo pop-up animation
    _logoPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Form pop-up animation
    _formPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Bubble animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Start animations with stagger
    _startAnimations();

    // Listen to gyroscope
    gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroX = event.x.clamp(-2.0, 2.0);
          _gyroY = event.y.clamp(-2.0, 2.0);
        });
      }
    });
  }

  Future<void> _startAnimations() async {
    // Haptic feedback on page load
    await HapticFeedback.mediumImpact();

    // Logo pops up first
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoPopController.forward();

    // Then form pops up
    await Future.delayed(const Duration(milliseconds: 100));
    await _formPopController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoPopController.dispose();
    _formPopController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Haptic feedback on login attempt
      HapticFeedback.mediumImpact();

      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
            // Role is determined by the backend based on email
          ));
    }
  }

  void _onForgotPassword() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password - Coming soon')),
    );
  }

  void _onCreateAccount() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create account - Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Success haptic
          HapticFeedback.heavyImpact();
          if (state.role == UserRole.canteen) {
            context.goCanteenDashboard();
          } else {
            context.goStudentDashboard();
          }
        } else if (state is AuthError) {
          // Error haptic
          HapticFeedback.vibrate();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF29f094), // Bright green top (from logo.dart)
                Color(0xFF00E676), // Medium green
                Color(0xFF00C853), // Darker green bottom
              ],
            ),
          ),
          child: Stack(
            children: [
              // Gyroscope-sensitive bubble background
              ..._buildBubbles(),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),

                      // Logo with pop-up animation
                      _buildAnimatedLogo(),

                      SizedBox(height: 40.h),

                      // Login Form with pop-up animation
                      _buildAnimatedForm(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build gyroscope-sensitive animated bubbles
  List<Widget> _buildBubbles() {
    final bubbles = [
      _BubbleData(280, -50, -80, 0, 0.3),
      _BubbleData(180, 80, -60, -2, 0.25),
      _BubbleData(220, 320, -100, -4, 0.35),
      _BubbleData(160, 450, 10, -6, 0.2),
      _BubbleData(140, 180, 5, -8, 0.28),
      _BubbleData(200, 50, 150, -10, 0.32),
      _BubbleData(120, 250, 200, -12, 0.18),
      _BubbleData(260, 400, 120, -14, 0.38),
      _BubbleData(150, 100, 250, -16, 0.22),
      _BubbleData(190, 300, 50, -18, 0.3),
      _BubbleData(130, 150, 300, -20, 0.26),
      _BubbleData(240, 380, 180, -22, 0.34),
    ];

    return bubbles.map((data) => _buildBubble(data)).toList();
  }

  Widget _buildBubble(_BubbleData data) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        final value = _bubbleController.value;
        final offset = _calculateBubbleOffset(value, data.delay);

        // Apply gyroscope influence
        final gyroOffsetX = _gyroX * 30 * data.sensitivity;
        final gyroOffsetY = _gyroY * 30 * data.sensitivity;

        return Positioned(
          top: data.top + offset.dy + gyroOffsetY,
          right: data.right + offset.dx + gyroOffsetX,
          child: Container(
            width: data.size,
            height: data.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset _calculateBubbleOffset(double value, double delay) {
    final adjustedValue = (value + delay / 20) % 1.0;
    final x = 25 * math.sin(adjustedValue * 2 * math.pi);
    final y = -40 * math.cos(adjustedValue * 2 * math.pi);
    return Offset(x, y);
  }

  /// Build logo with pop-up animation
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoPopController,
      builder: (context, child) {
        final value = Curves.elasticOut.transform(_logoPopController.value);
        return Transform.scale(
          scale: value.clamp(0.0, 1.0),
          child: Opacity(
            opacity: _logoPopController.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _buildLogo(),
    );
  }

  /// Build the logo - Exact match to logo.dart (HTML design)
  Widget _buildLogo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 35.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: const Color(0xFF242a24), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top-left bracket - positioned with padding from edges
          Positioned(
            top: 8.h,
            left: 8.w,
            child: _buildCornerBracket(isTopLeft: true),
          ),

          // Bottom-right bracket - positioned with padding from edges
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: _buildCornerBracket(isTopLeft: false),
          ),

          // Text content - FOOD and GOOD touching with BE in between
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FOOD',
                style: TextStyle(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF242a24),
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
              Container(
                margin: EdgeInsets.zero, // No vertical margin - FOOD and GOOD touch BE
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF29f094),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'BE',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF242a24),
                  ),
                ),
              ),
              Text(
                'GOOD',
                style: TextStyle(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF242a24),
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build corner bracket (L-shape)
  Widget _buildCornerBracket({required bool isTopLeft}) {
    return Container(
      width: 55.w,
      height: 55.h,
      decoration: BoxDecoration(
        border: Border(
          top: isTopLeft
              ? const BorderSide(color: Color(0xFF242a24), width: 4)
              : BorderSide.none,
          left: isTopLeft
              ? const BorderSide(color: Color(0xFF242a24), width: 4)
              : BorderSide.none,
          bottom: !isTopLeft
              ? const BorderSide(color: Color(0xFF242a24), width: 4)
              : BorderSide.none,
          right: !isTopLeft
              ? const BorderSide(color: Color(0xFF242a24), width: 4)
              : BorderSide.none,
        ),
        borderRadius: isTopLeft
            ? BorderRadius.only(topLeft: Radius.circular(16.r))
            : BorderRadius.only(bottomRight: Radius.circular(16.r)),
      ),
    );
  }

  /// Build form with pop-up animation
  Widget _buildAnimatedForm() {
    return AnimatedBuilder(
      animation: _formPopController,
      builder: (context, child) {
        final value = Curves.easeOutBack.transform(_formPopController.value);
        return Transform.scale(
          scale: value.clamp(0.0, 1.0),
          child: Opacity(
            opacity: _formPopController.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _buildLoginCard(),
    );
  }

  /// Build the login card
  Widget _buildLoginCard() {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFF242a24), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Center(
              child: Column(
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF242a24),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Email field - Fixed styling (no dark mode effect, proper padding)
            _buildInputField(
              controller: _emailController,
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Password field
            _buildPasswordField(),

            SizedBox(height: 16.h),

            // Remember me & Forgot password
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _rememberMe = !_rememberMe);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: _rememberMe
                                ? const Color(0xFF29f094)
                                : const Color(0xFFCCCCCC),
                            width: 2,
                          ),
                          color: _rememberMe
                              ? const Color(0xFF29f094)
                              : Colors.transparent,
                        ),
                        child: _rememberMe
                            ? Icon(
                                Icons.check,
                                size: 14.w,
                                color: const Color(0xFF242a24),
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _onForgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF29f094),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Error message
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthError) {
                  return Container(
                    padding: EdgeInsets.all(12.r),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: const Color(0xFFEF4444),
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Sign In button with haptic
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return _buildPrimaryButton(
                  text: 'Sign In',
                  onPressed: state is AuthLoading ? null : _onLogin,
                  isLoading: state is AuthLoading,
                );
              },
            ),

            SizedBox(height: 24.h),

            // Divider
            Row(
              children: [
                const Expanded(
                    child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'or',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ),
                const Expanded(
                    child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
              ],
            ),

            SizedBox(height: 20.h),

            // Create account button
            _buildSecondaryButton(
              text: 'Create Account',
              onPressed: _onCreateAccount,
            ),

            SizedBox(height: 24.h),

            // Demo credentials
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0xFF29f094).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF29f094).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Credentials',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00C853),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Student: student@example.com / password123',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF242a24),
                    ),
                  ),
                  Text(
                    'Canteen: canteen@example.com / canteen123',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF242a24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build underline-style input field with fixed styling
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF242a24), // Fixed color - not affected by dark mode
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF999999), // Fixed hint color
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF999999),
          size: 22,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 2.w,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 2.w,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFF29f094),
            width: 2.w,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFEF4444),
            width: 2.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 14.h,
          horizontal: 4.w,
        ),
        // Ensure consistent styling regardless of theme
        fillColor: Colors.transparent,
        filled: false,
      ),
    );
  }

  /// Build password field with toggle
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF242a24), // Fixed color - not affected by dark mode
      ),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF999999), // Fixed hint color
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF999999),
          size: 22,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 2.w,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 2.w,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFF29f094),
            width: 2.w,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFEF4444),
            width: 2.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 14.h,
          horizontal: 4.w,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _obscurePassword = !_obscurePassword);
          },
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF999999),
            size: 20.w,
          ),
        ),
        // Ensure consistent styling regardless of theme
        fillColor: Colors.transparent,
        filled: false,
      ),
    );
  }

  /// Build primary button with haptic feedback
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      child: SizedBox(
        width: double.infinity,
        height: 54.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF29f094),
            foregroundColor: const Color(0xFF242a24),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r),
              side: const BorderSide(color: Color(0xFF242a24), width: 2.5),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF242a24)),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF242a24),
                  ),
                ),
        ),
      ),
    );
  }

  /// Build secondary button with haptic
  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF29f094),
            side: const BorderSide(color: Color(0xFF29f094), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF29f094),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bubble data for background animation
class _BubbleData {
  final double size;
  final double top;
  final double right;
  final double delay;
  final double sensitivity;

  _BubbleData(this.size, this.top, this.right, this.delay, this.sensitivity);
}
