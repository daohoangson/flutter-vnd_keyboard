import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

void main() {
  group('autoZeros', () {
    test('returns true', () {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values, use_named_constants
        const VndEditingValue(autoZeros: true),
      );
      expect(controller.autoZeros, isTrue);
    });

    test('returns false', () {
      final controller = VndEditingController.fromValue(
        const VndEditingValue(autoZeros: false),
      );
      expect(controller.autoZeros, isFalse);
    });

    test('sets true', () {
      final controller = VndEditingController.fromValue(
        const VndEditingValue(autoZeros: false),
      );
      controller.autoZeros = true;
      expect(controller.autoZeros, isTrue);
    });

    test('sets false', () {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values, use_named_constants
        const VndEditingValue(autoZeros: true),
      );
      controller.autoZeros = false;
      expect(controller.autoZeros, isFalse);
    });

    test('skips changing value (already true)', () {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values, use_named_constants
        const VndEditingValue(autoZeros: true),
      );
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.autoZeros = true;
      expect(triggered, equals(0));
    });

    test('skips changing value (already false)', () {
      final controller = VndEditingController.fromValue(
        const VndEditingValue(autoZeros: false),
      );
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.autoZeros = false;
      expect(triggered, equals(0));
    });
  });

  group('isSelected', () {
    test('returns true', () {
      final controller = VndEditingController.fromValue(
        const VndEditingValue(isSelected: true),
      );
      expect(controller.isSelected, isTrue);
    });

    test('returns false', () {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values, use_named_constants
        const VndEditingValue(isSelected: false),
      );
      expect(controller.isSelected, isFalse);
    });

    test('sets true', () {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values, use_named_constants
        const VndEditingValue(isSelected: false),
      );
      controller.isSelected = true;
      expect(controller.isSelected, isTrue);
    });

    test('sets false', () {
      final controller = VndEditingController.fromValue(
        const VndEditingValue(isSelected: true),
      );
      controller.isSelected = false;
      expect(controller.isSelected, isFalse);
    });

    test('skips changing value (already true)', () {
      final controller = VndEditingController.fromValue(
        const VndEditingValue(isSelected: true),
      );
      var triggered = 0;
      controller.addListener(() => triggered++);
      controller.isSelected = true;
      expect(triggered, equals(0));
    });

    test('skips changing value (already false)', () {
      final controller = VndEditingController.fromValue(
        // ignore: avoid_redundant_argument_values, use_named_constants
        const VndEditingValue(isSelected: false),
      );
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

    test('skips appending on max int', () {
      final controller = VndEditingController(vnd: 9223372036854775807);
      controller.append('0');
      expect(controller.vnd, equals(9223372036854775807));
    });

    test('skips replacing on int overflow', () {
      final controller = VndEditingController(vnd: 123);
      controller.isSelected = true;
      controller.append('9223372036854775808');
      expect(controller.isSelected, isFalse);
      expect(controller.vnd, equals(0));
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

  group('done', () {
    test('marks as done', () async {
      final controller = VndEditingController();
      var done = 0;
      controller.onDone((_) => done++);

      expect(done, equals(0));
      controller.done();

      await Future.delayed(Duration.zero);
      expect(done, equals(1));
    });
  });

  group('vnd', () {
    group('autoZeros=false', () {
      test('rawValue=1', () {
        const value = VndEditingValue(autoZeros: false, rawValue: 1);
        expect(value.vnd, equals(1));
      });
      test('rawValue=1000', () {
        const value = VndEditingValue(autoZeros: false, rawValue: 1000);
        expect(value.vnd, equals(1000));
      });
    });

    group('autoZeros=true', () {
      test('rawValue=1', () {
        // ignore: avoid_redundant_argument_values
        const value = VndEditingValue(autoZeros: true, rawValue: 1);
        expect(value.vnd, equals(1000));
      });
      test('rawValue=1000', () {
        // ignore: avoid_redundant_argument_values
        const value = VndEditingValue(autoZeros: true, rawValue: 1000);
        expect(value.vnd, equals(1000));
      });
    });
  });
}
