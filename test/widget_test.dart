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
    await tester.tap(find.text('Browse plans'));
    await tester.pumpAndSettle();
    expect(find.text('Silver plan'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('DEMO EXPERIENCE'), findsOneWidget);
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
}
