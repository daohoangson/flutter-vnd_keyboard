class KeyboardKey {
  final KeyboardKeyType type;
  final String value;

  const KeyboardKey._(this.type, [this.value]);

  static const delete = KeyboardKey._(KeyboardKeyType.delete);

  static const done = KeyboardKey._(KeyboardKeyType.done);

  const KeyboardKey.numeric(int value)
      : type = KeyboardKeyType.value,
        value = '$value';

  static const zeros = KeyboardKey._(KeyboardKeyType.value, '000');

  @override
  String toString() => type == KeyboardKeyType.value ? value : type.toString();
}

enum KeyboardKeyType {
  delete,
  done,
  value,
}
