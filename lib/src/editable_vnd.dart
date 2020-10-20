import 'package:flutter/material.dart';

import 'vnd_editing_controller.dart';
import 'vnd_keyboard_provider.dart';

/// A Vietnamese đồng editable widget.
class EditableVnd extends StatefulWidget {
  /// The color for auto zeros.
  ///
  /// Default: [ThemeData.dividerColor].
  final Color autoZerosColor;

  /// Whether this text field should focus itself
  /// if nothing else is already focused.
  ///
  /// Default: `false`.
  final bool autofocus;

  /// Controls the value being inputed.
  ///
  /// If null, this widget will create its own [VndEditingController].
  final VndEditingController controller;

  /// A widget to display the blinking cursor.
  ///
  /// If null, this widget will create its own widget.
  final Widget cursor;

  /// Defines the keyboard focus for this widget.
  ///
  /// If null, this widget will create its own [VndFocusNode].
  final VndFocusNode focusNode;

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

  /// The initial value.
  final int vnd;

  const EditableVnd({
    this.autoZerosColor,
    this.autofocus = false,
    this.controller,
    this.cursor,
    this.focusNode,
    Key key,
    this.style,
    this.symbol,
    this.textSelectionColor,
    this.vnd,
  }) : super(key: key);

  @override
  _EditableVndState createState() => _EditableVndState();
}

class _EditableVndState extends State<EditableVnd> {
  VndEditingController _managedController;
  VndEditingController get controller =>
      widget.controller ??
      (_managedController ??= VndEditingController(vnd: widget.vnd));

  VndFocusNode _managedFocusNode;
  VndFocusNode get focusNode =>
      widget.focusNode ?? (_managedFocusNode ??= VndFocusNode());

  Color get autoZerosColor =>
      widget.autoZerosColor ?? Theme.of(context).dividerColor;

  bool get hasFocus => focusNode.hasFocus;

  Color get textSelectionColor =>
      widget.textSelectionColor ?? Theme.of(context).textSelectionColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style ?? theme.textTheme.subtitle1;
    final cursor = widget.cursor ?? _BlinkingCursor(style);
    final dismissible = Dismissible(
      child: Text(
        ',000',
        style: style.copyWith(color: autoZerosColor),
      ),
      direction: DismissDirection.up,
      key: ValueKey(controller),
      onDismissed: _disableAutoZeros,
    );
    final symbol = widget.symbol ??
        Text('đ',
            style: style.copyWith(
              color: theme.disabledColor,
              fontSize: style.fontSize * .7,
            ));

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Row(
        children: [
          GestureDetector(
            child: AnimatedBuilder(
              animation: focusNode,
              builder: (_, child) => Container(
                child: child,
                color: !hasFocus
                    ? null
                    : (controller.isSelected ? textSelectionColor : null),
              ),
              child: Text(_formatValue(), style: style),
            ),
            onTap: _onTap,
          ),
          AnimatedBuilder(
            animation: focusNode,
            builder: (_, __) => Opacity(
              child: cursor,
              opacity: !hasFocus ? 0 : (controller.isSelected ? 0 : 1),
            ),
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
    );
  }

  @override
  void dispose() {
    _managedController?.dispose();
    _managedFocusNode?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.autofocus == true) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => focusNode.requestFocus(context, controller));
    }
  }

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

  void _onTap() {
    if (!hasFocus) {
      focusNode.requestFocus(context, controller);
    } else {
      controller.isSelected = !controller.isSelected;
    }
  }
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
