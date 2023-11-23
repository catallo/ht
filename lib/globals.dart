import 'dart:io';
import 'package:ht/config.dart';

bool debug = false;

const version = "2.0.0"; // SemVer
const compileDate = "2023-11-22";

String os = "Linux";
String distro = "Debian derivate";
String uname = "-";
String shell = "";

final String model = "gpt-3.5-turbo";
final double temp = 0.0;

String? apiKey = "";

String line = "";

var config = Config();

String home = Platform.environment['HOME'] ?? "";