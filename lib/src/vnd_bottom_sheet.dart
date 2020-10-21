import 'package:flutter/material.dart';

import 'vnd_editing_controller.dart';
import 'vnd_keyboard_provider.dart';

/// A Vietnamese đồng bottom sheet.
class VndBottomSheet extends StatelessWidget {
  /// Controls the value being inputed.
  ///
  /// If null, this widget will create its own [VndEditingController].
  final VndEditingController controller;

  /// The initial value.
  final int vnd;

  /// Creates a VND bottom sheet.
  const VndBottomSheet({this.controller, Key key, this.vnd}) : super(key: key);

  @override
  Widget build(BuildContext context) => VndKeyboardProvider(
        child: Padding(
          child: EditableVnd(
            autofocus: true,
            controller: controller,
            onDone: (vnd) => Navigator.pop(context, vnd),
            style: Theme.of(context).textTheme.headline4,
            vnd: vnd,
          ),
          padding: const EdgeInsets.all(16),
        ),
        mainAxisSize: MainAxisSize.min,
      );
}
