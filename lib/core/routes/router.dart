import "package:go_router/go_router.dart";
import "package:wattwais/core/routes/screen_routes.dart";

import "package:wattwais/screens/dashboard.dart";
import "package:wattwais/screens/splash_screen.dart";
// import "package:wattwais/screens/profilescreen.dart";
import "package:wattwais/screens/tipsscreen.dart";
import "package:wattwais/screens/statscreen.dart";
import "package:wattwais/screens/predict_bill_screen.dart";
import "package:wattwais/screens/adjust_screen.dart";
import "package:wattwais/screens/notifications_screen.dart";

class WattwaisRouter {
  static final router = GoRouter(
    initialLocation: Routes.splashscreen,

    routes: [
      GoRoute(
        path: Routes.splashscreen,
        builder: (context, state) => const LogoScreen(),
      ),

      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const Dashboard(),
      ),

      // GoRoute(
      //   path: Routes.profilescreen,
      //   builder: (context, state) => const ProfileScreen(),
      // ),

      GoRoute(
        path: Routes.tipsscreen,
        builder: (context, state) => const TipsScreen(),
      ),

      GoRoute(
        path: Routes.statscreen,
        builder: (context, state) => const StatsScreen(),
      ),
      
      GoRoute(
        path: Routes.adjustscreen,
        builder: (context, state) => const AdjustValuesScreen(),
      ),

      GoRoute(
        path: Routes.predictBill,
        builder: (context, state) => const PredictBillScreen(),
      ),

      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
