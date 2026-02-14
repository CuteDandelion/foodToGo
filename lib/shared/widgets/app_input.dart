import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';

/// Input field variants
enum InputVariant { outlined, filled }

/// Reusable input field widget
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.variant = InputVariant.outlined,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final InputVariant variant;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          style: TextStyle(
            fontSize: 16.sp,
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          decoration: _buildDecoration(theme),
        ),
        if (helperText != null && errorText == null) ...[
          SizedBox(height: 4.h),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.error,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildDecoration(ThemeData theme) {
    final borderRadius = BorderRadius.circular(12.r);

    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              size: 20.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            )
          : null,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: maxLines > 1 ? 16.h : 0,
      ),
      filled: variant == InputVariant.filled,
      fillColor:
          variant == InputVariant.filled ? theme.colorScheme.surface : null,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: theme.dividerTheme.color ?? AppTheme.lightBorder,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: theme.dividerTheme.color ?? AppTheme.lightBorder,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: AppTheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: AppTheme.error,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: AppTheme.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: (theme.dividerTheme.color ?? AppTheme.lightBorder)
              .withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      hintStyle: TextStyle(
        fontSize: 16.sp,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      errorStyle: const TextStyle(height: 0),
    );
  }
}
