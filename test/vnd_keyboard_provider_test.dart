import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() async {
  testWidgets('toggles keyboard', (tester) async {
    final controller = VndEditingController();
    final focusNode = VndFocusNode();
    final key = GlobalKey();

    await tester.pumpWidget(materialAppWrapper()(
        VndKeyboardProvider(child: SizedBox.shrink(key: key))));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('1'), findsNothing);

    focusNode.requestFocus(key.currentContext, controller);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('1'), findsOneWidget);

    focusNode.unfocus();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('1'), findsNothing);
  });

  group('already focused', () {
    VndEditingController controller;
    FocusNode flutterFn;
    VndFocusNode focusNode;
    GlobalKey key;

    setUp(() {
      controller = VndEditingController();
      flutterFn = FocusNode();
      focusNode = VndFocusNode();
      key = GlobalKey();
    });

    final _precondition = (WidgetTester tester) async {
      await tester.pumpWidget(materialAppWrapper()(VndKeyboardProvider(
        child: Column(
          children: [
            TextField(focusNode: flutterFn),
            SizedBox.shrink(key: key),
          ],
        ),
      )));

      focusNode.requestFocus(key.currentContext, controller);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('1'), findsOneWidget);
    };

    testWidgets('hides virtual keyboard over device keyboard', (tester) async {
      await _precondition(tester);

      flutterFn.requestFocus();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('1'), findsNothing);
    });

    testWidgets('handles taps', (tester) async {
      await _precondition(tester);

      await tester.tap(find.bySemanticsLabel('1'));
      expect(controller.vnd, equals(1000));

      await tester.tap(find.bySemanticsLabel('2'));
      expect(controller.vnd, equals(12000));

      await tester.tap(find.bySemanticsLabel('3'));
      expect(controller.vnd, equals(123000));

      await tester.tap(find.bySemanticsLabel('4'));
      expect(controller.vnd, equals(1234));

      await tester.tap(find.bySemanticsLabel('5'));
      expect(controller.vnd, equals(12345));

      await tester.tap(find.bySemanticsLabel('6'));
      expect(controller.vnd, equals(123456));

      await tester.tap(find.bySemanticsLabel('7'));
      expect(controller.vnd, equals(1234567));

      await tester.tap(find.bySemanticsLabel('8'));
      expect(controller.vnd, equals(12345678));

      await tester.tap(find.bySemanticsLabel('9'));
      expect(controller.vnd, equals(123456789));

      await tester.tap(find.bySemanticsLabel('000'));
      expect(controller.vnd, equals(123456789000));

      await tester.tap(find.bySemanticsLabel(String.fromCharCode(127)));
      expect(controller.vnd, equals(12345678900));

      expect(controller.isDone, false);
      await tester.tap(find.bySemanticsLabel('OK'));
      await tester.pumpAndSettle();
      expect(controller.isDone, true);
      expect(find.bySemanticsLabel('OK'), findsNothing);
    });
  });
}
