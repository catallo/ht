import 'package:ht/ansi_codes.dart';

import 'wrapper_script.dart';
import 'dart:io';
import 'globals.dart';
import 'debug.dart';

bool checkInstallation() {
  dbg("checkInstallation started");
  if (!File("${htPath}ht").existsSync()) {
    dbg("${htPath}ht not found");
    installOrUpdate();
    return true;
  } else {
    dbg("ht found, checking version");
    // extracting version from installed warpper script
    var htWrapperScript = File("${htPath}ht").readAsStringSync();
    dbg("htWrapperScript:\n $htWrapperScript");
    var foundVersion = parseSemVer(htWrapperScript);
    dbg("this version: $version installed version: $foundVersion");
    if (isSemVerHigher(foundVersion, version)) {
      dbg("installed version is lower");
      installOrUpdate();
      return true;
    } else {
      dbg("installed version is the same or higher");
      print(" 🤖 ht is already installed and up to date.");
      exit(1);
    }
  }
}

bool installOrUpdate() {
  dbg("install started");
  // check if ~/.config/ht exists
  if (!Directory(htPath).existsSync()) {
    dbg("creating $htPath");
    try {
      Directory(htPath).createSync(recursive: false);
    } catch (e) {
      print("Error creating directory: $e");
      return false;
    }
  }
  final configFile = File("${htPath}config");
  if (!configFile.existsSync()) {
    try {
      configFile.createSync(recursive: true);
      configFile.writeAsStringSync('debug: false\n', mode: FileMode.append);
    } catch (e) {
      print("Error creating config file: $e");
      return false;
    }
  }
  // check if ~/.config/ exists
  if (!Directory("$home/config").existsSync()) {
    dbg("creating $home/config");
    try {
      Directory("$home/config").createSync(recursive: false);
    } catch (e) {
      print("Error creating directory: $e");
      return false;
    }
  }

  // check if ~/.config/ht/ht exists
  if (!File("${htPath}ht").existsSync()) {
    dbg("creating ${htPath}ht");
    try {
      File("${htPath}ht").createSync(recursive: false);
    } catch (e) {
      print("Error creating file: $e");
      return false;
    }
  }
  // write wrapper script
  if (!writeWrapperScript()) {
    print("Error writing wrapper script.");
    return false;
  }
  // add to PATH
  if (!addToPATH()) {
    print("Error adding ht to PATH.");
    return false;
  }
  // copy this file to ~/.config/ht/ht.bin
  // find the path of this file
  var thisFilePath = Platform.script.path;
  dbg("path: $thisFilePath");
  // copy this file to ~/.config/ht/ht.bin
  try {
    File(thisFilePath).copySync("${htPath}ht.bin");
  } catch (e) {
    //print("Error copying file: $e");
    //return false;
  }

  print(
      " 🤖 ht installed successfully. Please close and reopen the terminal and type ${acBold}ht$acReset to start.");
  exit(0);
}

String parseSemVer(String line) {
  final RegExp semVerRegex = RegExp(r'\bv(\d+\.\d+\.\d+)\b');
  final match = semVerRegex.firstMatch(line);

  if (match != null) {
    return match.group(1) ?? ''; // Return the matched version string
  } else {
    return ''; // Return empty string if no match is found
  }
}

bool isSemVerHigher(String installedVersion, String thisVersion) {
  List<int> installedParts =
      installedVersion.split('.').map(int.parse).toList();
  List<int> thisParts = thisVersion.split('.').map(int.parse).toList();

  for (int i = 0; i < installedParts.length; i++) {
    if (thisParts[i] > installedParts[i]) {
      return true;
    } else if (thisParts[i] < installedParts[i]) {
      return false;
    }
  }
  return false; // Return false if versions are identical
}

bool writeWrapperScript() {
  dbg("writeWrapperScript started");
  var wrapperScriptFile = File("${htPath}ht");
  try {
    wrapperScriptFile.writeAsStringSync(wrapperScript);
    Process.runSync("chmod", ["+x", "${htPath}ht"]);
    return true;
  } catch (e) {
    print("Problem writing wrapper script: $e");
    return false;
  }
}

bool addToPATH() {
  // add to PATH for bash, fish and zsh
  dbg("addToPATH started");
  dbg("home: $home");

  // bash
  if (File("$home/.bashrc").existsSync()) {
    dbg("bash config found");
    // check if ~/.bashrc contains htPath
    var bashrc = File("$home/.bashrc").readAsStringSync();
    if (bashrc.contains(htPath)) {
      dbg("ht is already in bash PATH.");
    } else {
      // add htPath to ~/.bashrc
      var output = Process.runSync(
          "bash", ["-c", "echo 'export PATH=\$PATH:$htPath' >> ~/.bashrc"]);
      dbg("ht added to bash PATH. $output");
    }
  }

  // fish
  if (File("$home/.config/fish/config.fish").existsSync()) {
    dbg("fish config found");
    var fishConfig = File("$home/.config/fish/config.fish").readAsStringSync();
    if (fishConfig.contains(htPath)) {
      dbg("ht is already in fish PATH.");
    } else {
      var output = Process.runSync("fish", [
        "-c",
        "echo 'set -gx PATH \$PATH $htPath' >> ~/.config/fish/config.fish"
      ]);
      dbg("ht added to fish PATH. $output");
    }
  }
  // zsh
  if (File("$home/.zshrc").existsSync()) {
    dbg("zsh config found");
    var zshrc = File("$home/.zshrc").readAsStringSync();
    if (zshrc.contains(htPath)) {
      dbg("ht is already in zsh PATH.");
    } else {
      var output = Process.runSync(
          "zsh", ["-c", "echo 'export PATH=\$PATH:$htPath' >> ~/.zshrc"]);
      dbg("ht added to zsh PATH. $output");
    }
  }
  return true;
}
