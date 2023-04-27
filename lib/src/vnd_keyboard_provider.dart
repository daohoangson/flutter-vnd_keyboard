import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

part 'editable_vnd.dart';

/// An object that can be used to obtain the [VndKeyboardProvider] focus.
class VndFocusNode extends ChangeNotifier {
  final _flutter = FocusNode();
  var _hasFocus = false;

  /// If true, this focus node may request the primary focus.
  bool get canRequestFocus => _flutter.canRequestFocus;

  /// Returns built-in focus node.
  FocusNode? get flutter => _flutter;

  /// Whether this node has input focus.
  bool get hasFocus => _hasFocus;

  /// If true, tells the focus traversal policy to skip over this node for
  /// purposes of the traversal algorithm.
  bool get skipTraversal => _flutter.skipTraversal;

  @override
  void dispose() {
    _flutter.dispose();
    super.dispose();
  }

  /// Requests the primary focus for this node.
  void requestFocus() => _flutter.requestFocus();

  /// Removes the focus on this node.
  void unfocus() => _flutter.unfocus();

  void _onFocusNodeFocused() {
    _hasFocus = true;
    notifyListeners();
  }

  void _onFocusNodeUnfocused() {
    _hasFocus = false;
    notifyListeners();
  }
}

/// A keyboard provider for multiple [EditableVnd] widgets.
class VndKeyboardProvider extends StatefulWidget {
  /// The [child] contained by this widget.
  final Widget child;

  /// How much height should be occupied.
  ///
  /// Default: [MainAxisSize.max].
  final MainAxisSize mainAxisSize;

  /// Creates a keyboard provider.
  const VndKeyboardProvider({
    super.key,
    required this.child,
    this.mainAxisSize = MainAxisSize.max,
  }) : super();

  @override
  State<VndKeyboardProvider> createState() => _State();
}

class _InheritedWidget extends InheritedWidget {
  final _State state;
  const _InheritedWidget(this.state, Widget child) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedWidget old) => state != old.state;
}

class _State extends State<VndKeyboardProvider> with WidgetsBindingObserver {
  VndEditingController? _controller;
  var _hasFocus = false;
  var _systemKeyboardIsVisible = false;

  @override
  Widget build(BuildContext context) {
    Widget child = _InheritedWidget(this, widget.child);

    if (widget.mainAxisSize == MainAxisSize.max) {
      child = Expanded(child: child);
    }

    return Column(
      mainAxisSize: widget.mainAxisSize,
      children: [
        child,
        Visibility(
          visible: _hasFocus && !_systemKeyboardIsVisible,
          child: VndKeyboard(onTap: _controller?.onTap),
        ),
      ],
    );
  }

  @override
  void didChangeMetrics() {
    final v = WidgetsBinding.instance.window.viewInsets.bottom > 0;
    if (v != _systemKeyboardIsVisible) {
      setState(() => _systemKeyboardIsVisible = v);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setController(VndEditingController? controller) {
    final hasFocus = controller != null;
    setState(() {
      _controller = controller;
      _hasFocus = hasFocus;
    });

    if (hasFocus) {
      WidgetsBinding.instance.addObserver(this);
      didChangeMetrics();
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
