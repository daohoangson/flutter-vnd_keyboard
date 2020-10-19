import 'package:flutter/material.dart';

import 'vnd_editing_controller.dart';

class EditableVnd extends StatelessWidget {
  final Color autoZerosColor;
  final VndEditingController controller;
  final Widget cursor;
  final EdgeInsets padding;
  final TextStyle style;
  final Widget symbol;
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
    final cursor = this.cursor ?? const _BlinkingCursor();
    final style = this.style ?? Theme.of(context).textTheme.headline4;
    final dismissible = Dismissible(
      child: Text(
        ',000',
        style: style.copyWith(color: _autoZerosColor(context)),
      ),
      direction: DismissDirection.up,
      key: ValueKey(controller),
      onDismissed: _disableAutoZeros,
    );
    final symbol = this.symbol ?? const _VndSymbol();

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
  const _BlinkingCursor({Key key}) : super(key: key);

  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  Widget build(BuildContext context) => Opacity(
        child: Container(
          color: Theme.of(context).cursorColor,
          height: DefaultTextStyle.of(context).style.fontSize * 3,
          width: 2,
        ),
        opacity: animation.value,
      );

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
  }
}

class _VndSymbol extends StatelessWidget {
  const _VndSymbol({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        theme.textTheme.headline5.copyWith(color: theme.disabledColor);
    return Text('đ', style: style);
  }
}
