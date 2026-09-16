import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/albums/domain/entities/album.dart';
import 'package:fullstack_app/features/albums/domain/repositories/albums_repository.dart';

class GetAlbumsUseCase {
  final AlbumsRepository repository;
  GetAlbumsUseCase(this.repository);

  Future<Result<DataWithSource<List<Album>>>> call() => repository.getAlbums();
}
