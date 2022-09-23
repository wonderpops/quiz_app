import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class QuizAPIClient {
  final String _apiKey = 'j24WhINsXuMG7PszLmbkLHqRiXRoFnjRZrHxkwDa';
  final _client = http.Client();
  final String _host = 'https://quizapi.io/api/v1';
  final int _limit = 10;

  Future<List> getQuestions(String category, String difficulty) async {
    final url = Uri.parse(
        '$_host/questions?apiKey=$_apiKey&limit=$_limit&category=$category&difficulty=$difficulty');
    final response =
        await _client.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body) as List;
      // inspect(json);
      return json;
    } else {
      throw Exception('Error when loading questions');
    }
  }
}
