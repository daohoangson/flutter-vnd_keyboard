import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/src/vnd_row.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() async {
  debugCheckIntrinsicSizes = true;

  testGoldens('looks correct', (tester) async {
    const surfaceWidth = 810.0;
    const columns = 3;
    const widthToHeightRatio = 2.5;

    final builder = GoldenBuilder.grid(
      columns: columns,
      widthToHeightRatio: widthToHeightRatio,
    )
      ..addScenario(
        'In column',
        Column(
          children: [
            VndRow(children: const [Text('foo')]),
            VndRow(children: const [Text('bar')]),
          ],
        ),
      )
      ..addScenario(
        'In row',
        Row(
          children: [
            VndRow(children: const [Text('foo')]),
            VndRow(children: const [Text('bar')]),
          ],
        ),
      )
      ..addScenario(
        'In stack',
        Stack(
          children: [
            VndRow(children: const [Text('foo')]),
            VndRow(children: const [Text('bar')]),
          ],
        ),
      )
      ..addScenario(
        'Baseline row: no children',
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('big', style: TextStyle(fontSize: 30)),
            VndRow(),
          ],
        ),
      )
      ..addScenario(
        'Baseline row: big then small',
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            VndRow(
              children: const [
                Text('big', style: TextStyle(fontSize: 30)),
              ],
            ),
            VndRow(children: const [Text('small')]),
          ],
        ),
      )
      ..addScenario(
        'Baseline row: small then big',
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            VndRow(children: const [Text('small')]),
            VndRow(
              children: const [
                Text('big', style: TextStyle(fontSize: 30)),
              ],
            ),
          ],
        ),
      )
      ..addScenario(
        'IntrinsicHeight: no children',
        IntrinsicHeight(
          child: VndRow(),
        ),
      )
      ..addScenario(
        'IntrinsicHeight: 1 child',
        IntrinsicHeight(
          child: VndRow(children: const [Text('foo')]),
        ),
      )
      ..addScenario(
        'IntrinsicHeight: 2 children',
        IntrinsicHeight(
          child: VndRow(children: const [Text('foo'), Text('bar')]),
        ),
      )
      ..addScenario(
        'IntrinsicWidth: no children',
        IntrinsicWidth(
          child: VndRow(),
        ),
      )
      ..addScenario(
        'IntrinsicWidth: 1 child',
        IntrinsicWidth(
          child: VndRow(children: const [Text('foo')]),
        ),
      )
      ..addScenario(
        'IntrinsicWidth: 2 children',
        IntrinsicWidth(
          child: VndRow(children: const [Text('foo'), Text('bar')]),
        ),
      )
      ..addScenario(
        'No children',
        VndRow(),
      )
      ..addScenario(
        '1 child',
        VndRow(children: const [Text('foo')]),
      )
      ..addScenario(
        '2 children',
        VndRow(children: const [Text('foo'), Text('bar')]),
      )
      ..addScenario(
        '100 children',
        ClipRect(
          child: VndRow(
            children: List.generate(
              100,
              (index) => Text('index=$index'),
            ),
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
      'vnd_row',
      customPump: (_) async {},
    );
  });

  testWidgets('hitTestChildren works', (tester) async {
    var tapped = 0;
    final widget = VndRow(
      children: [
        ElevatedButton(
          onPressed: () => tapped++,
          child: const Text('Tap me'),
        ),
      ],
    );
    await tester.pumpWidget(materialAppWrapper()(widget));

    await tester.tap(find.text('Tap me'));
    expect(tapped, equals(1));
  });
}
