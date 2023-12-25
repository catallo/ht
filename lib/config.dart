import 'dart:io';
import 'package:ht/globals.dart';
import 'package:ht/installation_and_update.dart';

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
