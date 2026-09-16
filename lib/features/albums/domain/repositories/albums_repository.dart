import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/albums/domain/entities/album.dart';

abstract class AlbumsRepository {
  Future<Result<DataWithSource<List<Album>>>> getAlbums();
}
