import 'package:flutter/material.dart';

import 'keyboard_key.dart';

class VndKeyboard extends StatefulWidget {
  final double buttonLabelSize;
  final double height;
  final ValueChanged<KeyboardKey> onTap;

  const VndKeyboard({
    this.buttonLabelSize = 20,
    this.height = 200,
    Key key,
    this.onTap,
  }) : super(key: key);

  @override
  _VndKeyboardState createState() => _VndKeyboardState();
}

class _VndKeyboardState extends State<VndKeyboard> {
  @override
  Widget build(BuildContext context) => Container(
        child: Row(
          children: [
            _buildExpandedColumn(
              [
                _buildExpandedRow(
                  [
                    _buildKey('1'),
                    _Divider.vertical().marginTop,
                    _buildKey('2'),
                    _Divider.vertical().marginTop,
                    _buildKey('3'),
                  ],
                ),
                _Divider.horizontal().marginLeft,
                _buildExpandedRow(
                  [
                    _buildKey('4'),
                    _Divider.vertical(),
                    _buildKey('5'),
                    _Divider.vertical(),
                    _buildKey('6'),
                  ],
                ),
                _Divider.horizontal().marginLeft,
                _buildExpandedRow(
                  [
                    _buildKey('7'),
                    _Divider.vertical(),
                    _buildKey('8'),
                    _Divider.vertical(),
                    _buildKey('9'),
                  ],
                ),
                _Divider.horizontal().marginLeft,
                _buildExpandedRow(
                  [
                    _buildKey('0'),
                    _Divider.vertical().marginBottom,
                    _buildKey('000', flex: 2),
                    _Divider.vertical().invisible,
                  ],
                ),
              ],
              flex: 3,
            ),
            _Divider.vertical().marginTop.marginBottom,
            _buildExpandedColumn(
              [
                Expanded(
                  child: _Key(
                    child: Icon(Icons.backspace),
                    onTap: widget.onTap,
                    value: KeyboardKey.delete(),
                  ),
                ),
                _Divider.horizontal().marginRight,
                Expanded(
                  child: _Key(
                    child: Icon(
                      Icons.done,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    onTap: widget.onTap,
                    value: KeyboardKey.done(),
                  ),
                ),
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: _Divider.color(context),
              width: _Divider.kThickness,
            ),
          ),
        ),
        height: widget.height,
      );

  Widget _buildExpandedColumn(
    List<Widget> children, {
    int flex = 1,
  }) =>
      Expanded(child: Column(children: children), flex: flex);

  Widget _buildExpandedRow(
    List<Widget> children, {
    int flex = 1,
  }) =>
      Expanded(child: Row(children: children), flex: flex);

  Widget _buildKey(
    String value, {
    int flex = 1,
  }) =>
      Expanded(
        child: _Key(
          buttonLabelSize: widget.buttonLabelSize,
          onTap: widget.onTap,
          value: KeyboardKey.numeric(value),
        ),
        flex: flex,
      );
}

class _Divider extends StatelessWidget {
  static Color color(BuildContext context) => Theme.of(context).dividerColor;
  static const kPadding = 4.0;
  static const kThickness = 1.0;

  final double height;
  final EdgeInsetsGeometry margin;
  final double width;

  const _Divider({Key key, this.height, this.margin, this.width})
      : super(key: key);

  factory _Divider.horizontal() => _Divider(height: kThickness);

  factory _Divider.vertical() => _Divider(width: kThickness);

  _Divider get marginBottom =>
      copyWith(margin: const EdgeInsets.only(bottom: _Divider.kPadding));

  _Divider get marginLeft =>
      copyWith(margin: const EdgeInsets.only(left: _Divider.kPadding));

  _Divider get marginRight =>
      copyWith(margin: const EdgeInsets.only(right: _Divider.kPadding));

  _Divider get marginTop =>
      copyWith(margin: const EdgeInsets.only(top: _Divider.kPadding));

  @override
  Widget build(BuildContext context) => Container(
        color: color(context),
        height: height,
        margin: margin,
        width: width,
      );

  _Divider copyWith({EdgeInsetsGeometry margin}) => _Divider(
        height: height,
        margin:
            margin != null ? (this.margin?.add(margin) ?? margin) : this.margin,
        width: width,
      );
}

extension _Invisible on Widget {
  Widget get invisible => Opacity(child: this, opacity: 0);
}

class _Key extends StatelessWidget {
  final Color backgroundColor;
  final double buttonLabelSize;
  final Widget child;
  final ValueChanged<KeyboardKey> onTap;
  final KeyboardKey value;

  const _Key({
    this.backgroundColor,
    this.child,
    this.buttonLabelSize,
    Key key,
    this.onTap,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget built = InkWell(
      child: Center(
        child: child != null
            ? child
            : Text(
                value.toString(),
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(fontSize: buttonLabelSize),
              ),
      ),
      onTap: () => onTap?.call(value),
    );

    if (backgroundColor != null) {
      built = DecoratedBox(
        child: Material(
          child: built,
          type: MaterialType.transparency,
        ),
        decoration: BoxDecoration(color: backgroundColor),
      );
    }

    return built;
  }
}
