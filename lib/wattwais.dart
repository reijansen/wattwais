import "package:flutter/material.dart";
import "package:wattwais/core/routes/router.dart";
import "package:wattwais/core/theme/app_theme.dart";

class WattwAIsApp extends StatelessWidget {
  const WattwAIsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "WattwAIs",
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: WattwaisRouter.router,
    );
  }
}
