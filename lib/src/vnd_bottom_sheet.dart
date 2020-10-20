import 'dart:async';

import 'package:flutter/material.dart';

import 'editable_vnd.dart';
import 'vnd_editing_controller.dart';
import 'vnd_keyboard_provider.dart';

/// A Vietnamese đồng bottom sheet.
class VndBottomSheet extends StatefulWidget {
  /// Controls the value being inputed.
  ///
  /// If null, this widget will create its own [VndEditingController].
  final VndEditingController controller;

  /// The initial value.
  final int vnd;

  /// Creates a VND bottom sheet.
  const VndBottomSheet({
    this.controller,
    Key key,
    this.vnd,
  }) : super(key: key);

  @override
  _VndBottomSheetState createState() => _VndBottomSheetState();
}

class _VndBottomSheetState extends State<VndBottomSheet> {
  VndEditingController _managedController;
  VndEditingController get controller =>
      widget.controller ??
      (_managedController ??= VndEditingController(vnd: widget.vnd));

  StreamSubscription _doneSubscription;

  @override
  Widget build(BuildContext context) => VndKeyboardProvider(
        child: Padding(
          child: EditableVnd(
            autofocus: true,
            controller: controller,
            style: Theme.of(context).textTheme.headline4,
          ),
          padding: const EdgeInsets.all(16),
        ),
        mainAxisSize: MainAxisSize.min,
      );

  @override
  void dispose() {
    _doneSubscription.cancel();
    _managedController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _doneSubscription = controller
        .onDone((controller) => Navigator.pop(context, controller.vnd));
  }
}
