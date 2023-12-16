import 'globals.dart';
import 'ansi_codes.dart';

void dbg(String text) {
  if (!debug) return;
  print("$acBlue dbg:$acReset $acYellow$text$acReset");
}
