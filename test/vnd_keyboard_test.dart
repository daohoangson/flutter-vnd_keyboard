import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() async {
  testGoldens('looks correct', (tester) async {
    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RepaintBoundary(
          child: Builder(
            builder: (context) => ColoredBox(
              color: Theme.of(context).canvasColor,
              child: const VndKeyboard(),
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
      'vnd_keyboard',
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

  testWidgets('fires onTap', (tester) async {
    final keys = <KeyboardKey>[];
    await tester.pumpWidget(materialAppWrapper()(VndKeyboard(onTap: keys.add)));

    await tester.tap(find.bySemanticsLabel('1'));
    expect(keys.last, equals(const KeyboardKey.numeric(1)));

    await tester.tap(find.bySemanticsLabel('2'));
    expect(keys.last, equals(const KeyboardKey.numeric(2)));

    await tester.tap(find.bySemanticsLabel('3'));
    expect(keys.last, equals(const KeyboardKey.numeric(3)));

    await tester.tap(find.bySemanticsLabel('4'));
    expect(keys.last, equals(const KeyboardKey.numeric(4)));

    await tester.tap(find.bySemanticsLabel('5'));
    expect(keys.last, equals(const KeyboardKey.numeric(5)));

    await tester.tap(find.bySemanticsLabel('6'));
    expect(keys.last, equals(const KeyboardKey.numeric(6)));

    await tester.tap(find.bySemanticsLabel('7'));
    expect(keys.last, equals(const KeyboardKey.numeric(7)));

    await tester.tap(find.bySemanticsLabel('8'));
    expect(keys.last, equals(const KeyboardKey.numeric(8)));

    await tester.tap(find.bySemanticsLabel('9'));
    expect(keys.last, equals(const KeyboardKey.numeric(9)));

    await tester.tap(find.bySemanticsLabel('000'));
    expect(keys.last, equals(KeyboardKey.zeros));

    await tester.tap(find.bySemanticsLabel(String.fromCharCode(127)));
    expect(keys.last, equals(KeyboardKey.delete));

    await tester.tap(find.bySemanticsLabel('OK'));
    expect(keys.last, equals(KeyboardKey.done));
  });

  group('keys', () {
    testWidgets('render default', (tester) async {
      await tester.pumpWidget(materialAppWrapper()(const VndKeyboard()));

      expect(find.byIcon(Icons.backspace), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('render custom', (tester) async {
      await tester.pumpWidget(
        materialAppWrapper()(
          const VndKeyboard(
            keyDelete: Text('keyDelete'),
            keyDone: Text('keyDone'),
          ),
        ),
      );

      expect(find.byIcon(Icons.backspace), findsNothing);
      expect(find.text('keyDelete'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsNothing);
      expect(find.text('keyDone'), findsOneWidget);
    });
  });
}
