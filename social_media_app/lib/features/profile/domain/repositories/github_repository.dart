import 'package:social_media_app/core/error/failure.dart';

abstract class GithubRepository {
  Future<List<dynamic>> fetchTopRepos(String username);
}
