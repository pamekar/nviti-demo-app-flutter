import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nviti_demo_bank_flutter/main.dart';

void main() {
  testWidgets('selects a use case, opens API catalogue and returns', (
    tester,
  ) async {
    await tester.pumpWidget(
      DemoBankApp(
        loader: (url) async => url.endsWith('use-cases')
            ? {
                'use_cases': [
                  {
                    'title': 'Health insurance',
                    'dashboard_url':
                        'https://hmo-demo.nvt.ng/api/v1/mobile/dashboard',
                  },
                ],
              }
            : {
                'id': 'hmo',
                'title': 'Health insurance',
                'notice': 'DEMO EXPERIENCE',
                'metrics': [
                  {'value': '2', 'label': 'Plans'},
                ],
                'actions': [
                  {
                    'title': 'Browse plans',
                    'items': ['Silver plan', 'Gold plan'],
                  },
                ],
              },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Health insurance'));
    await tester.pumpAndSettle();
    expect(find.text('2  Plans'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Browse plans'), 200);
    await tester.ensureVisible(find.text('Browse plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse plans'));
    await tester.pumpAndSettle();
    expect(find.text('Silver plan'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Browse plans'), findsOneWidget);
  });
  testWidgets('failed dashboard fetch has a working retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      DemoBankApp(
        loader: (_) async {
          calls++;
          if (calls == 1) {
            throw Exception('Offline');
          }
          return {'use_cases': <dynamic>[]};
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your experience'), findsOneWidget);
    expect(calls, 2);
  });
  testWidgets('native invitation dismisses without hiding the round launcher', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(DemoBankApp(loader: (_) async => {
      'id': 'banking', 'title': 'Banking', 'notice': 'DEMO',
      'chat_url': 'https://nviti-demo-bank.nvt.ng/chat/test?webview=1',
      'metrics': [{'value': '37', 'label': 'Supported banks'}], 'actions': <dynamic>[],
    }));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Dismiss chat invitation'), findsOneWidget);
    final launcher = find.byType(FloatingActionButton);
    expect(tester.widget<FloatingActionButton>(launcher).shape, isA<CircleBorder>());
    expect(tester.getCenter(launcher).dx, greaterThan(300));
    await tester.tap(find.byTooltip('Dismiss chat invitation'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Dismiss chat invitation'), findsNothing);
    expect(launcher, findsOneWidget);
    await tester.tap(find.byTooltip('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Ask assistant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
