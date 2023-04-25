import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() async {
  var debugDeterministicCursor = false;

  setUp(() {
    debugDeterministicCursor = EditableText.debugDeterministicCursor;
    EditableText.debugDeterministicCursor = true;
  });

  tearDown(() {
    EditableText.debugDeterministicCursor = debugDeterministicCursor;
  });

  testGoldens('looks correct', (tester) async {
    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
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

  testWidgets('handles taps', (tester) async {
    final controller = VndEditingController();
    var result;

    await tester.pumpWidget(materialAppWrapper()(Builder(
      builder: (context) => ElevatedButton(
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
}
