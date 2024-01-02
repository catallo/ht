import 'dart:io';
import 'package:ht/ansi_codes.dart';
import 'package:ht/globals.dart';
import 'package:ht/installation_and_update.dart';

import 'debug.dart';
import 'ter_print.dart';

// configuration settings at ~/.config/ht/config.
// key: value
// API-KEY: sk-1234567890
// debug: false

class Config {
  Config({this.apiKey, this.debug});

  String? apiKey;
  bool? debug;
  String? home = Platform.environment['HOME'];

  bool checkConfig() {
    if (!Directory(htPath).existsSync()) {
      checkInstallation();
    } else {
      return true;
    }
    return false;
  }

  // Read property from config file
  String? _readProperty(String propertyName) {
    // check if config file exists
    if (!File("${htPath}config").existsSync()) {
      print(
          "\n🤖 Config file not found. Please run$acBold rm -rf ~/.config/ht/$acReset and reinstall ht.\n");
      exit(1);
    }

    final configFile = File("${htPath}config");
    final fileContents = configFile.readAsStringSync();
    final lines = fileContents.split('\n');

    for (var line in lines) {
      final parts = line.split(':');
      if (parts[0].trim() == propertyName) {
        return parts[1].trim();
      }
    }
    return null;
  }

// Set property in config file
  bool _setProperty(String propertyName, String propertyValue) {
    final configFile = File("${htPath}config");
    final regex = RegExp('$propertyName:.*');

    String fileContents =
        configFile.readAsStringSync(); // Assign to fileContents

    if (regex.hasMatch(fileContents)) {
      try {
        fileContents = fileContents.replaceAll(
            regex, '$propertyName: $propertyValue'); // Update fileContents
        configFile.writeAsStringSync(fileContents);
        return true;
      } catch (e) {
        print("Error setting $propertyName: $e");
        return false;
      }
    } else {
      try {
        configFile.writeAsStringSync('$propertyName: $propertyValue\n',
            mode: FileMode.append);
        return true;
      } catch (e) {
        print("Error setting $propertyName: $e");
        return false;
      }
    }
  }

  String? readApiKey() {
    if (getOpenAIApiKeyFromENV()) {
      return openAIapiKey;
    }
    return _readProperty('API-KEY');
  }

  bool setApiKey(String apiKey) {
    return _setProperty('API-KEY', apiKey);
  }

  bool? readDebug() {
    final debugValue = _readProperty('debug');
    return debugValue == 'true';
  }

  bool setDebug(bool debug) {
    final debugValue = debug ? 'true' : 'false';
    return _setProperty('debug', debugValue);
  }
}

void setupApiKey() {
  terPrint(
      "\n\n 🤖 Welcome to ht. To use this application, you need to set an OpenAI API key.");
  print("");
  terPrint(
      "The good news is that due to ht's low token usage, a typical request costs about \$0.00025, making it a budget-friendly tool for daily usage. You can obtain an API key by signing up at https://platform.openai.com/signup. For a more detailed guide on how to get an OpenAI API key, you can refer to this article: https://www.howtogeek.com/885918/how-to-get-an-openai-api-key/.");
  stdout.write(
      "\n${acBold}Paste your OpenAI API key here (or press enter to exit):$acReset ");
  openAIapiKey = stdin.readLineSync();
  if (openAIapiKey!.isEmpty) {
    print("Exiting...");
    exit(1);
  }
  config.setApiKey(openAIapiKey!);
  print("API key set. Please run ht again.");
  exit(0);
}

bool getOpenAIApiKeyFromENV() {
  if (Platform.environment.containsKey('OPENAI_API_KEY')) {
    dbg("OPENAI_API_KEY found in environment");
    openAIapiKey = Platform.environment['OPENAI_API_KEY'];
    return true;
  } else {
    dbg("OPENAI_API_KEY not found in environment");
    return false;
  }
}
