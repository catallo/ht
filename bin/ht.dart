// ht (for 'how-to')
//          - a shell command that answers your questions about shell commands.
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
import 'package:compute/compute.dart';

import 'package:ht/cache.dart';
import 'package:ht/ansi_codes.dart';
import 'package:ht/globals.dart';
import 'package:ht/request_openai_instruct.dart';
import 'package:ht/arguments.dart';
import 'package:ht/system_information.dart';
import 'package:ht/ter_print.dart';
import 'package:ht/debug.dart';
import 'package:ht/get_latest_version.dart';
import 'package:ht/installation_and_update.dart';
import 'package:ht/wrapper_script.dart';

import 'package:ht/request_ollama_instruct.dart';

void setupApiKey() {
  terPrint(
      "\n\nWelcome to ht. To use this application, you need to set an OpenAI API key.");
  print("");
  terPrint(
      "The good news is that due to ht's low token usage, a typical request costs about \$0.00025, making it a budget-friendly tool for daily usage. You can obtain an API key by signing up at https://platform.openai.com/signup. For a more detailed guide on how to get an OpenAI API key, you can refer to this article: https://www.howtogeek.com/885918/how-to-get-an-openai-api-key/.");
  stdout.write(
      "\n${acBold}Paste your OpenAI API key here (or press enter to exit):$acReset ");
  apiKey = stdin.readLineSync();
  if (apiKey!.isEmpty) {
    print("Exiting...");
    exit(1);
  }
  config.setApiKey(apiKey!);
  print("API key set.");
  exit(0);
}

void initialize() {
  config.checkConfig();
  debug = config.readDebug() ?? false;
  apiKey = config.readApiKey();
}

Future<bool> checkLatestRelease() async {
  // Wrap the call in another function that takes a dummy argument
  bool result = await compute(wrapperLatestVersionCheck, null);
  return result;
}

bool updateAvailable() {
  if (File("${htPath}update_available").existsSync()) {
    return true;
  }
  return false;
}

void main(List<String> arguments) async {
  dbg("ht started");

  dbg(wrapperScript);

  // install ───────────────────────────────────────────────────────────────────
  if (arguments.isNotEmpty &&
      (arguments[0] == '-i' || arguments[0] == '--install')) {
    checkInstallation();
    exit(0);
  }

  if (updateAvailable()) await downloadUpdate();

  checkLatestRelease();

  initialize();

  if (apiKey == null) {
    setupApiKey();
  }

  gatherSystemInfo();

  if (await parseArguments(arguments)) {
    String instruction = arguments.join(' ');
    // search if exists in cache
    dbg("searching in cache");
    Cache cache = Cache(instruction, "");
    String? cachedResponse = cache.search();
    if (cachedResponse != null) {
      dbg("found in cache");
      print("\n $cachedResponse\n");
      // save to last_response
      try {
        dbg("saving to last_response");
        File lastResponse = File("${htPath}last_response");
        await lastResponse.writeAsString(cachedResponse);
      } catch (error) {
        print("Error saving file: $error");
      }
      exit(0);
    }
    requestOpenAIinstruct(instruction);
    //requestOllamaChat(instruction);
  }
}
