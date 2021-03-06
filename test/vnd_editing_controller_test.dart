import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

void main() {
  group('autoZeros', () {
    test('returns true', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(autoZeros: true));
      expect(controller.autoZeros, isTrue);
    });

    test('returns false', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(autoZeros: false));
      expect(controller.autoZeros, isFalse);
    });

    test('sets true', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(autoZeros: false));
      controller.autoZeros = true;
      expect(controller.autoZeros, isTrue);
    });

    test('sets false', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(autoZeros: true));
      controller.autoZeros = false;
      expect(controller.autoZeros, isFalse);
    });

    test('skips changing value (already true)', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(autoZeros: true));
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.autoZeros = true;
      expect(triggered, equals(0));
    });

    test('skips changing value (already false)', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(autoZeros: false));
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.autoZeros = false;
      expect(triggered, equals(0));
    });
  });

  group('isSelected', () {
    test('returns true', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(isSelected: true));
      expect(controller.isSelected, isTrue);
    });

    test('returns false', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(isSelected: false));
      expect(controller.isSelected, isFalse);
    });

    test('sets true', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(isSelected: false));
      controller.isSelected = true;
      expect(controller.isSelected, isTrue);
    });

    test('sets false', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(isSelected: true));
      controller.isSelected = false;
      expect(controller.isSelected, isFalse);
    });

    test('skips changing value (already true)', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(isSelected: true));
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.isSelected = true;
      expect(triggered, equals(0));
    });

    test('skips changing value (already false)', () {
      final controller =
          VndEditingController.fromValue(VndEditingValue(isSelected: false));
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.isSelected = false;
      expect(triggered, equals(0));
    });
  });

  group('append', () {
    test('appends', () {
      final controller = VndEditingController(vnd: 123);
      controller.append('456');
      expect(controller.vnd, equals(123456));
    });

    test('replaces', () {
      final controller = VndEditingController(vnd: 123);
      controller.isSelected = true;
      controller.append('456');
      expect(controller.isSelected, isFalse);
      expect(controller.vnd, equals(456));
    });

    test('skips changing value (already empty)', () {
      final controller = VndEditingController();
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.delete();
      expect(triggered, equals(0));
    });
  });

  group('delete', () {
    test('deletes last', () {
      final controller = VndEditingController(vnd: 123);
      controller.delete();
      expect(controller.vnd, equals(12));
    });

    test('clears all', () {
      final controller = VndEditingController(vnd: 123);
      controller.isSelected = true;
      controller.delete();
      expect(controller.vnd, equals(0));
    });
  });

  group('vnd', () {
    group('autoZeros=false', () {
      test('rawValue=1', () {
        final value = VndEditingValue(autoZeros: false, rawValue: 1);
        expect(value.vnd, equals(1));
      });
      test('rawValue=1000', () {
        final value = VndEditingValue(autoZeros: false, rawValue: 1000);
        expect(value.vnd, equals(1000));
      });
    });

    group('autoZeros=true', () {
      test('rawValue=1', () {
        final value = VndEditingValue(autoZeros: true, rawValue: 1);
        expect(value.vnd, equals(1000));
      });
      test('rawValue=1000', () {
        final value = VndEditingValue(autoZeros: true, rawValue: 1000);
        expect(value.vnd, equals(1000));
      });
    });
  });
}
