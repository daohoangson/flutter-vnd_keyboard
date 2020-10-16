import 'package:flutter/material.dart';

import 'keyboard_key.dart';
import 'vnd_keyboard.dart';

class VndBottomSheet extends StatefulWidget {
  final TextEditingController controller;
  final EdgeInsetsGeometry valuePadding;

  const VndBottomSheet({
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          child: Row(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (_, __) => _buildValue(),
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
    _managedController?.dispose();
    super.dispose();
  }

  Widget _buildSymbol() => Text(
        'đ',
        style: Theme.of(context).textTheme.headline5.copyWith(
              color: Theme.of(context).disabledColor,
            ),
      );

  Widget _buildValue() {
    final intValue = _getValueInt();
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

    final suggestedValue = _getValueSuggested(intValue);
    final strSuggested = '$suggestedValue';
    InlineSpan spanSuggested;
    if (strSuggested.startsWith(strValue)) {
      final deltaSuggested = strSuggested.substring(strValue.length);
      if (deltaSuggested.isNotEmpty) {
        spanSuggested = TextSpan(
          text: ',$deltaSuggested',
          style: style.copyWith(color: theme.dividerColor),
        );
      }
    }

    final spanValue = TextSpan(
      children: spanSuggested != null ? [spanSuggested] : null,
      style: style,
      text: sb.toString(),
    );

    return RichText(text: spanValue);
  }

  int _getValueInt() => int.tryParse(controller.text) ?? 0;

  int _getValueSuggested(int intValue) {
    if (intValue == 0) return intValue;
    if (intValue > 999) return intValue;
    return intValue * 1000;
  }

  void _onTap(KeyboardKey key) {
    switch (key.type) {
      case KeyboardKeyType.delete:
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
        controller.text += key.value;
        break;
    }
  }
}
