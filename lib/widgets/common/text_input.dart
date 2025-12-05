import 'package:flutter/material.dart';
import 'package:sori/theme/theme.dart';

enum AppTextFieldVariant { filled }

class AppTextField extends StatelessWidget {
  final AppTextFieldVariant variant;

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.variant = AppTextFieldVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      style: AppTextStyle.body,
      cursorColor: AppColors.slate900,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyle.body.copyWith(color: AppColors.gray500),
        filled: true,
        fillColor: _backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s5,
          vertical: AppSpace.s4,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: _border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: _border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: _border, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.red500, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.red500, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gray100, width: 1),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (variant == AppTextFieldVariant.filled) {
      return AppColors.white;
    }

    return AppColors.white;
  }

  Color get _border {
    if (variant == AppTextFieldVariant.filled) {
      return AppColors.gray100;
    }

    return AppColors.gray100;
  }
}
