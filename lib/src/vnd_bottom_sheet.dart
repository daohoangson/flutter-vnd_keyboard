import 'package:flutter/material.dart';

import 'editable_vnd.dart';
import 'vnd_editing_controller.dart';
import 'keyboard_key.dart';
import 'vnd_keyboard.dart';

class VndBottomSheet extends StatefulWidget {
  final VndEditingController controller;
  final Widget editable;

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

  Widget editable;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          editable,
          VndKeyboard(onTap: _onTap),
        ],
        mainAxisSize: MainAxisSize.min,
      );

  @override
  void dispose() {
    _managedController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    editable = widget.editable ?? EditableVnd(controller);
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
