// ht (for 'how-to') - a shell command that answers your questions about shell commands.
//
// MIT License
//
// Copyright (c) 2023 Sandro Catallo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import 'dart:io';
import 'dart:convert';
import 'package:ht/checkDistro.dart';
import 'package:ht/db.dart';
import 'package:ht/ansi_codes.dart';
import 'package:ht/config.dart';

import 'package:dart_openai/dart_openai.dart';

final db = DB("", "");

bool debug = false;

const version = "1.0.5"; // SemVer
const compileDate = "2023-10-18";

final String os = Platform.operatingSystem;
String distro = "Debian derivate";
String uname = "-";
String shell = "";

final String model = "gpt-3.5-turbo";
final String temp = "0.0";

String? apiKey = "";

String systemRole =
    "You're an assistant for using shell on $distro. You always answer with only the command without any further explanation!";

//String systemRoleX =
//    "You're a shell command for using shell on $distro. Explain every argument used in only the last command, write a newline after every argument. Check the command for syntax errors and suggest the correct version if an error is found. Give short answers.";

String systemRoleX =
    // ignore: prefer_interpolation_to_compose_strings
    "You're an assistant for using shell on $distro. You're given a shell command that you will analyse by conducting the following steps:"
    "\\n1. Check the command for syntax errors and if an error is found suggest the correct version.\\n2. Explain every argument used in"
    " only the last command followed by a newline.\\nGive short answers.";

String prePrompt =
    "$distro $os command to replace every IP address in file logfile with 192.168.0.1\n\nsed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile\n\n$distro $os command to mv file list1 to list2\n\nmv list1 list2\n$distro $os command to ";

String prePromptX =
    "Explain $os command ls -l -R\n\nls lists directory contents\n  -l lists in long format\n-  R lists subdirectories recursively.\n\nExplain $os command rm -rf\n\nrm removes files or directories\n  -r removes directories and their contents recursively\n  -f ignores nonexistent files and arguments, never prompts\n  / is the root directory\n\nExplain $os command";

final String stop = "Explain $os command";

String promptEx = '''{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You're a Unix shell expert. You sort parts of commands into the following categories followed by '#DSCR:' and a description: \n\n#CMD: actual command #DSCR:\n#SUB: options and other things following the command #DSCR:\n#SUBSUB: sub parts of the above #DSCR:\n#SUBSUBSUB: sub parts of the above #DSCR:\n#OPR: Operators like | or > that are not part of an actual command #DSCR:\n\nYour output will be parsed to a hierachical structure, this is what SUB: and SUBSUB: are for. Describe parts in the same order as in the original command.\n\n#ERR: use this to describe every error or misspelling of commands you found\n#COR: the corrected version if an error was found\n\nIf you found an error, describe the corrected version!\n\n#SS: short summary"
    },
    {
      "role": "user",
      "content": "Describe and check for errors: ls -l -R"
    },
    {
      "role": "assistant",
      "content": "#ERR: none\n#CMD: ls #DSCR: lists directory contents\n#SUB: -l #DSCR: lists in long format\n#SUB: -R #DSCR: lists subdirectories recursively\n#SS: Lists directory and subdirectories in long format"
    },
    {
      "role": "user",
      "content": "Describe and check for errors: sed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile"
    },
    {
      "role": "assistant",
      "content": "#ERR: none\n#CMD: sed #DSCR: stream editor for filtering and transforming text\n#SUB: -i #DSCR: edit files in-place\n#SUB: 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' #DSCR: search and replace pattern\n#SUBSUB: [0-9]{1,3} #DSCR: specifies one to three digits\n#SUBSUB: . #DSCR: specifies a literal period\n#SUBSUB: /192.168.0.1/ #DSCR: specifies the replacement text\n#SUBSUB: g #DSCR: specifies global replacement (replace all occurrences on each line)\n#SUB: logfile #DSCR: the file name on which the command is to be applied\n#SS: Searches for IP addresses (in the format xxx.xxx.xxx.xxx) in the logfile and replaces them with 192.168.0.1, saving the changes to the logfile."
    },
    {
      "role": "user",
      "content": "Describe and check for errors: curl -s https://www.google.de | grep -oE '\\b\\w+\\b'"
    },
    {
      "role": "assistant",
      "content": "#ERR: none\n#CMD: curl #DSCR: command line tool for transferring data from or to a server\n#SUB: -s #DSCR: silent mode, does not show progress or error messages\n#SUB: https://www.google.de #DSCR: specifies the URL to retrieve data from\n#OPR: | #DSCR: redirects the output of the previous command to the next command\n#CMD: grep #DSCR: searches for patterns in text\n#SUB: -oE #DSCR: tells grep to show only the matched portion of the line using extended regular expressions\n#SUB: '\\b\\w+\\b' #DSCR: regular expression pattern to match words\n#SS: Retrieves the content of https://www.google.de and then extracts and displays only the individual words found in the text."
    },
    {
      "role": "user",
      "content": "Describe and check for errors: grep -E -o "([0-9]{1,3}\\.){3}[0-9]{1,3}" file1 > file2 "
    },
    {
      "role": "assistant",
      "content": "#ERR: none\n#CMD: grep #DSCR: searches for patterns in text\n#SUB: -E #DSCR: tells grep to use extended regular expressions\n#SUB: -o #DSCR: only outputs the matched portion of the line\n#SUB: "([0-9]{1,3}\\.){3}[0-9]{1,3}" #DSCR: regular expression pattern to match IP addresses\n#SUBSUB: [0-9]{1,3} #DSCR: specifies one to three digits\n#SUBSUB: \\. #DSCR: specifies a literal period\n#SUBSUB: {3} #DSCR: specifies exactly three occurrences of the preceding pattern\n#SUB: file1 #DSCR: the file to search in\n#OPR: > #DSCR: redirects the output to a file\n#SUB: file2 #DSCR: the file to write the output to\n#SS: Searches for IP addresses in file1 using extended regular expressions and writes the matched IP addresses to file2."
    },
    {
      "role": "user",
      "content": "Describe and check for errors: mkdirr ~/bin && echo "export PATH=\$PATH:\$HOME/bin" >> ~/.bashrt"
    },
    {
      "role": "assistant",
      "content": "#ERR: The comands name is mkdir, not mkdirr.  The name of the bash configuration file is .bashrc, not .bashrt\n#COR: mkdir ~/bin && echo "export PATH=\$PATH:\$HOME/bin" >> ~/.bashrc\n#CMD: mkdir #DSCR: creates a new directory\n#SUB: ~/bin #DSCR: specifies the path of the new directory as the user's home directory followed by "/bin"\n#OPR: && #DSCR: executes the next command only if the previous command succeeds\n#CMD: echo #DSCR: prints a string to the standard output\n#SUB: "export PATH=\$PATH:\$HOME/bin" #DSCR: the string to be printed\n#OPR: >> #DSCR: appends the output to a file\n#SUB: ~/.bashrc #DSCR: the file to append the output to\n#SS: Creates a new directory named "bin" in the user's home directory and then appends the line "export PATH=\$PATH:\$HOME/bin" to the end of the ~/.bashrc file. This ensures that the newly created "bin" directory is added to the system's PATH variable."
    },
    {
      "role": "user",
      "content": "Describe and check for errors: echo "set -xg PATH /home/sco/bin" >> ~/.config/fish/config.fish"
    }
  ],
  "temperature": 0,
  "max_tokens": 512,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0
}''';

// explain last response ───────────────────────────────────────────────────────
void explainLastResponse(String lastCommand) {
  //print("$acBold$lastCommand$acReset");

  prePromptX = prePromptX.replaceAll("\n", "\\n");

  String prompt = "$prePromptX $lastCommand";

  // replace " with \" in prompt
  prompt = prompt.replaceAll('"', '\\"');

  dbg("prompt: $prompt");
  // String explanation =
  //    requestGPTEx(model, systemRoleX, prompt, temp, 2048, "").toString();

  String explanation =
      requestGPTEx(model, systemRoleX, lastCommand, temp, 2048, "").toString();

  // print explanation
  if (explanation != "null") {
    //explanation = filterResponse(explanation);
    printResponse(explanation);
    // write to db
    db.prompt = lastCommand;
    db.response = explanation;
    db.save();
    exit(0);
  } else {
    print('\x1B[36;1m  No explanation available\x1B[0m');
    exit(1);
  }
}

// explain command ─────────────────────────────────────────────────────────────
void explainCommand(var command) {
  prePromptX = prePromptX.replaceAll("\n", "\\n");

  String prompt = "$prePromptX " + command;

  var explanation =
      requestGPT(model, systemRoleX, prompt, temp, 2048, "").toString();

  //explanation = filterResponse(explanation);

  printResponse(explanation);

  // write to db
  db.prompt = command;
  db.response = explanation;
  db.save();

  exit(0);
}

// request to OpenAI API ───────────────────────────────────────────────────────
String? requestGPTEx(String model, String role, String prompt,
    String temperature, int maxTokens, String stop) {
  String roleJSON = jsonEncode(role);
  String promptJSON = jsonEncode(promptEx);

  dbg("roleJSON: $roleJSON");
  dbg("promptJSON: $promptJSON");

  var process = Process.runSync('curl', [promptJSON]);

  dbg("process.stdout: ${process.stdout}");

  calculateCost(process.stdout.toString());

  Map<String, dynamic> response = jsonDecode(process.stdout.toString());

  // check json response for errors
  if (response.containsKey('error')) {
    print("There was a problem: ${response['error']['message']}");
    switch (response['error']['code']) {
      case "invalid_request":
        print(
            "The request was invalid. This is usually due to missing a required parameter.");
        break;
      case "invalid_api_key":
        print("Use ht --settings to see how to set your API key.");
        break;
      default:
        print("Unknown error code: ${response['error']['code']}");
    }
    exit(1);
  }

  dbg(response['choices'][0]['message']['content']);
  String returnValue = response['choices'][0]['message']['content'];
  returnValue = returnValue.replaceAll("\\\\", "\\");

  return response['choices'][0]['message']['content'];
}

// request to OpenAI API ───────────────────────────────────────────────────────
String? requestGPT(String model, String role, String prompt, String temperature,
    int maxTokens, String stop) {
  String roleJSON = jsonEncode(role);
  String promptJSON = jsonEncode(prompt);

  dbg("roleJSON: $roleJSON");
  dbg("promptJSON: $promptJSON");

  var process = Process.runSync('curl', [
    "https://api.openai.com/v1/chat/completions",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer $apiKey",
    "-d",
    '{"model": "$model", "messages": [{"role": "system", "content" : "$role"}, {"role": "user", "content": $promptJSON}], "temperature": $temperature, "max_tokens": $maxTokens, "stream": false}'
  ]);
  dbg("process.stdout: ${process.stdout}");

  calculateCost(process.stdout.toString());

  Map<String, dynamic> response = jsonDecode(process.stdout.toString());

  // check json response for errors
  if (response.containsKey('error')) {
    print("There was a problem: ${response['error']['message']}");
    switch (response['error']['code']) {
      case "invalid_request":
        print(
            "The request was invalid. This is usually due to missing a required parameter.");
        break;
      case "invalid_api_key":
        print("Use ht --settings to see how to set your API key.");
        break;
      default:
        print("Unknown error code: ${response['error']['code']}");
    }
    exit(1);
  }

  dbg(response['choices'][0]['message']['content']);
  String returnValue = response['choices'][0]['message']['content'];
  returnValue = returnValue.replaceAll("\\\\", "\\");

  return response['choices'][0]['message']['content'];
}

// filterResponse ──────────────────────────────────────────────────────────────
String filterResponse(String text) {
  text = text.replaceAll("\n\n", "\n");
  text = text.replaceAll("\\n\\n", "\n");

  text = text.replaceAll("\\n", "\n");
  text = text.replaceAll('\\"', '"');

  var lines = text.split("\n");
  for (var i = 0; i < lines.length; i++) {
    // if line starts with "- ", replace with "  "
    if (lines[i].startsWith("- ")) {
      lines[i] = "  ${lines[i].substring(2)}";
    }
    if (lines[i].startsWith("The last command you mentioned, ")) {
      lines[i] = lines[i].substring(32);
    }
    if (lines[i].contains("syntax error") ||
        lines[i].contains("incorrect") ||
        lines[i].contains("not a valid")) {
      lines[i] = "$acBold${lines[i]}$acReset\n";
    }
  }
  text = lines.join("\n");

  text = text.replaceAll("```", "");
  text = text.replaceAll("So, ", "$acReset$acItalic\nSo, ");
  text = text.replaceAll("Note: ", "$acReset$acItalic\nNote: ");
  text = text.replaceAll("Overall, ", "$acReset$acItalic\nOverall, ");
  text = text.replaceAll("However, ", "$acReset$acItalic\nHowever, ");
  text = text.replaceAll("Together, ", "$acReset$acItalic\nTogether, ");
  text = text.replaceAll("Remember, ", "$acReset$acItalic\nRemember, ");
  text = text.replaceAll("In short, ", "$acReset$acItalic\nIn short, ");
  text = text.replaceAll("In general, ", "$acReset$acItalic\nIn general, ");
  text = text.replaceAll("In summary, ", "$acReset$acItalic\nIn summary, ");
  text = text.replaceAll("Please note ", "$acReset$acItalic\nPlease note ");
  text = text.replaceAll("This command ", "$acReset$acItalic\nThis command ");
  text = text.replaceAll(
      "Please remember ", "$acReset$acItalic\nPlease remember ");
  text = text.replaceAll(
      "Please keep in mind ", "$acReset$acItalic\nPlease keep in mind ");

  dbg("filtered text: $text");
  return text;
}

// print response ──────────────────────────────────────────────────────────────
void printResponse(String text) {
  //text = text.replaceAll("\n", "\n  ");
  //text = text.replaceAll("\\n", "\n  ");
  text = text.replaceAll(RegExp(r'\\?\n'), '\n');

  text = filterResponse(text);

  // ensure lines in the output do not exceed terminal width
  var terminalWidth = stdout.terminalColumns;
  var lines = text.split("\n");
  var newLines = <String>[];
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    var words = line.split(" ");
    var newLine = "";
    for (var j = 0; j < words.length; j++) {
      var word = words[j];
      if (newLine.length + word.length + 1 > terminalWidth) {
        newLines.add(newLine);
        newLine = "";
      }
      newLine += "$word ";
    }
    newLines.add(newLine);
  }

  text = newLines.join("\n");

  print('\n$text$acReset\n');
}

// write last response to file ─────────────────────────────────────────────────
void saveLastResponse(String text) {
  var home = Platform.environment['HOME'];
  dbg("home: $home");
  // check if directory ~/.config/h exists
  if (!Directory('$home/.config/h').existsSync()) {
    Directory('$home/.config/h').create(recursive: true);
  }

  File('$home/.config/ht/last_response').create(recursive: true);

  var file = File('$home/.config/ht/last_response').writeAsStringSync(text);

  dbg("writing to last_response: $text ");
}

// debug output ────────────────────────────────────────────────────────────────
void dbg(String text) {
  if (!debug) return;
  print("\x1B[34mdbg:\x1B[0m \x1B[33m$text\x1B[0m");
}

// calculate costs ─────────────────────────────────────────────────────────────
void calculateCost(String processStdout) {
  String? promptTokens = "0";
  var promptTokensReg =
      RegExp(r'"prompt_tokens": (.*?),\n').firstMatch(processStdout.toString());

  if (promptTokensReg != null) {
    promptTokens = promptTokensReg.group(1);
    dbg("promptTokens: $promptTokens");
  }

  String? completionTokens = "0";
  var completionTokensReg = RegExp(r'"completion_tokens": (.*?),\n')
      .firstMatch(processStdout.toString());

  if (completionTokensReg != null) {
    completionTokens = completionTokensReg.group(1);
    dbg("completionTokens: $completionTokens");
  }

  promptTokens = double.parse(promptTokens!).toString();
  completionTokens = double.parse(completionTokens!).toString();

  // promptTokens cost $0.0015, completionTokens cost $0.002 per 1000 tokens
  var cost = (double.parse(promptTokens) * 0.0015) +
      (double.parse(completionTokens) * 0.002);
  cost /= 1000;

  dbg("cost: \$ $cost");
}

// gather information about system ─────────────────────────────────────────────
void gatherSystemInfo() {
  dbg("os: $os");

  var out = Process.runSync('uname', ['-a']);
  uname = out.stdout.toString().trim();
  dbg("uname: $uname");

  if (Platform.isMacOS) {
    distro = "MacOS";
  } else {
    distro = checkDistro(uname) ?? "Debian derivate";
  }

  dbg("distro: $distro");

  shell = Platform.environment['SHELL']!;
  // trim shell to the last part after the last /
  shell = shell.substring(shell.lastIndexOf('/') + 1);
  dbg("shell: $shell");
}

// execute command ─────────────────────────────────────────────────────────────
Future<bool> executeCommand(String commandWithArguments) async {
  //print("executing $commandWithArguments:");

  var home = Platform.environment['HOME'];
  var filePath = '$home/.config/ht/execute';

  await File(filePath).writeAsString(commandWithArguments);

  var width = stdout.terminalColumns;
  var height = stdout.terminalLines;

  print(acGrey + List.filled(width, '─').join() + acReset);
  print("");

  await Future.delayed(Duration(milliseconds: 300));

  Process process = await Process.start('bash', [filePath],
      environment: {'COLUMNS': width.toString(), 'LINES': height.toString()});

  process.stdout.transform(utf8.decoder).listen((data) {
    stdout.write(data);
  });

  int exitCode = await process.exitCode;
  //print('Command exited with code $exitCode');

  // print out the result of stderr from the process
  String stdError = await process.stderr.transform(utf8.decoder).join();
  if (stdError.isNotEmpty) {
    // there are two ":" in the error message, we want the string right from the second ":"
    var error = stdError.substring(stdError.indexOf(":") + 1);
    error = error.substring(error.indexOf(":") + 1);
    error = error.trim();

    print("${acBold}Error: $acBrightRed$error$acReset");
  }
  return exitCode == 0;
}

// main ────────────────────────────────────────────────────────────────────────
main(List<String> arguments) async {
  gatherSystemInfo();

  var config = Config();
  config.checkConfig();

  debug = config.readDebug() ?? false;

  apiKey = config.readApiKey();
  OpenAI.apiKey = apiKey ?? "couldn't read API key";

  if (apiKey == null) {
    print(
        "To use this application, you need to set an API key. The good news is that due to ht's");
    print(
        "low token usage, a typical request costs about \$0.00025, making it a budget-friendly\ntool for daily usage.");
    print(
        "You can obtain an API key by signing up at https://platform.openai.com/signup.");
    print(
        "For a more detailed guide on how to get an OpenAI API key, you can refer to this\narticle:\nhttps://www.howtogeek.com/885918/how-to-get-an-openai-api-key/.");

    stdout.write("\n${acBold}Enter your API key (or press enter to exit): ");

    apiKey = stdin.readLineSync();

    if (apiKey!.isEmpty) {
      print("Exiting...");
      exit(1);
    }

    config.setApiKey(apiKey!);
    print("API key set.");
    exit(0);
  }

  // arguments ─────────────────────────────────────────────────────────────────

  // if arguments is empty, print help
  if (arguments.isEmpty ||
      (arguments[0] == '-h') ||
      (arguments[0] == '--help')) {
    print(
        "\n$acItalic${acBold}ht (for how-to)$acReset,$acItalic a shell command that answers your questions about shell commands.\n");
    print("$acItalic  Usage$acReset:");
    print("$acBold  ht <question>$acReset           - answers question");
    print("$acBold  ht e|explain$acReset            - explains last answer");
    print("$acBold  ht e|explain [command]$acReset  - explains command\n");
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
    exit(0);
  }

  // if arguments starts with -d or --debug, set debug to true for this session
  if ((arguments[0] == '-d') || (arguments[0] == '--debug')) {
    debug = true;
    arguments = arguments.sublist(1);
  }

  // if arguments is -s or --settings, print settings
  if ((arguments[0] == '-s') || (arguments[0] == '--settings')) {
    print(acBold);
    //print("$acBold  model:     $model");
    print("  ${acBold}apikey:    ..${apiKey!.substring(apiKey!.length - 6)}");

    print("  debug:     $debug");
    print(
        "\n$acReset${acItalic}Use 'ht -set <setting> <value>' to change setting (or edit ~/.config/ht/config).");
    print("example: ht -set apikey <your-api-key>>\n");
    exit(0);
  }

  // if starts with -set, set setting
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
    exit(1);
  }

  // if arguments is -v or --version, print version
  if ((arguments[0] == '-v') || (arguments[0] == '--version')) {
    print(
        "\n$acItalic$acBold  ht$acReset$acItalic v$version ($compileDate)$acReset\n");
    print("$acGrey  Detected OS:$acBrightGrey     $os");
    print("$acGrey  Detected Distro:$acBrightGrey $distro");
    print("$acGrey  Default Shell:$acBrightGrey   $shell");
    print("$acGrey  Model:$acBrightGrey           $model\n");

    exit(0);
  }

  // database ──────────────────────────────────────────────────────────────────
  // check if in database
  String promptDb;

  var explain = false;

  if (arguments[0] == 'e' || arguments[0] == 'explain') {
    explain = true;
    // if there is only one argument
    if (arguments.length == 1) {
      dbg("explain last command...");
      // check if file ~/.config/ht/last_response exists
      var lastResponseFile =
          File('${Platform.environment['HOME']}/.config/ht/last_response');
      if (lastResponseFile.existsSync()) {
        // read last command
        String lastCommand = lastResponseFile.readAsStringSync();
        dbg('last command: $lastCommand');
        // check if in db
        db.prompt = lastCommand;
        var response = db.search();
        dbg("db response: $response");
        if (response != null) {
          print("$acBold$lastCommand$acReset");
          printResponse(response);
          exit(0);
        } else {
          dbg('  \x1B[36;1m  not found in DB\x1B[0m');
          explainLastResponse(lastCommand);
        }
      }
    }

    promptDb = arguments.sublist(1).join(' ');
  } else {
    promptDb = arguments.join(' ');
  }

  db.prompt = promptDb;
  var response = db.search();
  if (response != null) {
    dbg("found in db");
    printResponse(response);
    if (!explain) {
      saveLastResponse(response);
    }
    exit(0);
  }

  // last response ─────────────────────────────────────────────────────────────

  // if the first argument is explain or e, we will explain the last response
  if ((arguments[0] == 'explain' || arguments[0] == 'e')) {
    explain = true;
    // if there is more than 1 argument
    if (arguments.length > 1) {
      // if the second argument is last
      // String joining all arguments except arguments[0]
      var command = arguments.sublist(1).join(' ');
      explainCommand(command);
    } else {
      print("${acItalic}Usage:$acReset ht e|explain [command]");
      exit(1);
    }
  }

  // execute last response ─────────────────────────────────────────────────────

  // if the first argument is x or execute, we will execute the last response
  if ((arguments[0] == 'x') || (arguments[0] == 'execute')) {
    // run only if there is one argument
    if (arguments.length == 1) {
      // check if file ~/.config/ht/last_response exists
      var lastResponseFile =
          File('${Platform.environment['HOME']}/.config/ht/last_response');
      if (lastResponseFile.existsSync()) {
        // read last command
        String lastCommand = lastResponseFile.readAsStringSync();
        dbg('last command: $lastCommand');

        // a print message that says we are checking the last command for validity
        stdout.write("checking $acBold$lastCommand$acReset ... ");

        String placeholderCheckPrompt =
            "Would the Linux shell command: '$lastCommand' work as is on $distro?";

        var validCheck =
            requestGPT(model, "", placeholderCheckPrompt, temp, 512, "");
        print(validCheck);
        // if command is not NULL or not valid, exit
        if (validCheck != null && validCheck.contains("##ERROR:")) {
          // print reason for invalidity but without ##ERROR:
          print("$acBold$acBrightRed"
              "\n\n${acBold}Warning: $acReset$acRed${validCheck.substring(9)}$acReset");
          stdout.write("\nDo you want to run it anyway? (y/N):");
        } else {
          stdout.write(
              "\n$acBold✓$acReset Command is valid.\nDo you want to execute it? (y/N):");
        }
        var answer = stdin.readLineSync();
        if (answer != "y") {
          print("Exiting...");
          exit(0);
        }
        // execute last command and wait until it's finished
        print(acReset);
        await executeCommand(lastCommand);

        exit(0);
      }
    }
  }

  // takes all arguments and joins them with spaces as a single string named prompt
  prePrompt = prePrompt.replaceAll("\n", "\\n");
  String prompt = prePrompt + arguments.join(' ');

  dbg("prompt: $prompt");

  var theAnswer =
      requestGPT(model, systemRole, prompt, temp, 512, stop).toString();

  dbg("request result: $theAnswer");

  //text = filterResponse(text);

  // save as last_response
  if (!explain) saveLastResponse(theAnswer);

  // save to db
  db.prompt = arguments.join(' ');
  db.response = theAnswer;
  db.save();

  printResponse(theAnswer);

  exit(0);
}
