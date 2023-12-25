import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'globals.dart';
import 'prompts_explain.dart';
import 'ansi_codes.dart';
import 'cache.dart';
import 'debug.dart';
import 'unescape_json_string.dart';
import 'ter_print.dart';

void requestOllamaExplain(String prompt) async {
  dbg("requestOllamaExplain started");
  print("\n $acBold$prompt$acReset\n");

  String completeResponse = "";
  String currentLine = "";

  var httpClient = HttpClient();
  var request =
      await httpClient.postUrl(Uri.parse('http://localhost:11434/api/chat'));

  request.headers.set('Content-Type', 'application/json');

  var requestBody = jsonEncode({
    'model': 'starcoder',
    'messages': [
      {'role': 'system', 'content': promptExSystemRole},
      {'role': 'user', 'content': promptExUser1},
      {'role': 'assistant', 'content': promptExAssistant1},
      {'role': 'user', 'content': promptExUser2},
      {'role': 'assistant', 'content': promptExAssistant2},
      {'role': 'user', 'content': promptExUser3},
      {'role': 'assistant', 'content': promptExAssistant3},
      {'role': 'user', 'content': promptExUser4},
      {'role': 'assistant', 'content': promptExAssistant4},
      {'role': 'user', 'content': promptExUser5},
      {'role': 'assistant', 'content': promptExAssistant5},
      {'role': 'user', 'content': promptExUser + prompt}
    ],
    'stream': true,
    'options': {
      'temperature': temp,
      'num_thread': 4,
      'num_keep': 0,
    }
  });

  request.add(utf8.encode(requestBody));

  var response = await request.close();

  StreamSubscription<String>? subscription;

  subscription = response.transform(utf8.decoder).listen(
    (chunk) {
      dbg("chunk: $chunk");

      var jsonResponse = jsonDecode(chunk);
      if (jsonResponse.containsKey('message')) {
        var content = jsonResponse['message']['content'];
        currentLine += content;

        if (currentLine.endsWith('\n')) {
          dbg("currentLine: $currentLine");
          terPrint(currentLine);
          currentLine = "";
        }

        completeResponse += content;
      }

      if (jsonResponse['done']) {
        dbg("\nresponse complete");
        terPrint(currentLine);
        done(prompt, completeResponse);
        subscription?.cancel();
        dbg("subscription cancelled");
        httpClient.close();
        dbg("httpClient closed");
        return;
      }
    },
    onError: (error) {
      print(error);
      subscription?.cancel();
      exit(1);
    },
    onDone: () {
      done(prompt, completeResponse);
    },
    cancelOnError: true,
  );
}

void done(var prompt, var completeResponse) {
  Cache(prompt, completeResponse).save();
  exit(0);
}
