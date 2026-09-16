import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/posts/domain/entities/post.dart';
import 'package:fullstack_app/features/posts/domain/repositories/posts_repository.dart';

class GetPostsUseCase {
  final PostsRepository repository;
  GetPostsUseCase(this.repository);

  Future<Result<DataWithSource<List<Post>>>> call() => repository.getPosts();
}
