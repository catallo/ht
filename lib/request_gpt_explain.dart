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

void requestGPTexplain(String prompt) async {
  dbg("requestGPTexplain started");
  print("\n $acBold$prompt$acReset\n");

  String completeResponse = "";
  String accumulatedChunk = "";
  String currentLine = "";

  var httpClient = HttpClient();
  var request = await httpClient
      .postUrl(Uri.parse('https://api.openai.com/v1/chat/completions'));

  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Authorization', 'Bearer $apiKey');

  var requestBody = jsonEncode({
    'model': model,
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
    'temperature': temp,
    'stream': true,
  });

  request.add(utf8.encode(requestBody));

  var response = await request.close();

  StreamSubscription<String>? subscription;

  subscription = response.transform(utf8.decoder).listen(
    (chunk) {
      dbg("chunk: $chunk");
      accumulatedChunk += chunk;

      if (chunk.endsWith('\n')) {
        RegExp exp = RegExp(r'"delta":\{"content":"(.*?)"\}');
        var matches = exp.allMatches(accumulatedChunk);

        for (var match in matches) {
          var content = match.group(1);
          content = unescapeJsonString(content!);
          currentLine += content;

          if (currentLine.endsWith('\n')) {
            dbg("currentLine: $currentLine");
            terPrint(currentLine);
            currentLine = "";
          }

          completeResponse += content;
        }

        RegExp reasonExp = RegExp(r'"finish_reason":"(.*?)"');
        var reasonMatches = reasonExp.allMatches(accumulatedChunk);
        for (var reasonMatch in reasonMatches) {
          var reason = reasonMatch.group(1);
          if (reason == "stop") {
            dbg("\nfinish_reason: $reason");
            terPrint(currentLine);
            done(prompt, completeResponse);
            subscription?.cancel();
            return;
          }
        }

        accumulatedChunk = "";
        dbg("next chunk");
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
  //print("\n");

  Cache(prompt, completeResponse).save();
  exit(0);
}
