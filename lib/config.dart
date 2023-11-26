import 'dart:io';
import 'package:ht/globals.dart';

// configuration settings at ~/.config/ht/config.
// one setting per line:
// API-KEY: 1234567890
// debug: false

class Config {
  Config({this.apiKey, this.debug});

  String? apiKey;
  bool? debug;
  String? home = Platform.environment['HOME'];

  String _getConfigFilePath() {
    return '${htPath}config';
  }

  // Check if config dir and file exist and create if not
  bool checkConfig() {
    final configDirPath = '$_getConfigFilePath()';
    if (!Directory(configDirPath).existsSync()) {
      try {
        Directory(configDirPath).createSync(recursive: false);
      } catch (e) {
        print("Error creating directory: $e");
        return false;
      }
    }
    final configFile = File(_getConfigFilePath());
    if (!configFile.existsSync()) {
      try {
        configFile.createSync(recursive: true);
        configFile.writeAsStringSync('debug: false\n', mode: FileMode.append);
      } catch (e) {
        print("Error creating config file: $e");
        return false;
      }
    }
    return true;
  }

  // Read property from config file
  String? _readProperty(String propertyName) {
    final configFile = File(_getConfigFilePath());
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
    final configFile = File(_getConfigFilePath());
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

  // Read API key
  String? readApiKey() {
    return _readProperty('API-KEY');
  }

  // Set API key
  bool setApiKey(String apiKey) {
    return _setProperty('API-KEY', apiKey);
  }

  // Read debug setting
  bool? readDebug() {
    final debugValue = _readProperty('debug');
    return debugValue == 'true';
  }

  // Set debug setting
  bool setDebug(bool debug) {
    final debugValue = debug ? 'true' : 'false';
    return _setProperty('debug', debugValue);
  }
}
