part of 'vnd_keyboard_provider.dart';

/// A Vietnamese đồng editable widget.
class EditableVnd extends StatefulWidget {
  /// The color for auto zeros.
  ///
  /// Default: [ThemeData.dividerColor].
  final Color? autoZerosColor;

  /// Whether this text field should focus itself
  /// if nothing else is already focused.
  ///
  /// Default: `false`.
  final bool autofocus;

  /// Controls the value being inputed.
  ///
  /// If null, this widget will create its own [VndEditingController].
  final VndEditingController? controller;

  /// If false the text field is "disabled": it ignores taps.
  ///
  /// Default: `true`.
  final bool enabled;

  /// Defines the keyboard focus for this widget.
  ///
  /// If null, this widget will create its own [VndFocusNode].
  final VndFocusNode? focusNode;

  /// Called when the user indicates that they are done.
  final ValueChanged<int>? onDone;

  /// If false the cursor will be hidden.
  ///
  /// Default: [enabled].
  final bool? showCursor;

  /// The style to use for the text being edited.
  ///
  /// Default: [TextTheme.titleMedium].
  final TextStyle? style;

  /// A widget to display the đ symbol.
  ///
  /// If null, this widget will create its own widget.
  final Widget? symbol;

  /// The type of action button to use for the keyboard.
  ///
  /// Values and associated action when user taps Done:
  ///
  /// - [TextInputAction.done] -> unfocus (keyboard goes away)
  /// - [TextInputAction.next] -> next focus
  /// - Anything else will trigger no action
  ///
  /// Default [TextInputAction.done].
  final TextInputAction textInputAction;

  /// The color for selection background.
  ///
  /// Default: [DefaultSelectionStyle.selectionColor].
  final Color? textSelectionColor;

  /// The initial value.
  final int? vnd;

  const EditableVnd({
    this.autoZerosColor,
    this.autofocus = false,
    this.controller,
    this.enabled = true,
    this.focusNode,
    super.key,
    this.onDone,
    this.showCursor,
    this.style,
    this.symbol,
    this.textInputAction = TextInputAction.done,
    this.textSelectionColor,
    this.vnd,
  }) : super();

  @override
  State<EditableVnd> createState() => _EditableVndState();
}

class _EditableVndState extends State<EditableVnd> {
  StreamSubscription? _doneSubscription;

  VndEditingController? _managedController;
  VndEditingController get controller =>
      widget.controller ??
      (_managedController ??= VndEditingController(vnd: widget.vnd));

  VndFocusNode? _managedFocusNode;
  VndFocusNode get focusNode =>
      widget.focusNode ?? (_managedFocusNode ??= VndFocusNode());

  Color get autoZerosColor =>
      widget.autoZerosColor ?? Theme.of(context).dividerColor;

  bool get enabled => widget.enabled != false;

  bool get hasFocus => focusNode.hasFocus;

  Color? get textSelectionColor =>
      widget.textSelectionColor ??
      DefaultSelectionStyle.of(context).selectionColor;

  @override
  Widget build(BuildContext context) {
    final showCursor = widget.showCursor ?? enabled;
    final theme = Theme.of(context);
    final style = widget.style ?? theme.textTheme.titleMedium;
    final symbol = widget.symbol ?? _Symbol(style);

    final built = AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (_, __) {
        final textSelectionColor = !hasFocus
            ? null
            : (controller.isSelected ? this.textSelectionColor : null);
        final textValue = Text(_formatValue(), style: style);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _onTap,
              child: textSelectionColor != null
                  ? ColoredBox(
                      color: textSelectionColor,
                      child: textValue,
                    )
                  : textValue,
            ),
            if (showCursor)
              _BlinkingCursor(
                isVisible: hasFocus && !controller.isSelected,
                style: style,
              ),
            Visibility(
              visible: controller.autoZeros &&
                  controller.vnd != controller.value.rawValue,
              child: Dismissible(
                direction: DismissDirection.up,
                key: ValueKey(controller),
                onDismissed: _disableAutoZeros,
                child: Text(
                  ',000',
                  style: style?.copyWith(
                    color: hasFocus ? autoZerosColor : null,
                  ),
                ),
              ),
            ),
            symbol,
          ],
        );
      },
    );

    return Focus(
      focusNode: focusNode.flutter,
      onFocusChange: _onFlutterFocusChange,
      child: built,
    );
  }

  @override
  void didUpdateWidget(EditableVnd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller ||
        widget.vnd != oldWidget.vnd) {
      _doneSubscription?.cancel();

      final outdatedController = _managedController;
      if (outdatedController != null) {
        _managedController = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.unfocus();
          outdatedController.dispose();
        });
      }

      _doneSubscription = controller.onDone(_onDone);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _managedFocusNode?.dispose();
      _managedFocusNode = null;
    }

    if (widget.enabled != oldWidget.enabled) {
      focusNode.flutter?.canRequestFocus = enabled;
      focusNode.flutter?.skipTraversal = !enabled;
    }
  }

  @override
  void dispose() {
    _doneSubscription?.cancel();
    _managedController?.dispose();
    _managedFocusNode?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _doneSubscription = controller.onDone(_onDone);

    if (widget.autofocus == true) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => focusNode.requestFocus());
    }

    focusNode.flutter?.canRequestFocus = enabled;
    focusNode.flutter?.skipTraversal = !enabled;
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

  void _onDone(VndEditingController controller) {
    switch (widget.textInputAction) {
      case TextInputAction.done:
        focusNode.unfocus();
        break;
      case TextInputAction.next:
        FocusScope.of(context).nextFocus();
        break;
      default:
      // do nothing
    }

    widget.onDone?.call(controller.vnd);
  }

  void _onFlutterFocusChange(bool hasFlutterFocus) {
    if (focusNode.hasFocus == hasFlutterFocus) return;

    final provider =
        context.dependOnInheritedWidgetOfExactType<_InheritedWidget>()?.state;
    if (hasFlutterFocus) {
      focusNode._onFocusNodeFocused();
      provider?._setController(controller);
    } else {
      focusNode._onFocusNodeUnfocused();
      provider?._setController(null);
    }
  }

  void _onTap() {
    if (!enabled) return;

    if (!hasFocus) {
      focusNode.requestFocus();
    } else {
      controller.isSelected = !controller.isSelected;
    }
  }
}

class _BlinkingCursor extends StatefulWidget {
  final bool isVisible;
  final TextStyle? style;

  const _BlinkingCursor({required this.isVisible, this.style}) : super();

  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late double height;

  @override
  Widget build(BuildContext context) {
    final color = DefaultSelectionStyle.of(context).cursorColor;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value,
          child: child,
        );
      },
      child: SizedBox(
        height: height,
        width: 2,
        child: color != null ? ColoredBox(color: color) : null,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _BlinkingCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateHeight();
    _repeatOrStop();
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

    _calculateHeight();
    _repeatOrStop();
  }

  void _calculateHeight() {
    final tp = TextPainter(
      text: TextSpan(text: '123456', style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    height = tp.height;
  }

  void _repeatOrStop() {
    if (!widget.isVisible) {
      controller
        ..stop()
        ..value = .0;
    } else if (EditableText.debugDeterministicCursor) {
      controller
        ..stop()
        ..value = 1;
    } else {
      controller.repeat(reverse: true);
    }
  }
}

class _Symbol extends StatelessWidget {
  final TextStyle? style;

  const _Symbol(this.style);

  @override
  Widget build(BuildContext context) {
    final fontSize = style?.fontSize;
    return Text(
      'đ',
      style: style?.copyWith(
        color: Theme.of(context).disabledColor,
        fontSize: fontSize != null ? fontSize * .7 : null,
      ),
    );
  }
}
