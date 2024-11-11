import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodent_trap_app/screen/rodent_trap_home.dart';

void main() {
  testWidgets('Rodent Trap UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Trap Status: Unknown'), findsOneWidget);

    expect(find.byKey(Key('startMonitoringButton')), findsOneWidget);
    expect(find.byKey(Key('resetTrapButton')), findsOneWidget);

    await tester.tap(find.byKey(Key('startMonitoringButton')));
    await tester.pump();
    expect(find.byKey(Key('startMonitoringButton')), findsOneWidget);

    await tester.tap(find.byKey(Key('resetTrapButton')));
    await tester.pump();
    expect(find.byKey(Key('resetTrapButton')), findsOneWidget);
  });
}
