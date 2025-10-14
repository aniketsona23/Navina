import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Custom text field with consistent styling
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        hintStyle: const TextStyle(
          color: AppTheme.mediumGray,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(color: borderColor ?? AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(color: borderColor ?? AppTheme.borderColor),
        ),
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        fillColor: fillColor ?? Colors.white,
        filled: true,
      ),
    );
  }
}

/// Switch tile with consistent styling
class AppSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool value;
  final void Function(bool)? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon != null
          ? Icon(
              leadingIcon,
              color: AppTheme.textPrimary,
              size: 24,
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor ?? AppTheme.primaryColor,
        inactiveThumbColor: inactiveColor ?? AppTheme.mediumGray,
        inactiveTrackColor: AppTheme.lightGray,
      ),
    );
  }
}

/// Dropdown with consistent styling
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hintText;
  final IconData? icon;
  final Color? dropdownColor;
  final Color? iconColor;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hintText,
    this.icon,
    this.dropdownColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      hint: hintText != null ? Text(hintText!) : null,
      icon: icon != null
          ? Icon(
              icon,
              color: iconColor ?? AppTheme.textPrimary,
            )
          : null,
      dropdownColor: dropdownColor ?? Colors.white,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}

/// Slider with consistent styling
class AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final void Function(double)? onChanged;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    this.label,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor ?? AppTheme.primaryColor,
            inactiveTrackColor: inactiveColor ?? AppTheme.lightGray,
            thumbColor: activeColor ?? AppTheme.primaryColor,
            overlayColor: (activeColor ?? AppTheme.primaryColor).withValues(alpha: 0.2),
            valueIndicatorColor: activeColor ?? AppTheme.primaryColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            label: label != null ? value.toStringAsFixed(1) : null,
          ),
        ),
      ],
    );
  }
}
