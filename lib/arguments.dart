import 'package:ht/ansi_codes.dart';
import 'dart:io';
import 'dart:async';

import 'package:ht/globals.dart';
import 'package:ht/request_openai_explain.dart';
import 'package:ht/cache.dart';
import 'package:ht/ter_print.dart';
import 'installation_and_update.dart';
import 'debug.dart';

import 'package:ht/request_ollama_explain.dart';

Future<bool> parseArguments(List arguments) async {
  // help ──────────────────────────────────────────────────────────────────────
  if (arguments.isEmpty ||
      (arguments[0] == '-h') ||
      (arguments[0] == '--help')) {
    print(
        "\n$acItalic${acBold}ht (for how-to)$acReset,$acItalic a shell command that answers your questions about shell commands.\n");
    print("$acItalic  Usage$acReset:");
    print(
        "$acBold  ht <instruction>$acReset        - answers with a shell command");
    print("$acBold  ht e|explain$acReset            - explains last answer");
    print("$acBold  ht e|explain [command]$acReset  - explains command");
    print("$acBold  ht x|execute          $acReset  - executes last command\n");
    print("$acBold  ht -h|--help$acReset            - help");
    print("$acBold  ht -s|--settings$acReset        - settings overview");
    print("$acBold  ht -v|--version$acReset         - show version");
    print("$acItalic\nExamples:$acReset");
    print("ht find all IPv4 addresses in log file and write to new file");
    print("ht explain");
    print("ht explain ls -lS");
    print('ht explain "ps -aux | grep nvidia"');
    print(
        "$acReset$acGrey                                                   https://github.com/catallo/ht$acReset");
    return false;
  }

  // debug ─────────────────────────────────────────────────────────────────────
  if ((arguments[0] == '-d') || (arguments[0] == '--debug')) {
    debug = true;
    arguments = arguments.sublist(1);
  }

  // show settings ─────────────────────────────────────────────────────────────
  if ((arguments[0] == '-s') || (arguments[0] == '--settings')) {
    print(acBold);
    //print("$acBold  model:     $model");
    print("  ${acBold}apikey:    ..${apiKey!.substring(apiKey!.length - 6)}");

    print("  debug:     $debug");
    print(
        "\n$acReset${acItalic}Use 'ht -set <setting> <value>' to change setting (or edit ~/.config/ht/config).");
    print("example: ht -set apikey <your-api-key>>\n");
    return false;
  }

  // set setting ───────────────────────────────────────────────────────────────
  if (arguments[0] == '-set') {
    if (arguments.length != 3) {
      print("\n$acBold  Wrong number of arguments.\n");
      print("$acBold$acItalic  Usage:$acReset  ht -set <setting> <value>");
      exit(1);
    }

    var setting = arguments[1];
    var value = arguments[2];

    switch (setting) {
      case "model":
        print("Setting model to $value");
        break;
      case "apikey":
        print("Setting apikey to $value");
        config.setApiKey(value);
        break;
      case "debug":
        if (value == "true") {
          debug = true;
          print("Setting debug to true. Use ht -set debug false to disable.");
          config.setDebug(true);
        } else {
          debug = false;
          print("Setting debug to false");
          config.setDebug(false);
        }
        break;
      default:
        print(
            "Unknown setting $setting, type ht -s to see available settings.");
        exit(1);
    }
    return false;
  }
  // version ───────────────────────────────────────────────────────────────────
  if ((arguments[0] == '-v') || (arguments[0] == '--version')) {
    print(
        "\n$acItalic$acBold  ht$acReset$acItalic v$version ($compileDate)$acReset\n");
    print("$acGrey  Detected OS:$acBrightGrey     $os");
    print("$acGrey  Detected Distro:$acBrightGrey $distro");
    print("$acGrey  Default Shell:$acBrightGrey   $shell");
    print("$acGrey  Model:$acBrightGrey           $model\n");

    return false;
  }
  // explain last response ─────────────────────────────────────────────────────
  if ((arguments[0] == 'explain' || arguments[0] == 'e')) {
    var command = "";

    // if arguments < 2
    if (arguments.length < 2) {
      var lastResponse = File('${htPath}last_response').readAsStringSync();
      // remove all empty lines from last response, also trim
      command = lastResponse
          .split('\n')
          .where((element) => element.isNotEmpty)
          .join('\n')
          .trim();
      if (lastResponse.isEmpty) {
        print("No last response found.");
        exit(1);
      }
    }
    if (arguments.length > 1) {
      command = arguments.sublist(1).join(' ');
    }
    Cache cache = Cache(command, "");
    String? cachedResponse = cache.search();
    if (cachedResponse != null) {
      print("\n$acBold $command$acReset\n");
      // split cachedResponse into lines
      var lines = cachedResponse.split('\n');
      // terPrint all lines
      for (var line in lines) {
        terPrint(line);
      }
      exit(0);
    }
    //requestGPTexplain(command);
    requestOllamaExplain(command);
    return false;
  }
  return true;
}
