class KeyboardKey {
  final KeyboardKeyType type;
  final String value;

  KeyboardKey.delete()
      : type = KeyboardKeyType.delete,
        value = null;

  KeyboardKey.done()
      : type = KeyboardKeyType.done,
        value = null;

  KeyboardKey.numeric(this.value) : type = KeyboardKeyType.numeric;

  @override
  String toString() =>
      type == KeyboardKeyType.numeric ? value : type.toString();
}

enum KeyboardKeyType {
  delete,
  done,
  numeric,
}
