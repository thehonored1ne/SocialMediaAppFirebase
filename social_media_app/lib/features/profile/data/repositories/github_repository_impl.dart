import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/github_repository.dart';

part 'github_repository_impl.g.dart';

class GithubRepositoryImpl implements GithubRepository {
  final http.Client _client;

  GithubRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<dynamic>> fetchTopRepos(String username) async {
    final url = Uri.parse('https://api.github.com/users/$username/repos?sort=stars&per_page=5');
    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch GitHub repos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching GitHub repos: $e');
    }
  }
}

@riverpod
GithubRepository githubRepository(Ref ref) {
  return GithubRepositoryImpl();
}
