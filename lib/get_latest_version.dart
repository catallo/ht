import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'globals.dart';
import 'package:http/http.dart' as http;
import 'package:ht/installation_and_update.dart';
import 'package:ht/debug.dart';

Future<String> getLatestReleaseVersion() async {
  var url =
      Uri.parse('https://api.github.com/repos/catallo/ht/releases/latest');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse['tag_name']; // 'tag_name' usually contains the version
  } else {
    throw Exception('Failed to load latest release version');
  }
}

// Wrapper function that matches the expected signature for compute
Future<bool> wrapperLatestVersionCheck(void _) async {
  return await checkForLatestVersion();
}

Future<bool> checkForLatestVersion() async {
  var latestVersion = 'v0.0.0';
  try {
    latestVersion = await getLatestReleaseVersion();
    dbg('Latest Release Version: $latestVersion, this version: $version');
  } catch (e) {
    print(e);
  }
  if (latestVersion.startsWith('v')) latestVersion = latestVersion.substring(1);
  // use isSemVerHigher() from installation_and_update.dart
  if (isSemVerHigher(version, latestVersion)) {
    dbg('New version available');
    // write an empty file "update_available" to ~/.config/ht
    try {
      File("$htPath/update_available").createSync(recursive: false);
      // write the latest version to ~/.config/ht/update_available
      File("$htPath/update_available")
          .writeAsStringSync('$latestVersion\n', mode: FileMode.append);
    } catch (e) {
      print("Error creating update_available file: $e");
      return false;
    }
  } else {
    dbg('No new version available');
  }
  return true;
}

downloadUpdate() async {
  dbg('downloadUpdate started');

  print(" 🤖 There is an updated version available. Downloading ...");

  // if it doesn't exist, create ~/.config/ht/download
  if (!Directory("$htPath/download").existsSync()) {
    try {
      Directory("$htPath/download").createSync(recursive: false);
    } catch (e) {
      print("Error creating directory: $e");
      return false;
    }
  }

  // Identify the platform
  String platformKey =
      Platform.isLinux ? 'linux_x64' : (Platform.isMacOS ? 'MacOS_ARM64' : '');

  // Fetch the latest release data from GitHub
  var url =
      Uri.parse('https://api.github.com/repos/catallo/ht/releases/latest');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    var body = jsonResponse['body'];

    // Regular expression to find download links
    RegExp regExp = RegExp(
        r'\[ht_[^\]]*_' +
            platformKey.replaceAll('_', r'_') +
            r'\.zip\]\((https?[^\)]+)\)',
        caseSensitive: false);

    var matches = regExp.allMatches(body);
    if (matches.isNotEmpty) {
      var downloadUrl = matches.first.group(1);
      print('Download URL: $downloadUrl');

      // Download the file
      var client = HttpClient();
      var request = await client.getUrl(Uri.parse(downloadUrl!));
      var response = await request.close();

      // Read the response and write it to a file
      String fileName = path.basename(downloadUrl);
      String filePath = '$htPath/download/$fileName';
      var file = File(filePath);
      var fileSink = file.openWrite();
      await response.pipe(fileSink);
      fileSink.close();

      print('File downloaded to $filePath. Extracting ...');

      // Proceed to unzip the file
      await unzipFile(filePath);

      // Delete the downloaded zip
      file.deleteSync();
      // get file name of extracted file, it's the only file in the directory
      var extractedFileName = Directory("$htPath/download").listSync()[0].path;
      dbg("extractedFileName: $extractedFileName");
      // run the extracted file with -i to install
      var installOutput = Process.runSync(extractedFileName, ['-i']);
      dbg("Process.runSync finished");
      print(installOutput.stdout);
      // delete the extracted file
      //File(extractedFileName).deleteSync();
      // delete the update_available file
      //File("$htPath/update_available").deleteSync();
      exit(0);
    } else {
      print('No matching asset found for platform $platformKey');
    }
  } else {
    print('Failed to load latest release version');
  }

  exit(0);
}

Future<void> unzipFile(String filePath) async {
  var destinationPath = "$htPath/download";
  var result =
      await Process.run('unzip', ['-o', filePath, '-d', destinationPath]);

  if (result.exitCode != 0) {
    print('Error unzipping file: ${result.stderr}');
  } else {
    print('File unzipped to $destinationPath');
  }
}
