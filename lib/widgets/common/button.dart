import 'package:flutter/material.dart';
import 'package:sori/theme/theme.dart';

enum AppButtonVariant {
  defaultVariant,
  destructive,
  outline,
  secondary,
  ghost,
  link,
}

enum AppButtonSize { defaultSize, sm, lg, icon }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool disabled;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.defaultVariant,
    this.size = AppButtonSize.defaultSize,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(AppRadius.md),
      type: MaterialType.button,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: _getHoverColor(),
        splashColor: _getSplashColor(),
        highlightColor: _getHighlightColor(),
        child: Container(
          height: _getHeight(),
          width: size == AppButtonSize.icon ? _getHeight() : null,
          padding: _getPadding(),
          alignment: Alignment.center,
          decoration: variant == AppButtonVariant.outline
              ? BoxDecoration(
                  border: Border.all(color: AppColors.gray200),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                )
              : null,
          child: DefaultTextStyle(
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 14,
              fontWeight: AppFontWeight.medium,
              fontFamily: 'Pretendard',
            ),
            child: IconTheme(
              data: IconThemeData(color: _getTextColor(), size: 16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (disabled) {
      return AppColors.gray100;
    }
    switch (variant) {
      case AppButtonVariant.defaultVariant:
        return AppColors.gray900;
      case AppButtonVariant.destructive:
        return AppColors.red500;
      case AppButtonVariant.secondary:
        return AppColors.white;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
      case AppButtonVariant.link:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (disabled) {
      return AppColors.gray400;
    }
    switch (variant) {
      case AppButtonVariant.defaultVariant:
        return AppColors.gray50;
      case AppButtonVariant.destructive:
        return AppColors.gray50;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
      case AppButtonVariant.link:
      case AppButtonVariant.secondary:
        return AppColors.gray900;
    }
  }

  Color? _getHoverColor() {
    if (disabled) return null;
    switch (variant) {
      case AppButtonVariant.defaultVariant:
        return AppColors.gray900.withOpacity(0.9);
      case AppButtonVariant.destructive:
        return AppColors.red500.withOpacity(0.9);
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppColors.gray100;
      case AppButtonVariant.secondary:
        return AppColors.gray100.withOpacity(0.8);
      case AppButtonVariant.link:
        return null;
    }
  }

  Color? _getSplashColor() {
    if (disabled) return null;
    return AppColors.gray200.withOpacity(0.2);
  }

  Color? _getHighlightColor() {
    if (disabled) return null;
    return Colors.transparent;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.defaultSize:
        return 40;
      case AppButtonSize.sm:
        return 36;
      case AppButtonSize.lg:
        return 44;
      case AppButtonSize.icon:
        return 40;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (size == AppButtonSize.icon) return EdgeInsets.zero;
    switch (size) {
      case AppButtonSize.defaultSize:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32);
      case AppButtonSize.icon:
        return EdgeInsets.zero;
    }
  }
}
