import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:flutter_vnd_keyboard/src/vnd_editing_controller.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

void main() async {
  testGoldens('looks correct', (tester) async {
    final focusedNode = _MockFocusNode();
    when(focusedNode.hasFocus).thenReturn(true);

    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 3)
      ..addScenario(
        '0đ',
        EditableVnd(),
      )
      ..addScenario(
        '10,000đ',
        EditableVnd(vnd: 10000),
      )
      ..addScenario(
        '10k (auto zeros)',
        EditableVnd(
          controller:
              VndEditingController.fromValue(VndEditingValue(rawValue: 10)),
          focusNode: focusedNode,
        ),
      )
      ..addScenario(
        '10,000đ (selected w/o focus)',
        EditableVnd(
          controller: VndEditingController.fromValue(VndEditingValue(
            rawValue: 10000,
            isSelected: true,
          )),
        ),
      )
      ..addScenario(
        '10,000đ (selected)',
        EditableVnd(
          controller: VndEditingController.fromValue(VndEditingValue(
            rawValue: 10000,
            isSelected: true,
          )),
          focusNode: focusedNode,
        ),
      )
      ..addScenario(
        '10k (auto zeros, selected)',
        EditableVnd(
          controller: VndEditingController.fromValue(VndEditingValue(
            rawValue: 10,
            isSelected: true,
          )),
          focusNode: focusedNode,
        ),
      )
      ..addScenario(
        '10k (auto zeros w/o focus)',
        EditableVnd(
          controller: VndEditingController.fromValue(VndEditingValue(
            rawValue: 10,
            isSelected: true,
          )),
        ),
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: Size(810, 270),
    );
    await screenMatchesGolden(
      tester,
      'editable_vnd',
      customPump: (_) async {},
    );
  });

  group('interactions', () {
    bool debugDeterministicCursor;

    setUp(() {
      debugDeterministicCursor = EditableText.debugDeterministicCursor;
      EditableText.debugDeterministicCursor = true;
    });

    tearDown(() {
      EditableText.debugDeterministicCursor = debugDeterministicCursor;
    });

    testWidgets('autofocus works', (tester) async {
      final focusNode = VndFocusNode();
      final widget = VndKeyboardProvider(
        child: EditableVnd(
          autofocus: true,
          focusNode: focusNode,
        ),
      );
      await tester.pumpWidget(materialAppWrapper()(widget));

      expect(focusNode.hasFocus, true);
    });

    testWidgets('disables autoZeros', (tester) async {
      final controller = VndEditingController.fromValue(
        VndEditingValue(autoZeros: true, rawValue: 100),
      );
      await tester.pumpWidget(
          materialAppWrapper()(EditableVnd(controller: controller)));

      expect(controller.autoZeros, isTrue);
      expect(controller.vnd, equals(100000));

      expect(find.text('100'), findsOneWidget);
      expect(find.text(',000'), findsOneWidget);

      await tester.drag(find.text(',000'), Offset(0, -100));
      await tester.pumpAndSettle();

      expect(controller.autoZeros, isFalse);
      expect(controller.vnd, equals(100));
    });

    testWidgets('tapping works', (tester) async {
      final controller = VndEditingController(vnd: 100000);
      final focusNode = VndFocusNode();
      final widget = VndKeyboardProvider(
        child: EditableVnd(
          controller: controller,
          focusNode: focusNode,
        ),
      );
      await tester.pumpWidget(materialAppWrapper()(widget));

      expect(focusNode.hasFocus, isFalse);
      await tester.tap(find.text('100,000'));

      expect(controller.isSelected, isFalse);
      expect(focusNode.hasFocus, isTrue);

      await tester.tap(find.text('100,000'));
      expect(controller.isSelected, isTrue);

      await tester.tap(find.text('100,000'));
      expect(controller.isSelected, isFalse);
    });

    testWidgets('enabled=false ignores taps', (tester) async {
      final controller = VndEditingController(vnd: 100000);
      final focusNode = VndFocusNode();
      final widget = VndKeyboardProvider(
        child: EditableVnd(
          controller: controller,
          enabled: false,
          focusNode: focusNode,
        ),
      );
      await tester.pumpWidget(materialAppWrapper()(widget));

      expect(focusNode.hasFocus, isFalse);
      await tester.tap(find.text('100,000'));
      expect(focusNode.hasFocus, isFalse);
    });

    group('didUpdateWidget', () {
      testWidgets('updates controller', (tester) async {
        final controller1 = VndEditingController(vnd: 10000);
        final controller2 = VndEditingController(vnd: 20000);
        final key = GlobalKey();

        await tester.pumpWidget(materialAppWrapper()(EditableVnd(
          controller: controller1,
          key: key,
        )));
        final state1 = key.currentState;
        expect(find.text('10,000'), findsOneWidget);

        await tester.pumpWidget(materialAppWrapper()(EditableVnd(
          controller: controller2,
          key: key,
        )));
        final state2 = key.currentState;
        expect(find.text('20,000'), findsOneWidget);

        expect(identical(state1, state2), isTrue);
      });

      testWidgets('updates vnd', (tester) async {
        final vnd1 = 10000;
        final vnd2 = 20000;
        final key = GlobalKey();

        await tester.pumpWidget(materialAppWrapper()(EditableVnd(
          key: key,
          vnd: vnd1,
        )));
        final state1 = key.currentState;
        expect(find.text('10,000'), findsOneWidget);

        await tester.pumpWidget(materialAppWrapper()(EditableVnd(
          key: key,
          vnd: vnd2,
        )));
        final state2 = key.currentState;
        expect(find.text('20,000'), findsOneWidget);

        expect(identical(state1, state2), isTrue);
      });
    });
  });
}

class _MockFocusNode extends Mock implements VndFocusNode {}
