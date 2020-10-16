import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class KeyboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Keyboard')),
        body: Column(
          children: [
            Expanded(child: Container()),
            VndKeyboard(
              onTap: (value) => print('onTap($value)'),
            ),
          ],
        ),
      );
}
