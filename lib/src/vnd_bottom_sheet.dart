import 'package:flutter/material.dart';

import 'editable_vnd.dart';
import 'vnd_editing_controller.dart';
import 'keyboard_key.dart';
import 'vnd_keyboard.dart';

/// A Vietnamese đồng bottom sheet.
class VndBottomSheet extends StatefulWidget {
  /// Controls the value being inputed.
  ///
  /// If null, this widget will create its own [VndEditingController].
  final VndEditingController controller;

  /// A widget to display the current value.
  ///
  /// If null, this widget will create its own [EditableVnd].
  final Widget editable;

  /// Creates a VND bottom sheet.
  const VndBottomSheet({
    this.controller,
    this.editable,
    Key key,
  }) : super(key: key);

  @override
  _VndBottomSheetState createState() => _VndBottomSheetState();
}

class _VndBottomSheetState extends State<VndBottomSheet> {
  VndEditingController _managedController;
  VndEditingController get controller =>
      widget.controller ?? (_managedController ??= VndEditingController());

  @override
  Widget build(BuildContext context) => Column(
        children: [
          widget.editable ??
              EditableVnd(
                controller,
                style: Theme.of(context).textTheme.headline4,
              ),
          VndKeyboard(onTap: _onTap),
        ],
        mainAxisSize: MainAxisSize.min,
      );

  @override
  void dispose() {
    _managedController?.dispose();
    super.dispose();
  }

  void _onTap(KeyboardKey key) {
    switch (key.type) {
      case KeyboardKeyType.delete:
        controller.delete();
        break;
      case KeyboardKeyType.done:
        Navigator.pop(context, controller.vnd);
        break;
      case KeyboardKeyType.value:
        controller.append(key.value);
        break;
    }
  }
}
