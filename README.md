# flutter_vnd_keyboard

![github/workflows](https://github.com/daohoangson/flutter-vnd_keyboard/workflows/Flutter/badge.svg)
[![codecov](https://codecov.io/gh/daohoangson/flutter-vnd_keyboard/branch/master/graph/badge.svg?token=UCX3ZZ60IU)](https://codecov.io/gh/daohoangson/flutter-vnd_keyboard)

Vietnamese đồng keyboard for Flutter.

## Getting Started

Add this to your app's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_vnd_keyboard: ^0.0.1
```

## Usage

Then you have to import the package with:

```dart
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
```

And use `VndKeyboard` or `VndBottomSheet` where appropriate.

```dart
      RaisedButton(
        child: Text('showBottomSheet'),
        onPressed: () async {
          final vnd = await showModalBottomSheet(
            builder: (_) => VndBottomSheet(),
            context: context,
          );
          print('vnd=$vnd');
        },
      );
}
```

| Light theme | Dark theme |
| ----------- | ---------- |
| VndKeyboard | |
| ![](./test/goldens/vnd_keyboard.phone_light.png) | ![](./test/goldens/vnd_keyboard.phone_dark.png) |
| VndBottomSheet | |
| ![](./test/goldens/vnd_bottom_sheet.phone_light.png) | ![](./test/goldens/vnd_bottom_sheet.phone_dark.png) |
