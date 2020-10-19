import 'package:flutter/material.dart';

import 'vnd_editing_controller.dart';

/// A Vietnamese đồng editable widget.
class EditableVnd extends StatelessWidget {
  /// The color for auto zeros.
  ///
  /// Default: [ThemeData.dividerColor].
  final Color autoZerosColor;

  /// The controller.
  final VndEditingController controller;

  /// A widget to display the blinking cursor.
  ///
  /// If null, this widget will create its own widget.
  final Widget cursor;

  /// The padding.
  ///
  /// Default: `16` on all sides.
  final EdgeInsets padding;

  /// The style to use for the text being edited.
  ///
  /// Default: [TextTheme.subtitle1].
  final TextStyle style;

  /// A widget to display the đ symbol.
  ///
  /// If null, this widget will create its own widget.
  final Widget symbol;

  /// The color for selection background.
  ///
  /// Default: [ThemeData.textSelectionColor].
  final Color textSelectionColor;

  const EditableVnd(
    this.controller, {
    this.autoZerosColor,
    this.cursor,
    Key key,
    this.padding = const EdgeInsets.all(16),
    this.style,
    this.symbol,
    this.textSelectionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = this.style ?? theme.textTheme.subtitle1;
    final cursor = this.cursor ?? _BlinkingCursor(style);
    final dismissible = Dismissible(
      child: Text(
        ',000',
        style: style.copyWith(color: _autoZerosColor(context)),
      ),
      direction: DismissDirection.up,
      key: ValueKey(controller),
      onDismissed: _disableAutoZeros,
    );
    final symbol = this.symbol ??
        Text('đ',
            style: style.copyWith(
              color: theme.disabledColor,
              fontSize: style.fontSize * .7,
            ));

    return Padding(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Row(
          children: [
            GestureDetector(
              child: Container(
                child: Text(_formatValue(), style: style),
                color:
                    controller.isSelected ? _textSelectionColor(context) : null,
              ),
              onTap: _toggleIsSelected,
            ),
            Opacity(
              child: cursor,
              opacity: controller.isSelected ? 0 : 1,
            ),
            Visibility(
              child: dismissible,
              visible: controller.autoZeros &&
                  controller.vnd != controller.value.rawValue,
            ),
            symbol,
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      padding: padding,
    );
  }

  Color _autoZerosColor(BuildContext context) =>
      autoZerosColor ?? Theme.of(context).dividerColor;

  void _disableAutoZeros(DismissDirection _) => controller.autoZeros = false;

  String _formatValue() {
    final rawValue = '${controller.value.rawValue}';
    final sb = StringBuffer();
    final l = rawValue.length;
    for (var i = 0; i < l; i++) {
      if (i > 0 && (l - i) % 3 == 0) {
        // add grouping separator manually to avoid the extra dependency
        sb.write(',');
      }

      sb.write(rawValue[i]);
    }

    return sb.toString();
  }

  Color _textSelectionColor(BuildContext context) =>
      textSelectionColor ?? Theme.of(context).textSelectionColor;

  void _toggleIsSelected() => controller.isSelected = !controller.isSelected;
}

class _BlinkingCursor extends StatefulWidget {
  final TextStyle style;

  _BlinkingCursor(this.style, {Key key}) : super(key: key);

  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  double height;

  @override
  Widget build(BuildContext context) => Opacity(
        child: Container(
          color: Theme.of(context).cursorColor,
          height: height,
          width: 2,
        ),
        opacity: animation.value,
      );

  @override
  void didUpdateWidget(covariant _BlinkingCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateHeight();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween<double>(begin: 1, end: 0).animate(controller)
      ..addListener(() => setState(() {}));

    if (!EditableText.debugDeterministicCursor) {
      controller.repeat(reverse: true);
    }

    _calculateHeight();
  }

  void _calculateHeight() {
    final tp = TextPainter(
      text: TextSpan(text: '123456', style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    height = tp.height;
  }
}
