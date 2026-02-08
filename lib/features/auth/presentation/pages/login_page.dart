import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../shared/services/mock_data_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';

import '../../domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthLoginRequested(
        studentId: _studentIdController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == UserRole.canteen) {
            context.goCanteenDashboard();
          } else {
            context.goStudentDashboard();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF8FAFC)],
                        ),
                        border: Border.all(color: AppTheme.primary, width: 2),
                        borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'FOOD',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.lightTextPrimary,
                              letterSpacing: 3,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              'BE',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'GOOD',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.lightTextPrimary,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Title
                  Text(
                    widget.role == 'canteen' ? 'Canteen Login' : 'Student Login',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sign in to access your account',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextSecondary,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Student ID field
                  AppInput(
                    controller: _studentIdController,
                    label: widget.role == 'canteen' ? 'Staff ID' : 'Student ID',
                    hint: widget.role == 'canteen' ? 'Enter staff ID' : 'Enter student ID',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ID';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Password field
                  AppInput(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.lightTextMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Remember me checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primary,
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.lightTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
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
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.error,
                                size: 20.w,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  state.message,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.error,
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

                  // Sign in button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Sign In',
                        onPressed: state is AuthLoading ? null : _onLogin,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Demo credentials hint
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Credentials:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Student: 61913042 / password123',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.lightTextSecondary,
                          ),
                        ),
                        Text(
                          'Canteen: canteen001 / canteen123',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.lightTextSecondary,
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
      ),
    );
  }
}
