import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF151D25),
    this.foreground = AppColors.text,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // Guarantees an accessible 44x44 minimum interactive boundary 
    // without altering the underlying 34x34 visual design.
    return SizedBox(
      width: 44,
      height: 44,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        containedInkWell: false,
        highlightColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: foreground,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}