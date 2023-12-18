import 'wrapper_script.dart';
import 'dart:io';
import 'globals.dart';
import 'debug.dart';

bool writeWrapperScript() {
  dbg("writeWrapperScript started");
  var wrapperScriptFile = File("$htPath/ht");
  try {
    wrapperScriptFile.writeAsStringSync(wrapperScript);
    Process.runSync("chmod", ["+x", "$htPath/ht"]);
    return true;
  } catch (e) {
    print("Problem writing wrapper script: $e");
    return false;
  }
}

bool addToPATH() {
  // add to PATH for bash, fish and zsh
  dbg("addToPATH started");
  // check if ~/.bashrc exists
  if (File("~/.bashrc").existsSync()) {
    // check if ~/.bashrc contains htPath
    var bashrc = File("~/.bashrc").readAsStringSync();
    if (bashrc.contains("export PATH=\$PATH:$htPath")) {
      dbg("ht is already in bash PATH.");
    } else {
      // add htPath to ~/.bashrc
      var output = Process.runSync(
          "bash", ["-c", "echo 'export PATH=\$PATH:$htPath' >> ~/.bashrc"]);
      dbg(output.stdout);
    }
  }
  // fish
  if (File("~/.config/fish/config.fish").existsSync()) {
    var fishConfig = File("~/.config/fish/config.fish").readAsStringSync();
    if (fishConfig.contains("set -gx PATH \$PATH $htPath")) {
      dbg("ht is already in fish PATH.");
    } else {
      var output = Process.runSync("fish", [
        "-c",
        "echo 'set -gx PATH \$PATH $htPath' >> ~/.config/fish/config.fish"
      ]);
      dbg(output.stdout);
    }
  }
  // zsh
  if (File("~/.zshrc").existsSync()) {
    var zshrc = File("~/.zshrc").readAsStringSync();
    if (zshrc.contains("export PATH=\$PATH:$htPath")) {
      dbg("ht is already in zsh PATH.");
    } else {
      var output = Process.runSync(
          "zsh", ["-c", "echo 'export PATH=\$PATH:$htPath' >> ~/.zshrc"]);
      dbg(output.stdout);
    }
  }
  return true;
}
