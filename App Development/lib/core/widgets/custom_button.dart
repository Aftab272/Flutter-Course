import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outline, text, lime }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 46,
    this.padding,
  });

  static const Color _brandBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor(context);

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 17, color: textColor),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );

    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10);

    Widget button;
    switch (type) {
      case ButtonType.primary:
      case ButtonType.lime:
      case ButtonType.secondary:
      case ButtonType.outline:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _brandBlue.withOpacity(0.6),
            disabledForegroundColor: Colors.white,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case ButtonType.text:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }

  Color _getTextColor(BuildContext context) {
    return Colors.white;
  }
}

