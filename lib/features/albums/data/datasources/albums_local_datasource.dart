import 'package:hive_flutter/hive_flutter.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/albums/data/models/album_model.dart';

abstract class AlbumsLocalDataSource {
  Future<void> cacheAlbums(List<AlbumModel> albums);
  Future<List<AlbumModel>> getCachedAlbums();
}

class AlbumsLocalDataSourceImpl implements AlbumsLocalDataSource {
  static const String boxName = 'albums_cache_box';
  static const String _key = 'albums';

  Box get _box => Hive.box(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  @override
  Future<void> cacheAlbums(List<AlbumModel> albums) async {
    final raw = albums.map((a) => a.toJson()).toList();
    await _box.put(_key, raw);
  }

  @override
  Future<List<AlbumModel>> getCachedAlbums() async {
    final raw = _box.get(_key);
    if (raw == null) throw CacheException('Aucune donnee en cache pour les albums.');
    final list = List<Map>.from(raw as List);
    return list.map((e) => AlbumModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
