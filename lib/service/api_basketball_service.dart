import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class ApiBasketballService {
  final String _baseUrl = 'https://v1.basketball.api-sports.io/';
  final String _token = '971aa846ce98df069384f28378939647';
  // id nba = 12;

  Future<List<dynamic>> getTeamsNBA({int leagueId = 12, String? season, String? search}) async {
    final params = <String, String>{'league': leagueId.toString()};
    if (season != null) params['season'] = season;

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final uri = Uri.parse('$_baseUrl/teams').replace(
      queryParameters: params,
    );
    
    //print('C$uri'); 

    final headers = {
      'x-rapidapi-key': _token,
      'x-rapidapi-host': 'v1.basketball.api-sports.io',
      'Accept': 'application/json',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw ApiException('Erro: ${response.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
    if (!body.containsKey('response')) {
      throw ApiException('Formato inesperado');
    }

    return body['response'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getTeamStatistics({required int teamId, required String season}) async {
    final params = {
      'league': '12', 
      'season': season,
      'team': teamId.toString(),
    };

    final uri = Uri.parse('$_baseUrl/statistics').replace(queryParameters: params);

    final headers = {
      'x-rapidapi-key': _token, 
      'x-rapidapi-host': 'v1.basketball.api-sports.io',
      'Accept': 'application/json',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw ApiException('Erro ao buscar estatísticas: ${response.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(response.body);
    return body['response'] as Map<String, dynamic>;
  }
}
