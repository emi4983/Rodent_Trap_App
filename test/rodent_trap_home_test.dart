import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodent_trap_app/screen/rodent_trap_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'rodent_trap_home_test.mocks.dart';

@GenerateMocks([http.Client, SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient client;

  setUp(() {
    client = MockClient();
  });

  testWidgets('startSensor - successful response', (WidgetTester tester) async {
    // Mock a successful HTTP response
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "ok"}', 200));

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.startSensor();

    await tester.pump();
    expect(state.status, equals("Monitoring for rodent..."));
  });

  testWidgets('startSensor - failed response', (WidgetTester tester) async {
    // Mock a failed HTTP response
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "error"}', 500));

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.startSensor();

    await tester.pump();
    expect(state.status, equals("Failed to start sensor."));
  });

  testWidgets('_checkTrapStatus - rodent trapped', (WidgetTester tester) async {
    // Mock a response indicating the rodent is trapped
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"status": "trapped"}', 200));

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.checkTrapStatus();

    await tester.pump();
    expect(state.status, equals("Rodent is trapped!"));
  });

  testWidgets('_checkTrapStatus - no rodent trapped', (WidgetTester tester) async {
    // Mock a response indicating no rodent is trapped
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"status": "not_trapped"}', 200));

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.checkTrapStatus();

    await tester.pump();
    expect(state.status, equals("No rodent trapped."));
  });

  testWidgets('resetTrap - successful reset', (WidgetTester tester) async {
    // Mock a successful reset response
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "ok"}', 200));

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.resetTrap();

    await tester.pump();
    expect(state.status, equals("Trap reset successfully."));
  });

  testWidgets('resetTrap - failed reset', (WidgetTester tester) async {
    // Mock a failed reset response
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "error"}', 500));

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.resetTrap();

    await tester.pump();
    expect(state.status, equals("Failed to reset the trap."));
  });

  testWidgets('logTrapEvent and retrieve logs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); // Mock shared preferences

    await tester.pumpWidget(MaterialApp(home: RodentTrapHomePage(client: client)));
    await tester.pumpAndSettle();

    final state = tester.state<RodentTrapHomePageState>(find.byType(RodentTrapHomePage));
    await state.logTrapEvent("Rodent trapped");

    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('trap_logs');
    expect(logs?.last.contains("Rodent trapped"), isTrue);
  });
}
