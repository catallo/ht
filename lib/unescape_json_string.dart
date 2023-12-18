String unescapeJsonString(String input) {
  var unescaped = input
      .replaceAll(r'\"', '"')
      .replaceAll(r'\\', r'\')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\t', '\t')
      .replaceAll(r'\b', '\b')
      .replaceAll(r'\f', '\f')
      .replaceAll(r'\r', '\r');

  // Handle unicode character escapes
  RegExp unicodeEscape = RegExp(r'\\u[0-9a-fA-F]{4}');
  unescaped = unescaped.replaceAllMapped(unicodeEscape, (match) {
    var hexCode = match[0]!.substring(2);
    var charCode = int.parse(hexCode, radix: 16);
    return String.fromCharCode(charCode);
  });

  return unescaped;
}
