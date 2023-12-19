import 'dart:io';
import 'package:ht/config.dart';

bool debug = false;

const version = "2.3.2";
const compileDate = "2023-12-19";

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

String htPath = "$home/.config/ht/";
