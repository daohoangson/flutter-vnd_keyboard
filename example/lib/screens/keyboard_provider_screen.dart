import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class KeyboardProviderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext _) => Scaffold(
        appBar: AppBar(title: Text('Keyboard Provider')),
        body: VndKeyboardProvider(
          child: ListView(
            children: [
              ListTile(title: TextField()),
              ListTile(title: EditableVnd()),
              ListTile(title: TextField()),
              ListTile(title: EditableVnd(vnd: 0)),
            ],
          ),
        ),
      );
}
