import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double fontSize;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.textColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    this.iconSize = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color ?? theme.colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: iconSize, color: textColor ?? theme.colorScheme.primary),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 