import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A controller for an editable VND widget.
class VndEditingController extends ValueNotifier<VndEditingValue> {
  /// Creates a controller for an editable VND widget.
  VndEditingController({int vnd})
      : super(vnd == null
            ? VndEditingValue.zero
            : VndEditingValue(autoZeros: false, rawValue: vnd));

  /// Creates a controller for an editable VND widget
  /// from an initial [VndEditingValue].
  VndEditingController.fromValue(VndEditingValue value) : super(value);

  /// Returns `true` if auto zeros is enabled.
  bool get autoZeros => value.autoZeros;

  /// Controls whether auto zeros should be added.
  set autoZeros(bool v) => value = value.copyWith(autoZeros: v);

  /// Returns `true` if input is being selected.
  bool get isSelected => value.isSelected;

  /// Selects or unselects input.
  set isSelected(bool v) => value = value.copyWith(isSelected: v);

  /// Returns the current VND value.
  int get vnd => value.vnd;

  /// Appends new characters at the end of the current value.
  void append(String str) {
    if (isSelected) {
      value = value.copyWith(rawValue: int.tryParse(str) ?? 0);
      return;
    }

    final rawValue = int.tryParse('${value.rawValue}$str') ?? 0;
    value = value.copyWith(rawValue: rawValue);
  }

  /// Deletes one character from the current value.
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

/// The current state while editing a VND value.
class VndEditingValue {
  /// Whether auto zeros should be added.
  final bool autoZeros;

  /// Whether input is being selected.
  final bool isSelected;

  /// The raw value;
  final int rawValue;

  /// Creates an editing state.
  const VndEditingValue({
    this.autoZeros = true,
    this.isSelected = false,
    this.rawValue = 0,
  });

  /// Returns the VND value, with auto zeros if enabled.
  int get vnd {
    if (!autoZeros) return rawValue;
    if (rawValue > 999) return rawValue;
    return rawValue * 1000;
  }

  /// Creates a copy with the given fields replaced with the new values.
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

  @override
  int get hashCode => rawValue;

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is VndEditingValue) {
      return autoZeros == other.autoZeros &&
          isSelected == other.isSelected &&
          rawValue == other.rawValue;
    } else {
      return false;
    }
  }

  /// A convenient zero initial state.
  static const VndEditingValue zero = VndEditingValue();
}
