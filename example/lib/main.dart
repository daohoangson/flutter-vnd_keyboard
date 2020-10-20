import 'package:flutter/material.dart';
import 'package:vnd_keyboard/screens/bottom_sheet_screen.dart';
import 'package:vnd_keyboard/screens/keyboard_provider_screen.dart';
import 'package:vnd_keyboard/screens/keyboard_screen.dart';

void main() => runApp(DemoApp());

final _routes = Map<String, Widget Function(BuildContext)>.unmodifiable({
  '/keyboard': (_) => KeyboardScreen(),
  '/bottom-sheet': (_) => BottomSheetScreen(),
  '/keyboard-provider': (_) => KeyboardProviderScreen(),
});

final _routeNames = _routes.keys.toList(growable: false);

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VND Keyboard Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: _Home(),
      routes: _routes,
    );
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('VND Keyboard Demo')),
        body: ListView.builder(
          itemBuilder: _itemBuilder,
          itemCount: _routeNames.length,
        ),
      );

  Widget _itemBuilder(BuildContext context, int index) {
    final routeName = _routeNames[index];
    final title = routeName.replaceAll(RegExp(r'[^a-z]'), ' ');

    return ListTile(
      onTap: () => Navigator.of(context).pushNamed(routeName),
      title: Text(title),
    );
  }
}
