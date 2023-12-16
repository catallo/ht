import 'dart:convert';
import 'dart:io';

import 'package:ht/globals.dart';
import 'package:ht/prompts_instruct.dart';
import 'package:ht/cache.dart'; // Make sure to import your Cache class

void requestGPTinstruct(String prompt) async {
  String completeResponse = "";
  String accumulatedChunk = "";

  var httpClient = HttpClient();
  var request = await httpClient
      .postUrl(Uri.parse('https://api.openai.com/v1/chat/completions'));

  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Authorization', 'Bearer $apiKey');

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
    'stream': true, // Enable streamed response
  });

  request.add(utf8.encode(requestBody));

  var response = await request.close();

  response.transform(utf8.decoder).listen(
    (chunk) {
      accumulatedChunk += chunk;

      if (chunk.endsWith('\n')) {
        // Use RegExp to extract content within delta object
        RegExp exp = RegExp(r'"delta":\{"content":"(.*?)"\}');
        var matches = exp.allMatches(accumulatedChunk);

        for (var match in matches) {
          var content = match.group(1);
          content = content!.replaceAll("\\n", "\n");
          stdout.write(content);
          completeResponse += content;
        }

        accumulatedChunk = ""; // Reset for the next chunk
      }
    },
    onError: (error) {
      print(error);
      exit(1);
    },
    onDone: () {
      print("\n");

      // Check if the last response is a command (contains "🤖")
      if (!completeResponse.contains("🤖")) {
        File file = File("${htPath}last_response");
        file.writeAsString(completeResponse);
        Cache(prompt, completeResponse).save();
      } else {
        Cache(prompt, completeResponse).save();
        exit(1);
      }
    },
    cancelOnError: true,
  );
}
