import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class KeyboardProviderScreen extends StatefulWidget {
  @override
  State<KeyboardProviderScreen> createState() => _KeyboardProviderState();
}

class _KeyboardProviderState extends State<KeyboardProviderScreen> {
  final price = VndEditingController();
  final priceFn = VndFocusNode();

  final shipping = VndEditingController();
  final shippingFn = VndFocusNode();

  @override
  Widget build(BuildContext _) => Scaffold(
        appBar: AppBar(title: Text('Keyboard Provider')),
        body: VndKeyboardProvider(
          child: FocusScope(
            child: ListView(
              children: [
                _TextListTile('Title'),
                _VndListTile('Price', price, priceFn),
                _TextListTile('Note'),
                _VndListTile('Shipping', shipping, shippingFn),
                _TotalListTile(price: price, shipping: shipping),
              ],
            ),
          ),
        ),
      );

  @override
  void dispose() {
    price.dispose();
    priceFn.dispose();

    shipping.dispose();
    shippingFn.dispose();

    super.dispose();
  }
}

class _VndListTile extends StatefulWidget {
  final VndEditingController controller;
  final VndFocusNode focusNode;
  final String title;

  const _VndListTile(
    this.title,
    this.controller,
    this.focusNode, {
    Key key,
  }) : super(key: key);

  @override
  State<_VndListTile> createState() => _VndListTileState();
}

class _VndListTileState extends State<_VndListTile> {
  final listFn = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  Widget build(BuildContext _) => ListTile(
        focusNode: listFn,
        onTap: () => widget.focusNode.requestFocus(),
        title: Row(
          children: [
            Expanded(child: Text(widget.title)),
            EditableVnd(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      );

  @override
  void dispose() {
    listFn.dispose();
    super.dispose();
  }
}

class _TextListTile extends StatelessWidget {
  final String title;

  const _TextListTile(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext _) => ListTile(
        title: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: title,
          ),
          textInputAction: TextInputAction.next,
        ),
      );
}

class _TotalListTile extends StatelessWidget {
  final VndEditingController price;
  final VndEditingController shipping;

  const _TotalListTile({Key key, this.price, this.shipping}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: ListTile(
          title: Row(
            children: [
              Expanded(child: Text('Total')),
              AnimatedBuilder(
                animation: Listenable.merge([price, shipping]),
                builder: (_, __) => EditableVnd(
                  enabled: false,
                  vnd: price.vnd + shipping.vnd,
                ),
              ),
            ],
          ),
        ),
      );
}
