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
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: Size(810, 180),
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

    testGoldens('autofocus works', (tester) async {
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
  });
}

class _MockFocusNode extends Mock implements VndFocusNode {}
