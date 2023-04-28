import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

void main() async {
  testGoldens('looks correct', (tester) async {
    final focusedNode = _MockFocusNode();
    when(() => focusedNode.hasFocus).thenReturn(true);

    const surfaceWidth = 810.0;
    const columns = 3;
    const widthToHeightRatio = 2.5;

    final builder = GoldenBuilder.grid(
      columns: columns,
      widthToHeightRatio: widthToHeightRatio,
    )
      ..addScenario(
        '0đ',
        const EditableVnd(),
      )
      ..addScenario(
        '10,000đ',
        const EditableVnd(vnd: 10000),
      )
      ..addScenario(
        '10k (auto zeros)',
        EditableVnd(
          controller: VndEditingController.fromValue(
            const VndEditingValue(rawValue: 10),
          ),
          focusNode: focusedNode,
        ),
      )
      ..addScenario(
        '10,000đ (selected w/o focus)',
        EditableVnd(
          controller: VndEditingController.fromValue(
            const VndEditingValue(
              rawValue: 10000,
              isSelected: true,
            ),
          ),
        ),
      )
      ..addScenario(
        '10,000đ (selected)',
        EditableVnd(
          controller: VndEditingController.fromValue(
            const VndEditingValue(
              rawValue: 10000,
              isSelected: true,
            ),
          ),
          focusNode: focusedNode,
        ),
      )
      ..addScenario(
        '10k (auto zeros, selected)',
        EditableVnd(
          controller: VndEditingController.fromValue(
            const VndEditingValue(
              rawValue: 10,
              isSelected: true,
            ),
          ),
          focusNode: focusedNode,
        ),
      )
      ..addScenario(
        '10k (auto zeros w/o focus)',
        EditableVnd(
          controller: VndEditingController.fromValue(
            const VndEditingValue(
              rawValue: 10,
              isSelected: true,
            ),
          ),
        ),
      )
      ..addScenario(
        'Overflow',
        ClipRect(
          child: EditableVnd(
            controller: VndEditingController.fromValue(
              const VndEditingValue(
                rawValue: 9223372036854775807,
                isSelected: true,
              ),
            ),
            style: const TextStyle(fontSize: 30),
          ),
        ),
      );

    final rows = (builder.scenarios.length / columns).ceil();
    // https://github.com/eBay/flutter_glove_box/blob/5af8ed5285d9fa261e5db054cbeab22814a93e32/packages/golden_toolkit/lib/src/golden_builder.dart#L135
    final mainAxisSpacing = 16 * (rows - 1);
    final surfaceHeight =
        (surfaceWidth / columns / widthToHeightRatio * rows) + mainAxisSpacing;

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: Size(surfaceWidth, surfaceHeight),
    );
    await screenMatchesGolden(
      tester,
      'editable_vnd',
      customPump: (_) async {},
    );
  });

  group('interactions', () {
    var debugDeterministicCursor = true;

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

    testWidgets('onDone is called', (tester) async {
      final controller = VndEditingController();
      var done = 0;
      final widget = VndKeyboardProvider(
        child: EditableVnd(
          controller: controller,
          onDone: (_) => done++,
        ),
      );
      await tester.pumpWidget(materialAppWrapper()(widget));

      expect(done, equals(0));
      controller.done();

      await tester.runAsync(() => Future.delayed(Duration.zero));
      expect(done, equals(1));
    });

    group('textInputAction', () {
      testWidgets('done dismisses keyboard', (tester) async {
        final controller = VndEditingController();
        final widget = VndKeyboardProvider(
          child: EditableVnd(
            autofocus: true,
            controller: controller,
            // ignore: avoid_redundant_argument_values
            textInputAction: TextInputAction.done,
          ),
        );
        await tester.pumpWidget(materialAppWrapper()(widget));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('OK'), findsOneWidget);
        controller.done();

        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('OK'), findsNothing);
      });

      testWidgets('requests next focus', (tester) async {
        final controller = VndEditingController();
        final textFn = FocusNode();
        final widget = VndKeyboardProvider(
          child: FocusScope(
            child: Column(
              children: [
                EditableVnd(
                  autofocus: true,
                  controller: controller,
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  focusNode: textFn,
                ),
              ],
            ),
          ),
        );
        await tester.pumpWidget(materialAppWrapper()(widget));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('OK'), findsOneWidget);
        expect(textFn.hasFocus, isFalse);
        controller.done();

        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('OK'), findsNothing);
        expect(textFn.hasFocus, isTrue);
      });

      testWidgets('receives next focus', (tester) async {
        final key = GlobalKey();
        final textFn = FocusNode();
        final widget = VndKeyboardProvider(
          child: FocusScope(
            child: Column(
              key: key,
              children: [
                TextField(
                  autofocus: true,
                  focusNode: textFn,
                ),
                const EditableVnd(),
              ],
            ),
          ),
        );
        await tester.pumpWidget(materialAppWrapper()(widget));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('OK'), findsNothing);
        expect(textFn.hasFocus, isTrue);

        final keyContext = key.currentContext;
        expect(keyContext, isNotNull);
        FocusScope.of(keyContext!).nextFocus();

        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('OK'), findsOneWidget);
        expect(textFn.hasFocus, isFalse);
      });
    });

    testWidgets('dragging disables autoZeros', (tester) async {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values
        const VndEditingValue(autoZeros: true, rawValue: 100),
      );
      await tester.pumpWidget(
        materialAppWrapper()(EditableVnd(controller: controller)),
      );

      expect(controller.autoZeros, isTrue);
      expect(controller.vnd, equals(100000));

      expect(find.text('100'), findsOneWidget);
      expect(find.text(',000'), findsOneWidget);

      await tester.drag(find.text(',000'), const Offset(0, -100));
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

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              controller: controller1,
              key: key,
            ),
          ),
        );
        final state1 = key.currentState;
        expect(find.text('10,000'), findsOneWidget);

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              controller: controller2,
              key: key,
            ),
          ),
        );
        final state2 = key.currentState;
        expect(find.text('20,000'), findsOneWidget);

        expect(identical(state1, state2), isTrue);
      });

      testWidgets('updates enabled', (tester) async {
        final focusNode = VndFocusNode();
        final key = GlobalKey();

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              // ignore: avoid_redundant_argument_values
              enabled: true,
              focusNode: focusNode,
              key: key,
            ),
          ),
        );
        final state1 = key.currentState;
        expect(focusNode.canRequestFocus, isTrue);
        expect(focusNode.skipTraversal, isFalse);

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              enabled: false,
              focusNode: focusNode,
              key: key,
            ),
          ),
        );
        final state2 = key.currentState;
        expect(focusNode.canRequestFocus, isFalse);
        expect(focusNode.skipTraversal, isTrue);

        expect(identical(state1, state2), isTrue);
      });

      testWidgets('updates focusNode', (tester) async {
        final focusNode1 = VndFocusNode();
        final focusNode2 = VndFocusNode();
        final key = GlobalKey();

        final symbolKey = GlobalKey();
        final symbol = SizedBox(key: symbolKey);

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              focusNode: focusNode1,
              key: key,
              symbol: symbol,
            ),
          ),
        );
        final state1 = key.currentState;
        final context1 = symbolKey.currentContext;
        final flutterFn1 = context1 != null ? Focus.of(context1) : null;
        expect(flutterFn1, isNotNull);

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              focusNode: focusNode2,
              key: key,
              symbol: symbol,
            ),
          ),
        );
        final state2 = key.currentState;
        final context2 = symbolKey.currentContext;
        final flutterFn2 = context2 != null ? Focus.of(context2) : null;

        expect(identical(state1, state2), isTrue);
        expect(identical(flutterFn1, flutterFn2), isFalse);
      });

      testWidgets('updates vnd', (tester) async {
        const vnd1 = 10000;
        const vnd2 = 20000;
        final key = GlobalKey();

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(
              key: key,
              vnd: vnd1,
            ),
          ),
        );
        final state1 = key.currentState;
        expect(find.text('10,000'), findsOneWidget);

        await tester.pumpWidget(
          materialAppWrapper()(
            EditableVnd(key: key, vnd: vnd2),
          ),
        );
        final state2 = key.currentState;
        expect(find.text('20,000'), findsOneWidget);

        expect(identical(state1, state2), isTrue);
      });
    });
  });
}

class _MockFocusNode extends Mock implements VndFocusNode {}
