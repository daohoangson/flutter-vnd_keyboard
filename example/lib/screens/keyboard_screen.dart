import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class KeyboardScreen extends StatelessWidget {
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Keyboard'),
        ),
        bottomNavigationBar: Builder(
          builder: (context) => VndKeyboard(
            onTap: (value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('onTap($value)'),
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );
}
