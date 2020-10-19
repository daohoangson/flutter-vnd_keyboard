/// A keyboard key.
class KeyboardKey {
  /// The key type.
  final KeyboardKeyType type;

  /// The value (only applicable with type=[KeyboardKeyType.value]).
  final String value;

  const KeyboardKey._(this.type, [this.value]);

  /// The Delete key.
  static const delete = KeyboardKey._(KeyboardKeyType.delete);

  /// The Done key.
  static const done = KeyboardKey._(KeyboardKeyType.done);

  /// Creates a numeric key.
  const KeyboardKey.numeric(int value)
      : type = KeyboardKeyType.value,
        value = '$value';

  /// The 000 key.
  static const zeros = KeyboardKey._(KeyboardKeyType.value, '000');

  @override
  String toString() => type == KeyboardKeyType.value ? value : type.toString();
}

/// Keyboard key type.
enum KeyboardKeyType {
  /// Delete key type.
  delete,

  /// Done key type.
  done,

  /// Value key type.
  value,
}
