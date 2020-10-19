import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:flutter_vnd_keyboard/src/vnd_editing_controller.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() async {
  EditableText.debugDeterministicCursor = true;

  testGoldens('looks correct', (tester) async {
    final widget = Column(
      children: [
        RepaintBoundary(
          child: Builder(
            builder: (context) => Container(
              color: Theme.of(context).canvasColor,
              child: VndBottomSheet(),
            ),
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );

    await tester.pumpWidgetBuilder(
      widget,
      wrapper: (child) => MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Material(child: child),
      ),
    );

    await multiScreenGolden(
      tester,
      'vnd_bottom_sheet',
      devices: [
        Device.phone
            .copyWith(name: 'phone_light', brightness: Brightness.light),
        Device.tabletPortrait
            .copyWith(name: 'tablet_light', brightness: Brightness.light),
        Device.tabletLandscape
            .copyWith(name: 'wide_light', brightness: Brightness.light),
        Device.phone.copyWith(name: 'phone_dark', brightness: Brightness.dark),
        Device.tabletPortrait
            .copyWith(name: 'tablet_dark', brightness: Brightness.dark),
        Device.tabletLandscape
            .copyWith(name: 'wide_dark', brightness: Brightness.dark),
      ],
      finder: find.byType(VndKeyboard),
    );
  });

  testGoldens('accepts existing value', (tester) async {
    await tester.pumpWidgetBuilder(VndBottomSheet(
      controller: VndEditingController(vnd: 10000),
    ));

    await screenMatchesGolden(tester, 'vnd_bottom_sheet/existing_value');
  });

  testGoldens('includes auto zeros', (tester) async {
    await tester.pumpWidgetBuilder(VndBottomSheet(
      controller: VndEditingController.fromValue(VndEditingValue(rawValue: 10)),
    ));

    await screenMatchesGolden(tester, 'vnd_bottom_sheet/auto_zeros');
  });

  testWidgets('handles taps', (tester) async {
    final controller = VndEditingController();
    var result;

    await tester.pumpWidget(materialAppWrapper()(Builder(
      builder: (context) => RaisedButton(
        child: Text('RaisedButton'),
        onPressed: () async {
          result = await showModalBottomSheet(
            builder: (_) => VndBottomSheet(controller: controller),
            context: context,
          );
        },
      ),
    )));

    await tester.tap(find.text('RaisedButton'));
    await tester.pumpAndSettle();

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

    expect(result, isNull);
    await tester.tap(find.bySemanticsLabel('OK'));
    await tester.pumpAndSettle();
    expect(result, equals(12345678900));
  });

  testWidgets('disables autoZeros', (tester) async {
    final controller = VndEditingController.fromValue(
        VndEditingValue(autoZeros: true, rawValue: 100));
    await tester.pumpWidget(
        materialAppWrapper()(VndBottomSheet(controller: controller)));

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
    await tester.pumpWidget(
        materialAppWrapper()(VndBottomSheet(controller: controller)));

    expect(controller.isSelected, isFalse);

    await tester.tap(find.text('100,000'));
    expect(controller.isSelected, isTrue);

    await tester.tap(find.text('100,000'));
    expect(controller.isSelected, isFalse);
  });
}
