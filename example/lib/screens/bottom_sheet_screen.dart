import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class BottomSheetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Bottom sheet')),
        body: Center(
          child: _Button(),
        ),
      );
}

class _Button extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RaisedButton(
        child: Text('showBottomSheet'),
        onPressed: () async {
          final vnd = await showModalBottomSheet(
            builder: (_) => VndBottomSheet(),
            context: context,
          );
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('vnd=$vnd'),
          ));
        },
      );
}
