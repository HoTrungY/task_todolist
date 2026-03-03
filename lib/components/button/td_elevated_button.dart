import 'package:flutter/material.dart';
import 'package:todolist_app/resources/app_color.dart';

class TdElevatedButton extends StatelessWidget {
  TdElevatedButton({
    super.key,
    this.onPressed,
    this.height = 54.0,
    this.color = AppColor.red,
    this.borderColor = AppColor.red,
    required this.text,
    this.textColor = AppColor.white,
    this.fontSize = 16.8,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(12.0),
       splashColor = splashColor ?? AppColor.yellow.withValues(alpha: 0.8),
       highlightColor =
           highlightColor ?? AppColor.orange.withValues(alpha: 0.8);

  TdElevatedButton.outline({
    super.key,
    this.onPressed,
    this.height = 54.0,
    this.color = AppColor.white,
    this.borderColor = AppColor.red,
    required this.text,
    this.textColor = AppColor.red,
    this.fontSize = 16.8,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(12.0),
       splashColor = splashColor ?? AppColor.yellow.withValues(alpha: 0.8),
       highlightColor =
           highlightColor ?? AppColor.orange.withValues(alpha: 0.8);

  TdElevatedButton.small({
    super.key,
    this.onPressed,
    this.height = 38.0,
    this.color = AppColor.red,
    this.borderColor = AppColor.red,
    required this.text,
    this.textColor = AppColor.white,
    this.fontSize = 14.6,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(8.0),
       splashColor = splashColor ?? AppColor.yellow.withValues(alpha: 0.8),
       highlightColor = highlightColor ?? AppColor.green.withValues(alpha: 0.8);

  TdElevatedButton.smallOutline({
    super.key,
    this.onPressed,
    this.height = 38.0,
    this.color = AppColor.white,
    this.borderColor = AppColor.red,
    required this.text,
    this.textColor = AppColor.red,
    this.fontSize = 14.6,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(8.0),
       splashColor = splashColor ?? AppColor.yellow.withValues(alpha: 0.6),
       highlightColor = highlightColor ?? AppColor.green.withValues(alpha: 0.6);

  final Function()? onPressed;
  final double height;
  final Color color;
  final Color borderColor;
  final String text;
  final Color textColor;
  final double fontSize;
  final Icon? icon;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isDisable;
  final Color splashColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: isDisable ? null : onPressed,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Ink(
          padding: padding,
          height: height,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 2.0),
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 4.6)],
              isDisable
                  ? Center(
                      child: SizedBox.square(
                        dimension: height - 22.0,
                        child: CircularProgressIndicator(
                          color: textColor,
                          strokeWidth: 2.2,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
