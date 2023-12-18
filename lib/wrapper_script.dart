import 'globals.dart';

String wrapperScript = """#!/bin/sh
# ht $version

if [ "\$1" = "x" ] || [ "\$1" = "execute" ]; then
    ./last_response
else
    ht.bin "\$@"
fi
""";
