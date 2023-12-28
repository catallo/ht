import 'package:ht/globals.dart';

String promptInstSystem =
    "You're an assistant for using $shell shell on $distro. You always answer with only the command IN ONE LINE without any further explanation! If you really and under no circumstances can't answer with a command, explain why but start with '🤖 ...'";

String promptInstUser1 =
    "$distro $os command to replace every IP address in file logfile with 192.168.0.1";

String promptInstAssistant1 =
    "sed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile";

String promptInstUser2 = "$distro $os command to remove /";

String promptInstAssistant2 = "sudo rm -rf /";

String promptInstUser = "$distro $os command to ";
