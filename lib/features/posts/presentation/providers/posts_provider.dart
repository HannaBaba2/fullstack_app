import 'package:flutter/foundation.dart';
import 'package:fullstack_app/features/posts/domain/entities/post.dart';
import 'package:fullstack_app/features/posts/domain/usecases/get_posts_usecase.dart';

class PostsProvider extends ChangeNotifier {
  final GetPostsUseCase getPostsUseCase;
  PostsProvider(this.getPostsUseCase);

  List<Post> posts = [];
  bool isLoading = false;
  bool isFromCache = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await getPostsUseCase();
    isLoading = false;

    result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
      },
      (dataWithSource) {
        posts = dataWithSource.data;
        isFromCache = dataWithSource.isFromCache;
        notifyListeners();
      },
    );
  }
}
