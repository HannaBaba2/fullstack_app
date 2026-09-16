import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/posts/domain/entities/post.dart';

abstract class PostsRepository {
  /// Returns posts from the network when available, falls back to the
  /// local Hive cache when offline, and refreshes the cache on success.
  Future<Result<DataWithSource<List<Post>>>> getPosts();
}
