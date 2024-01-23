import 'dart:convert';
import 'package:args/args.dart';
import 'package:http/http.dart' as http;

ArgParser buildListCommandParser() {
  return ArgParser()
    ..addOption('owner', defaultsTo: 'flutter', help: 'repository owner')
    ..addOption('repo', defaultsTo: 'flutter', help: 'repository name');
}

ArgParser buildParser() {
  var parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Print this usage information')
    ..addCommand('list', buildListCommandParser());
  return parser;
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    if (results.command?.name == 'list') {
      String owner = results.command?['owner'] ?? 'flutter';
      String repo = results.command?['repo'] ?? 'flutter';
      listReleases(owner, repo);
    }
  } on FormatException catch (e) {
    print('Failed with $e');
  }
}

Future<void> listReleases(String owner, String repo) async {
  final url = Uri.parse('https://api.github.com/repos/$owner/$repo/releases');

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> releases = jsonDecode(response.body);
      for (var release in releases) {
        print('Release: ${release['name']}, Tag: ${release['tag_name']}');
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
