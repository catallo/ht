import 'dart:io';
import 'package:dart_openai/dart_openai.dart';

import 'package:ht/globals.dart';
import 'package:ht/prompts_explain.dart';
import 'package:ht/ansi_codes.dart';

import 'package:ht/ter_print.dart';
import 'package:ht/cache.dart';

void requestGPTexplain(String prompt) {
  String completeResponse = "";

  OpenAI.apiKey = apiKey ?? exit(1);

  Stream<OpenAIStreamChatCompletionModel> chatStream =
      OpenAI.instance.chat.createStream(
    model: model,
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExSystemRole,
        role: OpenAIChatMessageRole.system,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExUser1,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExAssistant1,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExUser2,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExAssistant2,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExUser3,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExAssistant3,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExUser4,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExAssistant4,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExUser5,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptExAssistant5,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        //content: jsonEncode("$promptExUser$prompt"),
        content: promptExUser + prompt,
        role: OpenAIChatMessageRole.user,
      )
    ],
    temperature: temp,
  );

  // print full command
  print("\n$acBrightWhite$acBrightWhite"
      " $prompt $acReset\n");

  chatStream.listen(
      (streamChatCompletion) {
        String? content = streamChatCompletion.choices.first.delta.content;

        //stdout.write(acGrey + content + acReset); // debug

        line += content;
        completeResponse += content;
        // if line contains newline
        if (line.contains("\n")) {
          terPrint(line);
          line = "";
        }

        //sleep(Duration(milliseconds: 100));
      },
      onError: (error) {
        print(error);
      },
      cancelOnError: false,
      onDone: () {
        terPrint(line);
        // save to cache
        Cache(prompt, completeResponse).save();
        exit(0);
      });
  // get "usage" "prompt_tokens" of the response

  //print(completeOutput);
}
