import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:ht/ansi_codes.dart';

import 'globals.dart';
import 'prompts_instruct.dart';
import 'cache.dart';
import 'debug.dart';
import 'unescape_json_string.dart';

void requestOllamaChat(String prompt) async {
  dbg("requestOllamaChat started");
  stdout.write("\n ");

  String completeResponse = "";
  String accumulatedChunk = "";

  var httpClient = HttpClient();
  var request =
      await httpClient.postUrl(Uri.parse('http://localhost:11434/api/chat'));

  request.headers.set('Content-Type', 'application/json');

  var requestBody = jsonEncode({
    'model': 'mistral-openorca',
    'messages': [
      {'role': 'system', 'content': promptInstSystem},
      {'role': 'user', 'content': promptInstUser1},
      {'role': 'assistant', 'content': promptInstAssistant1},
      {'role': 'user', 'content': promptInstUser2},
      {'role': 'assistant', 'content': promptInstAssistant2},
      {'role': 'user', 'content': "$promptInstUser$prompt"}
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
        stdout.write(content);
        completeResponse += content;
      }

      if (jsonResponse['done']) {
        dbg("\nresponse complete");
        done(prompt, completeResponse);
        subscription?.cancel(); // Cancel the subscription
        dbg("subscription cancelled");
        // stop http request
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
  print("\n");

  // Check if the last response is a valid command
  if (!completeResponse.contains("🤖")) {
    File file = File("${htPath}last_response");
    file.writeAsStringSync(completeResponse);
    Process.runSync('chmod', ['+x', "${htPath}last_response"]);
    dbg("chmod +x ${htPath}last_response");
    Cache(prompt, completeResponse).save();
    exit(0);
  } else {
    if (File("${htPath}last_response").existsSync()) {
      File file = File("${htPath}last_response");
      file.deleteSync();
    }

    Cache(prompt, completeResponse).save();
    exit(1);
  }
}
