import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:wattwais/core/routes/screen_routes.dart';
import 'package:wattwais/services/ai_insights_service.dart';
import 'package:wattwais/services/prediction_store_service.dart';
import 'package:wattwais/widgets/bottom_nav.dart';

// Screen Imports
import 'tipsscreen.dart';
import 'statscreen.dart';
import 'homescreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _tab = 0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _aiInsightsService = const AiInsightsService();
  String _name = 'Put Name Here';
  String _insightsKey = '';
  Future<Map<String, dynamic>?>? _insightsFuture;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('profile')
        .get();

    final name = (doc.data()?['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty && mounted) {
      setState(() {
        _name = name;
      });
    }
  }

  Future<void> _editName() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final controller = TextEditingController(
      text: _name == 'Put Name Here' ? '' : _name,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'Put Name Here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final next = controller.text.trim();
                final value = next.isEmpty ? 'Put Name Here' : next;
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('settings')
                    .doc('profile')
                    .set({'name': value});
                if (!dialogContext.mounted) return;
                setState(() {
                  _name = value;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt screen layouts if viewed on tablets or landscape screen configurations
        final bool isWideLayout = constraints.maxWidth > 720;

        return StreamBuilder<Map<String, dynamic>?>(
          stream: PredictionStoreService.streamLatestPrediction(),
          builder: (context, snapshot) {
            final latest = snapshot.data;
            final prediction =
                latest?['prediction_result'] as Map<String, dynamic>?;
            final bill =
                (prediction?['estimated_bill'] as num?)?.toDouble() ?? 0.0;
            final usage =
                (prediction?['estimated_monthly_kwh'] as num?)?.toDouble() ??
                0.0;
            final baseline =
                (prediction?['historical_monthly_kwh'] as num?)?.toDouble() ??
                1.0;
            final currentKey = _insightCacheKey(latest);
            if (currentKey != _insightsKey) {
              _insightsKey = currentKey;
              _insightsFuture = _aiInsightsService.generateInsights(
                name: _name,
                latestPrediction: latest,
              );
            }

            return FutureBuilder<Map<String, dynamic>?>(
              future: _insightsFuture,
              builder: (context, insightsSnapshot) {
                final aiInsights = insightsSnapshot.data;

                return Scaffold(
                  body: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isWideLayout ? 600 : double.infinity,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        child: IndexedStack(
                          key: ValueKey(_tab),
                          index: _tab,
                          children: [
                            HomeScreen(
                              onPredict: () {
                                context.go(Routes.predictBill);
                              },
                              onTapNotifications: () {
                                context.push(Routes.notifications);
                              },
                              bill: bill,
                              usage: usage,
                              budgetUsage: baseline,
                              latestPrediction: latest,
                              aiInsights: aiInsights,
                              name: _name,
                              onEditName: _editName,
                            ),
                            StatsScreen(
                              latestPrediction: latest,
                              aiInsights: aiInsights,
                            ),
                            TipsScreen(
                              latestPrediction: latest,
                              aiInsights: aiInsights,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottomNavigationBar: const WattBottomNav(currentIndex: 0),
                );
              },
            );
          },
        );
      },
    );
  }

  String _insightCacheKey(Map<String, dynamic>? latest) {
    if (latest == null) return 'none';
    final prediction = latest['prediction_result'] as Map<String, dynamic>?;
    final bill = prediction?['estimated_bill'];
    final kwh = prediction?['estimated_monthly_kwh'];
    final timestamp = latest['created_at']?.toString() ?? '';
    return '$timestamp|$bill|$kwh|$_name';
  }
}
