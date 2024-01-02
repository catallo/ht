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
import 'package:ht/config.dart';

void initialize() {
  dbg("initialize started");

  config.checkConfig();
  debug = config.readDebug() ?? false;
  openAIapiKey = config.readApiKey();
}

Future<bool> checkForLatestRelease() async {
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
  //dbg(wrapperScript);

  // install ───────────────────────────────────────────────────────────────────
  if (arguments.isNotEmpty &&
      (arguments[0] == '-i' || arguments[0] == '--install')) {
    checkInstallation();
    exit(0);
  }

  if (updateAvailable()) await downloadUpdate();

  checkForLatestRelease();

  initialize();

  if (openAIapiKey == null) {
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
      // save to last_response if valid command, delete last_response if not
      if (!cachedResponse.contains("🤖")) {
        try {
          dbg("saving to last_response");
          File lastResponse = File("${htPath}last_response");
          await lastResponse.writeAsString(cachedResponse);
          Process.runSync('chmod', ['+x', "${htPath}last_response"]);
        } catch (error) {
          print("Error saving file: $error");
        }
      } else {
        if (File("${htPath}last_response").existsSync()) {
          File file = File("${htPath}last_response");
          file.deleteSync();
        }
      }
      exit(0);
    }
    requestOpenAIinstruct(instruction);
    //requestOllamaChat(instruction);
  }
}
