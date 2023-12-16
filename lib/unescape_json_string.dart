String unescapeJsonString(String input) {
  var unescaped = input
      .replaceAll(r'\"', '"') // Unescape double quotes
      .replaceAll(r'\\', r'\') // Unescape backslashes
      .replaceAll(r'\n', '\n') // Unescape newlines
      .replaceAll(r'\t', '\t') // Unescape tabs
      .replaceAll(r'\b', '\b') // Unescape backspaces
      .replaceAll(r'\f', '\f') // Unescape form feeds
      .replaceAll(r'\r', '\r'); // Unescape carriage returns

  // Handle unicode character escapes
  RegExp unicodeEscape = RegExp(r'\\u[0-9a-fA-F]{4}');
  unescaped = unescaped.replaceAllMapped(unicodeEscape, (match) {
    var hexCode = match[0]!.substring(2);
    var charCode = int.parse(hexCode, radix: 16);
    return String.fromCharCode(charCode);
  });

  return unescaped;
}
