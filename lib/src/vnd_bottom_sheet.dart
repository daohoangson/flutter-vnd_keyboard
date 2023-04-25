import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

/// A Vietnamese đồng bottom sheet.
class VndBottomSheet extends StatelessWidget {
  /// Controls the value being inputed.
  ///
  /// If null, this widget will create its own [VndEditingController].
  final VndEditingController? controller;

  /// The initial value.
  final int? vnd;

  /// Creates a VND bottom sheet.
  const VndBottomSheet({this.controller, super.key, this.vnd}) : super();

  @override
  Widget build(BuildContext context) => VndKeyboardProvider(
        mainAxisSize: MainAxisSize.min,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: EditableVnd(
            autofocus: true,
            controller: controller,
            onDone: (vnd) => Navigator.pop(context, vnd),
            style: Theme.of(context).textTheme.headlineMedium,
            vnd: vnd,
          ),
        ),
      );
}
