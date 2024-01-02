import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:ht/ansi_codes.dart';

import 'globals.dart';
import 'prompts_instruct.dart';
import 'cache.dart';
import 'debug.dart';
import 'unescape_json_string.dart';
import 'ter_print.dart';

void requestOpenAIinstruct(String prompt) async {
  dbg("requestGPTinstruct started");
  stdout.write("\n ");

  String completeResponse = "";
  String accumulatedChunk = "";

  var baseURL = "https://api.openai.com/v1/chat/completions";
  // var baseURL = "http://localhost:4891/v1/chat/completions";
  //model = "Mistral Instruct";

  var httpClient = HttpClient();
  var request = await httpClient.postUrl(Uri.parse(baseURL));

  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Authorization', 'Bearer $openAIapiKey');

  var requestBody = jsonEncode({
    'model': model,
    'messages': [
      {'role': 'system', 'content': promptInstSystem},
      {'role': 'user', 'content': promptInstUser1},
      {'role': 'assistant', 'content': promptInstAssistant1},
      {'role': 'user', 'content': promptInstUser2},
      {'role': 'assistant', 'content': promptInstAssistant2},
      {'role': 'user', 'content': "$promptInstUser$prompt"}
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
        // Check for errors in response
        if (accumulatedChunk.contains('"error":')) {
          final errorResponse = jsonDecode(accumulatedChunk);
          final error = errorResponse['error'];

          print("🤖 An error occurred:\n");
          print("   Code: ${error['code']}");
          print("   Type: ${error['type']}\n");
          terPrint("$acItalic${error['message']}");

          // if message contains "API key"
          if (error['message'].contains("API")) {
            print(
                "\n${acReset}Use$acBold ht -set <APIKEY>$acReset to set your API key.\n");
          }

          subscription?.cancel();
          exit(1);
        }

        // extract content within delta object
        RegExp exp = RegExp(r'"delta":\{"content":"(.*?)"\}');
        var matches = exp.allMatches(accumulatedChunk);

        for (var match in matches) {
          var content = match.group(1);
          content = unescapeJsonString(content!);
          stdout.write(content);
          completeResponse += content;
        }

        // extract finish_reason
        RegExp reasonExp = RegExp(r'"finish_reason":"(.*?)"');
        var reasonMatches = reasonExp.allMatches(accumulatedChunk);
        // if the finish_reason is "stop", the response is complete
        for (var reasonMatch in reasonMatches) {
          var reason = reasonMatch.group(1);
          if (reason == "stop") {
            dbg("\nfinish_reason: $reason");
            done(prompt, completeResponse);
            subscription?.cancel();
            dbg("subscription cancelled");
            // stop http request
            httpClient.close();
            dbg("httpClient closed");
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
  print("\n");

  // Check if the last response is a valid command
  dbg("completeResponse: |$completeResponse|");
  if ((!completeResponse.contains("🤖")) &&
      (!completeResponse.trim().isEmpty)) {
    File file = File("${htPath}last_response");
    file.writeAsStringSync(completeResponse);
    Process.runSync('chmod', ['+x', "${htPath}last_response"]);
    dbg("chmod +x ${htPath}last_response");
    Cache(prompt, completeResponse).save();
    exit(0);
  } else {
    dbg("last_response is not a valid command");
    if (File("${htPath}last_response").existsSync()) {
      File file = File("${htPath}last_response");
      file.deleteSync();
    }
    exit(1);
  }
}
