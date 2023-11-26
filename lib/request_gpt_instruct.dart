import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:ht/cache.dart';

import 'package:ht/globals.dart';
import 'package:ht/prompts_instruct.dart';

void requestGPTinstruct(String prompt) {
  String completeResponse = "";

  OpenAI.apiKey = apiKey ?? exit(1);

  Stream<OpenAIStreamChatCompletionModel> chatStream =
      OpenAI.instance.chat.createStream(
    model: model,
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: promptInstSystem,
        role: OpenAIChatMessageRole.system,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptInstUser1,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptInstAssistant1,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptInstUser2,
        role: OpenAIChatMessageRole.user,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: promptInstAssistant2,
        role: OpenAIChatMessageRole.assistant,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content: jsonEncode("$promptInstUser$prompt"),
        role: OpenAIChatMessageRole.user,
      )
    ],
    temperature: temp,
  );

  stdout.write("\n ");

  chatStream.listen(
      (streamChatCompletion) {
        String? content = streamChatCompletion.choices.first.delta.content;

        stdout.write(content);
        completeResponse += content;
      },
      onError: (error) {
        print(error);
        exit(1);
      },
      cancelOnError: false,
      onDone: () {
        print("\n");

        // if last_response wasn't a command
        if (!completeResponse.contains("😞")) {
          // write to last_response
          File file = File("${htPath}last_response");
          file.writeAsString(completeResponse);
          Cache(prompt, completeResponse).save();
        } else {
          exit(1);
        }
      });
}
