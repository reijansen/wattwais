import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.child,
    this.background = AppColors.ink,
    this.withBottomPadding = true,
  });

  final Widget child;
  final Color background;
  final bool withBottomPadding;

  @override
  Widget build(BuildContext context) {
    // Collect the unsafe structural window insertions (notch + system navigation bars)
    final viewPadding = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: background,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Compute the target defensive padding dynamically
            final bottomSpacer = withBottomPadding 
                ? (84.0 + viewPadding.bottom).clamp(100.0, 140.0)
                : (24.0 + viewPadding.bottom).clamp(24.0, 48.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                24,
                AppSpacing.page,
                bottomSpacer,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Guarantees internal cross-axis alignments function perfectly
                  minWidth: constraints.maxWidth,
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}