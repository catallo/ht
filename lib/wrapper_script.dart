import 'globals.dart';

String wrapperScript = """#!/bin/sh
# ht v$version ($compileDate)

if [ "\$1" = "x" ] || [ "\$1" = "execute" ]; then
    if [ -f ./last_response ]; then
        last_response
    else
        echo "\n 🤖 My previous answer wasn't a valid command. Please generate a new command.\n"
    fi
else
    ht.bin "\$@"
fi
""";
