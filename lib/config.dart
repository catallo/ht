import 'dart:io';

// configuration settings at ~/.config/ht/config.
// one setting per line:
// API-KEY: 1234567890
// debug: true

class Config {
  Config({this.apiKey, this.debug});

  String? apiKey;
  bool? debug;
  String? home = Platform.environment['HOME'];

  // check if config dir and file exists and create if not
  bool checkConfig() {
    if (!Directory('$home/.config/ht').existsSync()) {
      try {
        //print("creating config directory");
        Directory('$home/.config/ht').create(recursive: false);
      } catch (e) {
        print("Error creating directory: $e");
        return false;
      }
    }

    if (!File('$home/.config/ht/config').existsSync()) {
      try {
        //print("creating config file");
        File('$home/.config/ht/config').create(recursive: true);
        // write default settings to file (debug: false)
        File('$home/.config/ht/config')
            .writeAsStringSync('debug: false\n', mode: FileMode.append);
      } catch (e) {
        print("Error creating config file: $e");
        return false;
      }
    }
    return true;
  }

  // read API key
  String? readApiKey() {
    var file = File('$home/.config/ht/config').readAsStringSync();
    var lines = file.split('\n');

    for (var line in lines) {
      var parts = line.split(':');
      if (parts[0] == 'API-KEY') {
        return parts[1].trim();
      }
    }
    return null;
  }

  // set API key
  bool setApiKey(String apiKey) {
    // check if API key is in file
    var file = File('$home/.config/ht/config').readAsStringSync();
    var regex = RegExp(r'API-KEY:.*');
    if (regex.hasMatch(file)) {
      try {
        print("setting API key");
        file = file.replaceAll(regex, 'API-KEY: $apiKey');
        File('$home/.config/ht/config').writeAsStringSync(file);
        return true;
      } catch (e) {
        print("Error setting API key: $e");
        return false;
      }
    } else {
      // append API-KEY to file
      try {
        print("setting API key");
        File('$home/.config/ht/config')
            .writeAsStringSync('API-KEY: $apiKey\n', mode: FileMode.append);
        return true;
      } catch (e) {
        print("Error setting API key: $e");
        return false;
      }
    }
  }

  // read debug setting
  bool? readDebug() {
    var file = File('$home/.config/ht/config').readAsStringSync();
    var lines = file.split('\n');
    for (var line in lines) {
      var parts = line.split(':');
      if (parts[0] == 'debug') {
        return parts[1].trim() == 'true';
      }
    }
    return null;
  }

  // set debug setting
  bool setDebug(bool debug) {
    var file = File('$home/.config/ht/config').readAsStringSync();
    var regex = RegExp(r'debug:.*');

    if (regex.hasMatch(file)) {
      try {
        print("setting debug");
        file = file.replaceAll(regex, 'debug: $debug');
        File('$home/.config/ht/config').writeAsStringSync(file);
        return true;
      } catch (e) {
        print("Error setting debug: $e");
        return false;
      }
    } else {
      // append debug to file
      try {
        print("setting debug");
        File('$home/.config/ht/config')
            .writeAsStringSync('debug: $debug\n', mode: FileMode.append);
        return true;
      } catch (e) {
        print("Error setting debug: $e");
        return false;
      }
    }
  }
}
