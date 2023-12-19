import 'dart:convert';
import 'package:http/http.dart' as http;

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

void checkForLatestVersion() async {
  try {
    var latestVersion = await getLatestReleaseVersion();
    print('Latest Release Version: $latestVersion');
  } catch (e) {
    print(e);
  }
}
