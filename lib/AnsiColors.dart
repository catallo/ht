// ANSI color codes and text effects

const String acBlack = '\x1B[30m';
const String acRed = '\x1B[31m';
const String acGreen = '\x1B[32m';
const String acYellow = '\x1B[33m';
const String acBlue = '\x1B[34m';
const String acMagenta = '\x1B[35m';
const String acCyan = '\x1B[36m';
const String acWhite = '\x1B[37m';
const String acGrey = '\x1B[90m';

const String acBrightBlack = '\x1B[90m';
const String acBrightRed = '\x1B[91m';
const String acBrightGreen = '\x1B[92m';
const String acBrightYellow = '\x1B[93m';
const String acBrightBlue = '\x1B[94m';
const String acBrightMagenta = '\x1B[95m';
const String acBrightCyan = '\x1B[96m';
const String acBrightWhite = '\x1B[97m';
const String acBrightGrey = '\x1B[37m';

// Background color codes
const String acBgBlack = '\x1B[40m';
const String acBgRed = '\x1B[41m';
const String acBgGreen = '\x1B[42m';
const String acBgYellow = '\x1B[43m';
const String acBgBlue = '\x1B[44m';
const String acBgMagenta = '\x1B[45m';
const String acBgCyan = '\x1B[46m';
const String acBgWhite = '\x1B[47m';
const String acBgGrey = '\x1B[100m';

const String acBgBrightBlack = '\x1B[100m';
const String acBgBrightRed = '\x1B[101m';
const String acBgBrightGreen = '\x1B[102m';
const String acBgBrightYellow = '\x1B[103m';
const String acBgBrightBlue = '\x1B[104m';
const String acBgBrightMagenta = '\x1B[105m';
const String acBgBrightCyan = '\x1B[106m';
const String acBgBrightWhite = '\x1B[107m';
const String bgBrightGrey = '\x1B[47m';

// Text effects
const String acBold = '\x1B[1m';
const String acItalic = '\x1B[3m';
const String acUnderline = '\x1B[4m';
const String acBlink = '\x1B[5m';
const String acReverse = '\x1B[7m';

const String acReset = '\x1B[0m';

void main() {
  // Example usage:
  print(
      "$acRed${acBold}This ${acReset}is $acGreen$acItalic$acUnderline$acBgBlue${acBlink}blinking$acReset and $acBgYellow reverse$acBgBrightMagenta text$acReset.");
}
