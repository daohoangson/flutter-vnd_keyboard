import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class BottomSheetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Bottom sheet')),
        body: Column(children: [
          Center(
            child: _Button(
              text: 'showModalBottomSheet',
            ),
          ),
          Center(
            child: _Button(
              text: 'showModalBottomSheet (vnd=10000)',
              vnd: 10000,
            ),
          ),
        ]),
      );
}

class _Button extends StatelessWidget {
  final int vnd;
  final String text;

  const _Button({
    Key key,
    this.text,
    this.vnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => RaisedButton(
        child: Text(text),
        onPressed: () async {
          final newVnd = await showModalBottomSheet(
            builder: (_) => VndBottomSheet(vnd: vnd),
            context: context,
          );
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('vnd=$newVnd'),
            duration: const Duration(milliseconds: 100),
          ));
        },
      );
}
