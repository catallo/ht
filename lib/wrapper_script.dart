import 'globals.dart';

String wrapperScript = """#!/bin/sh
# ht v$version ($compileDate)

DOWNLOADS_FOLDER="\$(dirname "\$0")/download"
DESTINATION_FILE="\$(dirname "\$0")/ht.bin"

# check for updated version
if [ -f "\$DOWNLOADS_FOLDER"/ht_* ]; then

    mv "\$DOWNLOADS_FOLDER"/ht_* "\$DESTINATION_FILE"
    rm -rf "\$DOWNLOADS_FOLDER"/*
fi

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
