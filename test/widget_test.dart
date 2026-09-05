import 'package:flutter_test/flutter_test.dart';
import 'package:nviti_demo_bank_flutter/main.dart';

void main() {
  testWidgets('bank home exposes the Nviti chat entry point', (tester) async {
    await tester.pumpWidget(const DemoBankApp());
    expect(find.text('Nviti Demo Bank'), findsOneWidget);
    expect(find.text('₦1,248,650.00'), findsOneWidget);
    expect(find.text('Chat with Nia'), findsOneWidget);
  });
}
