// ht (for 'how-to') - an assistant that answers your questions about shell commands.
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

final db = DB("", "");

bool debug = false;
const version = "1.0.3"; // SemVer

final String os = Platform.operatingSystem;
String distro = "Debian derivate";
String uname = "-";
String shell = "";

final String model = "gpt-3.5-turbo";
final String temp = "0.0";

String? apiKey = "";

String systemRole =
    "You're an assistant for using shell on $distro. You always answer with only the command without any further explanation!";

String systemRoleX =
    "You're an assistant for using shell on $distro. Give short answers.";

String prePrompt =
    "$distro $os command to replace every IP address in file logfile with 192.168.0.1\n\nsed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile\n\n$distro $os command to mv file list1 to list2\n\nmv list1 list2\n$distro $os command to ";

String prePromptX =
    "Explain $os command ls -l -R\n\nls lists directory contents\n-l lists in long format\n-R lists subdirectories recursively.\n\nExplain $os command rm -rf\n\nrm removes files or directories\n-r removes directories and their contents recursively\n-f ignores nonexistent files and arguments, never prompts\n/ is the root directory\n\nExplain $os command";

// String prePromptX = "";

final String stop = "Explain $os command";

// function explain last response
void explainLastResponse(String lastCommand) {
  //print("$acBold$lastCommand$acReset");

  prePromptX = prePromptX.replaceAll("\n", "\\n");

  String prompt = "$prePromptX $lastCommand";

  // replace " with \" in prompt
  prompt = prompt.replaceAll('"', '\\"');

  dbg("prompt: $prompt");
  String explanation =
      requestGPT(model, systemRoleX, prompt, temp, 512, stop).toString();

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

// function to explain command
void explainCommand(var command) {
  prePromptX = prePromptX.replaceAll("\n", "\\n");
  String prompt = "$prePromptX " + command;

  var explanation =
      requestGPT(model, systemRoleX, prompt, temp, 512, stop).toString();

  //explanation = filterResponse(explanation);

  printResponse(explanation);

  // write to db
  db.prompt = command;
  db.response = explanation;
  db.save();

  exit(0);
}

// request to OpenAI API
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
    // add role system to prompt
    //

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
}

// function filterResponse
String filterResponse(String text) {
  text = text.replaceAll("\n\n", "\n");
  text = text.replaceAll("\\n\\n", "\n");

  text = text.replaceAll("\\n", "\n");
  text = text.replaceAll('\\"', '"');

  text = text.replaceAll("```", "");
  text = text.replaceAll("So, ", "$acItalic\nSo, ");
  text = text.replaceAll("Note: ", "$acItalic\nNote: ");
  text = text.replaceAll("Remember, ", "$acItalic\nRemember, ");
  text = text.replaceAll("Overall, ", "$acItalic\nRemember, ");

  dbg("filtered text: $text");
  return text;
}

// function to print response
void printResponse(String text) {
  //text = text.replaceAll("\n", "\n  ");
  //text = text.replaceAll("\\n", "\n  ");
  text = text.replaceAll(RegExp(r'\\?\n'), '\n');

  text = filterResponse(text);

  print('\n$acCyan$text$acReset\n');
}

// function write last response to file
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

// debug function
void dbg(String text) {
  if (!debug) return;
  print("\x1B[34mdbg:\x1B[0m \x1B[33m$text\x1B[0m");
}

// calculate costs
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

// function gather information about the system
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

main(List<String> arguments) async {
  gatherSystemInfo();

  var config = Config();
  config.checkConfig();

  debug = config.readDebug() ?? false;

  apiKey = config.readApiKey();

  if (apiKey == null) {
    print(
        "To use this application, you need to set an API key. You can obtain an API key by signing up at https://platform.openai.com/signup.");
    print(
        "For a more detailed guide on how to get an OpenAI API key, you can refer to this article: https://www.howtogeek.com/885918/how-to-get-an-openai-api-key/.");
    print(
        "Please note that using OpenAI's API with ht is rather budget-friendly. OpenAI provides \$5 for free to get you started,");
    print(
        "and each request typically consumes only a few tokens. For example, with \$1, you can make approximately 500 requests.");
    stdout.write("\nEnter your API key (or press enter to exit): ");

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
        "\n$acItalic${acBold}ht (for how-to)$acReset,$acItalic an assistant that answers your questions about shell commands.");
    print(
        "$acReset$acGrey                                                 https://github.com/catallo/ht$acReset");
    print("$acItalic  Usage$acReset:");
    print("$acBold  ht <question>$acReset           - answers question");
    print("$acBold  ht explain|x$acReset            - explains last answer");
    print("$acBold  ht explain|x [command]$acReset  - explains command");
    print("$acItalic\nExamples:$acReset");
    print("ht find all IPv4 addresses in log file and write to new file");
    print("ht explain");
    print("ht explain ls -lS");
    print('ht explain "ps -aux | grep nvidia"');

    exit(0);
  }

  // if arguments starts with -d or --debug, set debug to true for this session
  if ((arguments[0] == '-d') || (arguments[0] == '--debug')) {
    debug = true;
    arguments = arguments.sublist(1);
  }

  // if arguments is -s or --settings, print settings
  if ((arguments[0] == '-s') || (arguments[0] == '--settings')) {
    print("\n  model:  $model");
    print("apikey: $apiKey");
    print("debug:  $debug");
    print(
        "\n$acItalic  Use 'ht -set <setting> <value>' to change setting (or edit ~/.config/ht/config).");
    print("example: ht -set apikey 123456");
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
        "\n$acItalic$acBold  ht$acReset$acItalic v$version, https://github.com/catallo/ht $acReset\n");
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
    saveLastResponse(response);
    exit(0);
  }

  // last response ─────────────────────────────────────────────────────────────

  // if the first argument is explain or x, we will explain the last response
  if ((arguments[0] == 'explain' || arguments[0] == 'x')) {
    // if there is more than 1 argument
    if (arguments.length > 1) {
      explain = true;
      // if the second argument is last
      // String joining all arguments except arguments[0]
      var command = arguments.sublist(1).join(' ');
      explainCommand(command);
    } else {
      print("${acItalic}Usage:$acReset ht explain|x [command]");
      exit(1);
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
  if (explain == false) saveLastResponse(text);

  // save to db
  db.prompt = arguments.join(' ');
  db.response = text;
  db.save();

  printResponse(text);

  exit(0);
}
