import 'package:flutter/material.dart';

import 'keyboard_key.dart';

/// A Vietnamese đồng keyboard.
class VndKeyboard extends StatefulWidget {
  /// The entire keyboard height.
  ///
  /// Default: `200`.
  final double height;

  /// The font size of key labels.
  ///
  /// Default: `20`.
  final double labelSize;

  /// Called when the user taps a key.
  final ValueChanged<KeyboardKey>? onTap;

  /// Semantic label for the Delete key.
  ///
  /// Default: ASCII 127 (delete)
  final String? semanticLabelDelete;

  /// Semantic label for the Done key.
  ///
  /// Default: `'OK'`.
  final String? semanticLabelDone;

  /// Creates a VND keyboard.
  const VndKeyboard({
    this.height = 200,
    super.key,
    this.labelSize = 20,
    this.onTap,
    this.semanticLabelDelete,
    this.semanticLabelDone,
  }) : super();

  @override
  _VndKeyboardState createState() => _VndKeyboardState();
}

class _VndKeyboardState extends State<VndKeyboard> {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: _Divider.color(context),
              width: _Divider.kThickness,
            ),
          ),
        ),
        height: widget.height,
        child: Row(
          children: [
            _buildExpandedColumn(
              [
                _buildExpandedRow(
                  [
                    _buildKey(const KeyboardKey.numeric(1)),
                    _Divider.vertical().marginTop,
                    _buildKey(const KeyboardKey.numeric(2)),
                    _Divider.vertical().marginTop,
                    _buildKey(const KeyboardKey.numeric(3)),
                  ],
                ),
                _Divider.horizontal().marginLeft,
                _buildExpandedRow(
                  [
                    _buildKey(const KeyboardKey.numeric(4)),
                    _Divider.vertical(),
                    _buildKey(const KeyboardKey.numeric(5)),
                    _Divider.vertical(),
                    _buildKey(const KeyboardKey.numeric(6)),
                  ],
                ),
                _Divider.horizontal().marginLeft,
                _buildExpandedRow(
                  [
                    _buildKey(const KeyboardKey.numeric(7)),
                    _Divider.vertical(),
                    _buildKey(const KeyboardKey.numeric(8)),
                    _Divider.vertical(),
                    _buildKey(const KeyboardKey.numeric(9)),
                  ],
                ),
                _Divider.horizontal().marginLeft,
                _buildExpandedRow(
                  [
                    _buildKey(const KeyboardKey.numeric(0)),
                    _Divider.vertical().marginBottom,
                    _buildKey(KeyboardKey.zeros, flex: 2),
                    _Divider.vertical().invisible,
                  ],
                ),
              ],
              flex: 3,
            ),
            _Divider.vertical().marginTop,
            _buildExpandedColumn(
              [
                _buildKey(
                  KeyboardKey.delete,
                  child: Icon(
                    Icons.backspace,
                    // https://www.fileformat.info/info/unicode/char/007f/index.htm
                    semanticLabel:
                        widget.semanticLabelDelete ?? String.fromCharCode(127),
                  ),
                ),
                _buildKey(
                  KeyboardKey.done,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.done,
                    color: Theme.of(context).colorScheme.onPrimary,
                    semanticLabel: widget.semanticLabelDone ?? 'OK',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildExpandedColumn(
    List<Widget> children, {
    int flex = 1,
  }) =>
      Expanded(flex: flex, child: Column(children: children));

  Widget _buildExpandedRow(
    List<Widget> children, {
    int flex = 1,
  }) =>
      Expanded(flex: flex, child: Row(children: children));

  Widget _buildKey(
    KeyboardKey key, {
    Color? backgroundColor,
    Widget? child,
    int flex = 1,
  }) =>
      Expanded(
        flex: flex,
        child: _Key(
          backgroundColor: backgroundColor,
          labelSize: widget.labelSize,
          onTap: widget.onTap,
          value: key,
          child: child,
        ),
      );
}

class _Divider extends StatelessWidget {
  static Color color(BuildContext context) => Theme.of(context).dividerColor;
  static const kPadding = 4.0;
  static const kThickness = 1.0;

  final double? height;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const _Divider({this.height, this.margin, this.width}) : super();

  factory _Divider.horizontal() => _Divider(height: kThickness);

  factory _Divider.vertical() => _Divider(width: kThickness);

  _Divider get marginBottom =>
      copyWith(margin: const EdgeInsets.only(bottom: _Divider.kPadding));

  _Divider get marginLeft =>
      copyWith(margin: const EdgeInsets.only(left: _Divider.kPadding));

  _Divider get marginTop =>
      copyWith(margin: const EdgeInsets.only(top: _Divider.kPadding));

  @override
  Widget build(BuildContext context) => Container(
        color: color(context),
        height: height,
        margin: margin,
        width: width,
      );

  _Divider copyWith({EdgeInsetsGeometry? margin}) => _Divider(
        height: height,
        margin:
            margin != null ? (this.margin?.add(margin) ?? margin) : this.margin,
        width: width,
      );
}

extension _Invisible on Widget {
  Widget get invisible => Opacity(opacity: 0, child: this);
}

class _Key extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? child;
  final double labelSize;
  final ValueChanged<KeyboardKey>? onTap;
  final KeyboardKey value;

  const _Key({
    this.backgroundColor,
    this.child,
    required this.labelSize,
    this.onTap,
    required this.value,
  }) : super();

  @override
  Widget build(BuildContext context) {
    Widget built = InkWell(
      child: Center(
        child: child ??
            Text(
              value.toString(),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: labelSize),
            ),
      ),
      onTap: () => onTap?.call(value),
    );

    if (backgroundColor != null) {
      built = DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Material(
          type: MaterialType.transparency,
          child: built,
        ),
      );
    }

    return built;
  }
}
