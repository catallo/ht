import 'dart:io';
import 'dart:convert';

import 'package:ht/globals.dart';

class Cache {
  Cache(this.prompt, this.response);

  String prompt;
  String response;

  bool save() {
    if (response == "null") {
      print("response is null");
      return false;
    }

    // check if database exists. if not, create it
    if (!File('${htPath}cache').existsSync()) {
      try {
        //print("creating database");
        File('${htPath}cache').create(recursive: true);
      } catch (e) {
        print("Error creating cache file: $e");
        return false;
      }
    }

    response = response.replaceAll('"', '\\"');
    //response = response.replaceAll('\n', '\\n');

    // append  to file
    var json = jsonEncode({'prompt': prompt, 'response': response});
    File('${htPath}cache').writeAsStringSync('$json\n', mode: FileMode.append);
    return true;
  }

  // search in database
  String? search() {
    if (!File('${htPath}cache').existsSync()) {
      //print("database does not exist");
      return null;
    }
    // read file
    var file = File('${htPath}cache').readAsStringSync();
    var lines = file.split('\n');
    for (var line in lines) {
      if (line.isEmpty) {
        // skip line
        continue;
      }
      var json = jsonDecode(line);
      if (json['prompt'] == prompt) {
        json['response'] = json['response'].replaceAll('\\"', '"');
        return json['response'];
      }
    }
    // return null if no match was found
    return null;
  }
}
