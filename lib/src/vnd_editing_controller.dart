import 'package:flutter/foundation.dart';

class VndEditingController extends ValueNotifier<VndEditingValue> {
  VndEditingController({int vnd})
      : super(vnd == null
            ? VndEditingValue.zero
            : VndEditingValue(autoZeros: false, rawValue: vnd));

  VndEditingController.fromValue(VndEditingValue value) : super(value);

  bool get autoZeros => value.autoZeros;
  set autoZeros(bool v) {
    if (v == value.autoZeros) return;
    value = value.copyWith(autoZeros: v);
  }

  bool get isSelected => value.isSelected;
  set isSelected(bool v) {
    if (v == value.isSelected) return;
    value = value.copyWith(isSelected: v);
  }

  int get vnd => value.vnd;

  void append(String str) {
    if (isSelected) {
      value = value.copyWith(rawValue: int.tryParse(str) ?? 0);
      return;
    }

    final rawValue = int.tryParse('${value.rawValue}$str') ?? 0;
    value = value.copyWith(rawValue: rawValue);
  }

  void delete() {
    if (isSelected) {
      value = value.copyWith(rawValue: 0);
      return;
    }

    final current = '${value.rawValue}';
    if (current.isNotEmpty) {
      final deleted = current.substring(0, current.length - 1);
      value = value.copyWith(rawValue: int.tryParse(deleted) ?? 0);
    }
  }
}

class VndEditingValue {
  final bool autoZeros;
  final bool isSelected;
  final int rawValue;

  const VndEditingValue({
    this.autoZeros = true,
    this.isSelected = false,
    this.rawValue = 0,
  });

  int get vnd {
    if (!autoZeros) return rawValue;
    if (rawValue > 999) return rawValue;
    return rawValue * 1000;
  }

  VndEditingValue copyWith({
    bool autoZeros,
    bool isSelected,
    int rawValue,
  }) =>
      VndEditingValue(
        autoZeros: autoZeros ?? this.autoZeros,
        isSelected: isSelected ?? this.isSelected,
        rawValue: rawValue ?? this.rawValue,
      );

  static const VndEditingValue zero = VndEditingValue();
}
