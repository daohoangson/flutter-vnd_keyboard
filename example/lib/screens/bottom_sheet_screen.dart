import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class BottomSheetScreen extends StatelessWidget {
  const BottomSheetScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Bottom sheet'),
        ),
        body: Column(
          children: const [
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
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  final int? vnd;
  final String text;

  const _Button({required this.text, this.vnd}) : super();

  @override
  Widget build(BuildContext context) => ElevatedButton(
        child: Text(text),
        onPressed: () async {
          final newVnd = await showModalBottomSheet(
            builder: (_) => VndBottomSheet(vnd: vnd),
            context: context,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('vnd=$newVnd'),
                duration: const Duration(milliseconds: 100),
              ),
            );
          }
        },
      );
}
