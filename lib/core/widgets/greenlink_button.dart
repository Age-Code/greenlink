import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, disabled }

class GreenlinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;

  const GreenlinkButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color fgColor;

    switch (type) {
      case ButtonType.primary:
        bgColor = theme.primaryColor;
        fgColor = theme.primaryColorDark;
        break;
      case ButtonType.secondary:
        bgColor = theme.scaffoldBackgroundColor;
        fgColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
        break;
      case ButtonType.disabled:
        bgColor = theme.disabledColor.withValues(alpha: 0.1);
        fgColor = theme.disabledColor;
        break;
    }

    if (onPressed == null) {
      bgColor = theme.disabledColor.withValues(alpha: 0.1);
      fgColor = theme.disabledColor;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: type == ButtonType.secondary
                ? BorderSide(color: theme.disabledColor.withValues(alpha: 0.2))
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
