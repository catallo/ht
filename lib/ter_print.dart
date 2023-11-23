import 'dart:io';
import 'package:ht/ansi_codes.dart';

var terminalWidth = 80;

// decides which function to use ───────────────────────────────────────────────
void terPrint(String line) {
  // remove all newlines from line
  line = line.replaceAll("\n", "");

  //print("terPrint line: $line");

  if (line.contains("#DSCR:")) {
    terPrintCommandAndDescription(line);
  } else if (line.contains("#ERR:") || line.contains("#WRN:")) {
    terPrintErrorsAndWarnings(line);
  } else if (line.contains("#COR:")) {
    terPrintCorrectedVersion(line);
  } else if (line.contains("#SS:")) {
    terPrintSummary(line);
  } else {
    if (line.trim().isEmpty) {
      return;
    }
    terPrintLine(line);
  }
  return;
}

// returns a list of lines that fit into terminal width ────────────────────────
List<String> fitIntoTerminalWidth(line, {int indentation = 0}) {
  if (stdout.hasTerminal) terminalWidth = stdout.terminalColumns;

  String spaces = " " * indentation;

  var lines = <String>[];
  lines.add(spaces + line);

  for (var i = 0; i < lines.length; i++) {
    if ((lines[i].length) > terminalWidth) {
      int lastSpace = 0;
      lastSpace = lines[i].substring(0, terminalWidth).lastIndexOf(" ");
      //print(
      //    "TerminalWidth: $terminalWidth, lastSpace: $lastSpace, lineLength: ${lines[i].length}");
      var line1 = lines[i].substring(0, lastSpace);
      var line2 = lines[i].substring(lastSpace + 1);
      line2 = line2;
      lines[i] = line1;
      lines.insert(i + 1, spaces + line2);
    }
  }
  // check if there are empty lines and remove them
  for (var i = 0; i < lines.length; i++) {
    lines[i] = lines[i].trimRight();
    if (lines[i].isEmpty) {
      lines.removeAt(i);
    }
  }
  return lines;
}

// ─────────────────────────────────────────────────────────────────────────────
void terPrintErrorsAndWarnings(String line) {
  //print("$acYellow line: $line $acReset");
  if (stdout.hasTerminal) terminalWidth = stdout.terminalColumns;
  String emoji = "";

  if (line.contains("#ERR:")) {
    if (line.contains("none")) return;
    emoji = "❌";
  } else if (line.contains("#WRN:")) {
    emoji = "$acBrightYellow⚠️ $acReset";
  }
  line = line.replaceAll("#ERR:", "");
  line = line.replaceAll("#WRN:", "");

  List<String> lines = fitIntoTerminalWidth(line, indentation: 3);

  for (var i = 0; i < lines.length; i++) {
    if (i == 0) {
      lines[i] = lines[i].replaceAll(RegExp(r"^\s+"), "$emoji $acBold");
    }
    lines[i] = lines[i].trimRight();
    print(lines[i]);
  }
  print(acReset);
  return;
}

// ─────────────────────────────────────────────────────────────────────────────
void terPrintCorrectedVersion(line) {
  line = line.replaceAll("#COR:", "");

  line =
      "$acBrightGreen✓ $acReset Corrected version:$acBrightWhite$line$acReset\n";
  stdout.write(line);
  print("");
}

// ─────────────────────────────────────────────────────────────────────────────
void terPrintCommandAndDescription(String line) {
  //print(line);
  var parts = line.split("#DSCR:");
  var command = parts[0].trim();

  if (stdout.hasTerminal) terminalWidth = stdout.terminalColumns;
  //print(
  //    "terminalWidth: $terminalWidth, command: $command, commandLength: ${command.length}, description: $description");

  int fixedCommandWidth = 27;

  var lines = <String>[];

  // if command is longer than 27 chars, write description to additional line
  if (command.length > fixedCommandWidth) {
    var parts = line.split("#DSCR:");
    lines.insert(0, parts[0].trim());
    // insert parts[1] as new line in Lines
    lines.insert(1, "#DSCR:${parts[1].trim()}");
  } else {
    lines.insert(0, line.trim());
  }

  for (var i = 0; i < lines.length; i++) {
    lines[i] = lines[i].replaceAll("#CMD:", acBrightWhite);
    lines[i] = lines[i].replaceAll("#SB1:", acBrightWhite);
    lines[i] = lines[i].replaceAll("#SB2:", " └─$acBrightWhite");
    lines[i] = lines[i].replaceAll("#SB3:", "    └─$acBrightWhite");
    lines[i] = lines[i].replaceAll("#OPR:", acBrightWhite);
  }

  // iterate through lines to add dots padding
  for (var i = 0; i < lines.length; i++) {
    // if line does not contain #DSCR: skip
    if (!lines[i].contains("#DSCR:")) {
      //continue;
    }
    // if line starts with #DSCR:
    if (lines[i].startsWith("#DSCR:")) {
      lines[i] =
          lines[i].replaceAll("#DSCR:", "$acReset                        ");
      continue;
    }
    // if line contains #DSCR:
    if (lines[i].contains("#DSCR:")) {
      // fill space between command and #DSCR: with dots, depending on command length
      var parts = lines[i].split("#DSCR:");
      var command = parts[0].trimRight();
      var description = parts[1].trim();
      int dotPaddingLength = fixedCommandWidth - command.length;
      String dotPadding = dotPaddingLength > 0 ? '.' * dotPaddingLength : "";
      lines[i] = "$command $acGrey$dotPadding$acReset $description";
    }
  }

  // ensure line fits into terminal width
  for (var i = 0; i < lines.length; i++) {
    // if line is longer than terminal width, -11 for ansi codes
    if ((lines[i].length - 11) > terminalWidth) {
      int lastSpace = 0;
      lastSpace = lines[i].substring(0, terminalWidth).lastIndexOf(" ");
      var line1 = lines[i].substring(0, lastSpace);
      var line2 = lines[i].substring(lastSpace + 1);
      line2 = "                        $line2";
      lines[i] = line1;
      lines.insert(i + 1, line2);
    }
  }

  // replace tags
  for (var i = 0; i < lines.length; i++) {
    lines[i] = lines[i].replaceAll("└─", "$acGrey└─$acReset");
    lines[i] = lines[i].replaceAll("#DSCR:", "$acReset ${" " * 19}");
    lines[i] = lines[i].trimRight();
  }

  // print all lines
  for (var i = 0; i < lines.length; i++) {
    print(lines[i]);
  }

  return;
}

// ─────────────────────────────────────────────────────────────────────────────
void terPrintSummary(line) {
  //print("terPrintSummary: $line");

  // replacements for some edge cases
  line = line.replaceAll("#SS:", "");
  line = line.replaceAll("#COR:", "");
  line = line.replaceAll("#ERR:", "");
  line = line.replaceAll("#WRN:", "");
  line = line.replaceAll("\n", "");
  // summary ─────────────────────────────────────────────────────────────
  // remove #SS from line
  line = line.replaceAll("#SS:", "");
  line = line.trim();

  List<String> lines = fitIntoTerminalWidth(line, indentation: 1);
  // print lines
  for (var i = 0; i < lines.length; i++) {
    if (i == 0) lines[i] = "\n$acItalic${lines[i]}";
    print(lines[i]);
  }
  print("");
}

// ─────────────────────────────────────────────────────────────────────────────
void terPrintLine(String line, {int indentation = 0}) {
  List<String> lines = fitIntoTerminalWidth(line, indentation: indentation);

  for (var i = 0; i < lines.length; i++) {
    print(lines[i]);
  }
  return;
}