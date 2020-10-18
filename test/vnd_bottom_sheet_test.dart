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
}
