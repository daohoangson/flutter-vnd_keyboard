import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:flutter_vnd_keyboard/src/vnd_editing_controller.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() async {
  testGoldens('looks correct', (tester) async {
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 2)
      ..addScenario(
        '0đ',
        EditableVnd(VndEditingController()),
      )
      ..addScenario(
        '10,000đ',
        EditableVnd(VndEditingController(vnd: 10000)),
      )
      ..addScenario(
        '10,000đ (auto zeros)',
        EditableVnd(
          VndEditingController.fromValue(VndEditingValue(rawValue: 10)),
        ),
      )
      ..addScenario(
        '10,000đ (selected)',
        EditableVnd(
          VndEditingController.fromValue(VndEditingValue(
            rawValue: 10000,
            isSelected: true,
          )),
        ),
      )
      ..addScenario(
        '10,000đ (auto zeros, selected)',
        EditableVnd(
          VndEditingController.fromValue(VndEditingValue(
            rawValue: 10,
            isSelected: true,
          )),
        ),
      );

    await tester.pumpWidgetBuilder(builder.build());
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

    testWidgets('disables autoZeros', (tester) async {
      final controller = VndEditingController.fromValue(
        VndEditingValue(autoZeros: true, rawValue: 100),
      );
      await tester.pumpWidget(materialAppWrapper()(EditableVnd(controller)));

      expect(controller.autoZeros, isTrue);
      expect(controller.vnd, equals(100000));

      expect(find.text('100'), findsOneWidget);
      expect(find.text(',000'), findsOneWidget);

      await tester.drag(find.text(',000'), Offset(0, -100));
      await tester.pumpAndSettle();

      expect(controller.autoZeros, isFalse);
      expect(controller.vnd, equals(100));
    });

    testWidgets('toggles isSelected', (tester) async {
      final controller = VndEditingController(vnd: 100000);
      await tester.pumpWidget(materialAppWrapper()(EditableVnd(controller)));

      expect(controller.isSelected, isFalse);

      await tester.tap(find.text('100,000'));
      expect(controller.isSelected, isTrue);

      await tester.tap(find.text('100,000'));
      expect(controller.isSelected, isFalse);
    });
  });
}
