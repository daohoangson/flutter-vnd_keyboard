import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class KeyboardProviderScreen extends StatefulWidget {
  const KeyboardProviderScreen({super.key});

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
        appBar: AppBar(
          title: const Text('Keyboard Provider'),
        ),
        body: VndKeyboardProvider(
          child: FocusScope(
            child: ListView(
              children: [
                const _TextListTile('Title'),
                _VndListTile(
                  controller: price,
                  focusNode: priceFn,
                  textInputAction: TextInputAction.next,
                  title: 'Price',
                ),
                const _TextListTile('Note'),
                _VndListTile(
                  controller: shipping,
                  focusNode: shippingFn,
                  textInputAction: TextInputAction.done,
                  title: 'Shipping',
                ),
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
  final TextInputAction textInputAction;
  final String title;

  const _VndListTile({
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.title,
  }) : super();

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
              textInputAction: widget.textInputAction,
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

  const _TextListTile(this.title) : super();

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

  const _TotalListTile({required this.price, required this.shipping}) : super();

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: ListTile(
          title: Row(
            children: [
              const Expanded(
                child: Text('Total'),
              ),
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
