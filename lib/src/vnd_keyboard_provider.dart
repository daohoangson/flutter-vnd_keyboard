import 'package:flutter/widgets.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

import 'vnd_keyboard.dart';

/// An object that can be used to obtain the [VndKeyboardProvider] focus.
class VndFocusNode extends ChangeNotifier {
  final _flutter = FocusNode();
  _State _state;

  /// Creates a focus node.
  VndFocusNode() {
    _flutter.addListener(_onFlutterChanged);
  }

  /// Whether this node has input focus.
  bool get hasFocus => _state != null;

  @override
  void dispose() {
    _flutter.dispose();
    super.dispose();
  }

  /// Requests the primary focus for this node.
  void requestFocus(BuildContext context, VndEditingController controller) {
    final state =
        context.dependOnInheritedWidgetOfExactType<_InheritedWidget>()?.state;
    if (state == null) return;

    state.focus(this, controller);
    FocusScope.of(context).requestFocus(_flutter);
  }

  /// Removes the focus on this node.
  void unfocus() => _state?.unfocus();

  void _onFocused(_State state) {
    _state = state;
    notifyListeners();
  }

  void _onUnfocused() {
    _state = null;
    notifyListeners();
  }

  void _onFlutterChanged() {
    if (!_flutter.hasFocus) {
      // keyboard is coming up for some other node, hide our keyboard
      unfocus();
    }
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
    Key key,
    @required this.child,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  State<VndKeyboardProvider> createState() => _State();
}

class _InheritedWidget extends InheritedWidget {
  final _State state;
  const _InheritedWidget(this.state, Widget child, {Key key})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedWidget old) => state != old.state;
}

class _State extends State<VndKeyboardProvider> {
  VndEditingController controller;
  VndFocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    Widget child = _InheritedWidget(this, widget.child);

    if (widget.mainAxisSize == MainAxisSize.max) {
      child = Expanded(child: child);
    }

    return Column(
      children: [
        child,
        Visibility(
          child: VndKeyboard(onTap: onTap),
          visible: focusNode != null,
        ),
      ],
      mainAxisSize: widget.mainAxisSize,
    );
  }

  void focus(VndFocusNode focusNode, VndEditingController controller) =>
      setState(() {
        this.focusNode?._onUnfocused();

        this.controller = controller;
        this.focusNode = focusNode;

        focusNode._onFocused(this);
      });

  void unfocus() => setState(() {
        focusNode?._onUnfocused();

        controller = null;
        focusNode = null;
      });

  void onTap(KeyboardKey key) {
    switch (key.type) {
      case KeyboardKeyType.delete:
        controller?.delete();
        break;
      case KeyboardKeyType.done:
        controller?.done();
        unfocus();
        break;
      case KeyboardKeyType.value:
        controller?.append(key.value);
        break;
    }
  }
}
