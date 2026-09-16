import 'package:hive_flutter/hive_flutter.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/posts/data/models/post_model.dart';

abstract class PostsLocalDataSource {
  Future<void> cachePosts(List<PostModel> posts);
  Future<List<PostModel>> getCachedPosts();
}

class PostsLocalDataSourceImpl implements PostsLocalDataSource {
  static const String boxName = 'posts_cache_box';
  static const String _key = 'posts';

  Box get _box => Hive.box(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    final raw = posts.map((p) => p.toJson()).toList();
    await _box.put(_key, raw);
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    final raw = _box.get(_key);
    if (raw == null) throw CacheException('Aucune donnee en cache pour les posts.');
    final list = List<Map>.from(raw as List);
    return list
        .map((e) => PostModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
