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
import 'package:ht/AnsiColors.dart';
import 'package:ht/config.dart';

import 'package:http/http.dart' as http;

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
    "You're an assistant for using shell on $distro. You're given a shell command that you will analyse by conducting the following steps:\\n1. Check the command for syntax errors and if an error is found suggest the correct version.\\n2. Explain every argument used in only the last command followed by a newline.\\nGive short answers.";

String prePrompt =
    "$distro $os command to replace every IP address in file logfile with 192.168.0.1\n\nsed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile\n\n$distro $os command to mv file list1 to list2\n\nmv list1 list2\n$distro $os command to ";

String prePromptX =
    "Explain $os command ls -l -R\n\nls lists directory contents\n  -l lists in long format\n-  R lists subdirectories recursively.\n\nExplain $os command rm -rf\n\nrm removes files or directories\n  -r removes directories and their contents recursively\n  -f ignores nonexistent files and arguments, never prompts\n  / is the root directory\n\nExplain $os command";

//String prePromptX = "Explain $os command";

// String prePromptX = "";

final String stop = "Explain $os command";

// explain last response ───────────────────────────────────────────────────────
void explainLastResponse(String lastCommand) {
  //print("$acBold$lastCommand$acReset");

  prePromptX = prePromptX.replaceAll("\n", "\\n");

  String prompt = "$prePromptX $lastCommand";

  // replace " with \" in prompt
  prompt = prompt.replaceAll('"', '\\"');

  dbg("prompt: $prompt");
  String explanation =
      requestGPT(model, systemRoleX, prompt, temp, 512, "").toString();

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
      requestGPT(model, systemRoleX, prompt, temp, 512, "").toString();

  //explanation = filterResponse(explanation);

  printResponse(explanation);

  // write to db
  db.prompt = command;
  db.response = explanation;
  db.save();

  exit(0);
}

Future requestGPT(String model, String role, String prompt, String temperature,
    int maxTokens, String stop) async {
  String roleJSON = jsonEncode(role);
  String promptJSON = jsonEncode(prompt);

  dbg("roleJSON: $roleJSON");
  dbg("promptJSON: $promptJSON");

  var response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': role},
        {'role': 'user', 'content': promptJSON}
      ],
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': false
    }),
  );

  dbg("response.body: ${response.body}");

  calculateCost(response.body);

  Map<String, dynamic> responseBody = jsonDecode(response.body);

  // check json response for errors
  if (responseBody.containsKey('error')) {
    throw Exception(responseBody['error']);
  }

  String? text = responseBody['choices'][0]['text'];

  if (text == null) {
    return null;
  }

  return text.trim();
}
/* String? requestGPT(String model, String role, String prompt, String temperature,
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
    '{"model": "$model", "messages": [{"role": "system", "content" : "$role"}, {"role": "user", "content": $promptJSON}], "temperature": $temperature, "max_tokens": 512, "stream": false}'
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
} */

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
        lines[i].contains("not a valid command")) {
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

  // send uname to checkDistro function
  distro = checkDistro(uname) ?? "Debian derivate";
  dbg("distro: $distro");

  shell = Platform.environment['SHELL']!;
  // trim shell to the last part after the last /
  shell = shell.substring(shell.lastIndexOf('/') + 1);
  dbg("shell: $shell");
}

// execute command ─────────────────────────────────────────────────────────────
void executeCommand(String command) async {
  // not implemented yet
}

// main ────────────────────────────────────────────────────────────────────────
main(List<String> arguments) async {
  gatherSystemInfo();

  var config = Config();
  config.checkConfig();

  debug = config.readDebug() ?? false;

  apiKey = config.readApiKey();

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
    print("$acBold  ht explain|x$acReset            - explains last answer");
    print("$acBold  ht explain|x [command]$acReset  - explains command\n");
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

  if (arguments[0] == 'x' || arguments[0] == 'explain') {
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

  // if the first argument is explain or x, we will explain the last response
  if ((arguments[0] == 'explain' || arguments[0] == 'x')) {
    explain = true;
    // if there is more than 1 argument
    if (arguments.length > 1) {
      // if the second argument is last
      // String joining all arguments except arguments[0]
      var command = arguments.sublist(1).join(' ');
      explainCommand(command);
    } else {
      print("${acItalic}Usage:$acReset ht explain|x [command]");
      exit(1);
    }
  }

  // if the first argument is e or execute, we will execute the last response
  if ((arguments[0] == 'e') || (arguments[0] == 'execute')) {
    // run only if there is one argument
    if (arguments.length == 1) {
      // check if file ~/.config/ht/last_response exists
      var lastResponseFile =
          File('${Platform.environment['HOME']}/.config/ht/last_response');
      if (lastResponseFile.existsSync()) {
        // read last command
        String lastCommand = lastResponseFile.readAsStringSync();
        dbg('last command: $lastCommand');
        print("${acBold}executing $lastCommand$acReset");
        // ask user if he wants to execute last command
        stdout.write(
            "${acBold}Are you sure you want to execute this command? (y/N): $acReset");
        var answer = stdin.readLineSync();
        if (answer != "y") {
          print("Exiting...");
          exit(0);
        }
        // execute last command and wait until it's finished
        executeCommand(lastCommand);

        // not working yet
        exit(0);
      }
    }
  }

  // takes all arguments and joins them with spaces as a single string named prompt
  prePrompt = prePrompt.replaceAll("\n", "\\n");
  String prompt = prePrompt + arguments.join(' ');

  dbg("prompt: $prompt");

  var text = requestGPT(model, systemRole, prompt, temp, 512, stop).toString();
  dbg("request result: $text");

  //text = filterResponse(text);

  // save as last_response
  if (!explain) saveLastResponse(text);

  // save to db
  db.prompt = arguments.join(' ');
  db.response = text;
  db.save();

  printResponse(text);

  exit(0);
}
