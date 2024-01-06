import 'dart:io';
import 'package:ht/config.dart';

bool debug = true;

const version = "2.3.11";
const compileDate = "2024-01-06";

String os = "Linux";
String distro = "Debian derivate";
String uname = "-";
String shell = "";

String model = "gpt-3.5-turbo";
final double temp = 0.0;

String? openAIapiKey = "notset";

String line = "";

var config = Config();

String home = Platform.environment['HOME'] ?? "";

String htPath = "$home/.config/ht/";
