class PasswordHasher {
  static String hash(String input) {
    var hash = 0x811c9dc5;
    const prime = 0x01000193;

    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * prime) & 0xffffffff;
    }

    return hash.toRadixString(16);
  }
}
