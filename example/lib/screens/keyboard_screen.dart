import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class KeyboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext _) => Scaffold(
        appBar: AppBar(title: Text('Keyboard')),
        bottomNavigationBar: Builder(
          builder: (context) => VndKeyboard(
            onTap: (value) => Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('onTap($value)'),
              duration: const Duration(milliseconds: 10),
            )),
          ),
        ),
      );
}
