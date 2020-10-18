import 'package:flutter/material.dart';

import 'keyboard_key.dart';
import 'vnd_keyboard.dart';

class VndBottomSheet extends StatefulWidget {
  final bool autoAppend000;
  final TextEditingController controller;
  final EdgeInsetsGeometry valuePadding;

  const VndBottomSheet({
    this.autoAppend000,
    Key key,
    this.controller,
    this.valuePadding,
  }) : super(key: key);

  @override
  _VndBottomSheetState createState() => _VndBottomSheetState();
}

class _VndBottomSheetState extends State<VndBottomSheet> {
  TextEditingController _managedController;
  TextEditingController get controller =>
      widget.controller ?? (_managedController ??= TextEditingController());

  bool _isSelectAll = false;
  bool _autoAppend000;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          child: Row(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (_, cursor) => _buildValue(cursor),
                child: _BlinkingCursor(),
              ),
              _buildSymbol(),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
          ),
          padding: widget.valuePadding ?? const EdgeInsets.all(16),
        ),
        VndKeyboard(
          onTap: _onTap,
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onController);
    _managedController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _autoAppend000 = widget.autoAppend000 ?? true;
    controller.addListener(_onController);
  }

  Widget _buildSymbol() => Text(
        'đ',
        style: Theme.of(context).textTheme.headline5.copyWith(
              color: Theme.of(context).disabledColor,
            ),
      );

  Widget _buildValue(Widget cursor) {
    final intValue = _getValueInt();
    final append000 = _getValueSuggested(intValue) > intValue;
    final strValue = '$intValue';
    final theme = Theme.of(context);
    final style = theme.textTheme.headline4;

    final sb = StringBuffer();
    final l = strValue.length;
    for (var i = 0; i < l; i++) {
      if (i > 0 && (l - i) % 3 == 0) {
        // add grouping separator manually to avoid the extra dependency
        sb.write(',');
      }

      sb.write(strValue[i]);
    }

    return Row(
      children: [
        GestureDetector(
          child: Container(
            child: Text(sb.toString(), style: style),
            color: _isSelectAll ? theme.textSelectionColor : null,
          ),
          onTap: () => setState(() => _isSelectAll = !_isSelectAll),
        ),
        Opacity(
          child: cursor,
          opacity: _isSelectAll ? 0 : 1,
        ),
        if (append000)
          Dismissible(
            child: Text(
              ',000',
              style: style.copyWith(color: theme.dividerColor),
            ),
            direction: DismissDirection.up,
            key: ValueKey(this),
            onDismissed: (direction) => setState(() => _autoAppend000 = false),
          ),
      ],
    );
  }

  int _getValueInt() => int.tryParse(controller.text) ?? 0;

  int _getValueSuggested(int intValue) {
    if (!_autoAppend000) return intValue;
    if (intValue == 0) return intValue;
    if (intValue > 999) return intValue;
    return intValue * 1000;
  }

  void _onController() {
    if (_isSelectAll) {
      setState(() => _isSelectAll = false);
    }
  }

  void _onTap(KeyboardKey key) {
    switch (key.type) {
      case KeyboardKeyType.delete:
        if (_isSelectAll) {
          controller.clear();
          return;
        }

        final current = controller.text;
        if (current.isNotEmpty) {
          final deleted = current.substring(0, current.length - 1);
          controller.text = deleted;
        }
        break;
      case KeyboardKeyType.done:
        Navigator.pop(context, _getValueSuggested(_getValueInt()));
        break;
      case KeyboardKeyType.numeric:
        if (_isSelectAll) {
          controller.text = key.value;
          return;
        }

        controller.text += key.value;
        break;
    }
  }
}

class _BlinkingCursor extends StatefulWidget {
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
