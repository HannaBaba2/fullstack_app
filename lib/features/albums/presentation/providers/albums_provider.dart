import 'package:flutter/foundation.dart';
import 'package:fullstack_app/features/albums/domain/entities/album.dart';
import 'package:fullstack_app/features/albums/domain/usecases/get_albums_usecase.dart';

class AlbumsProvider extends ChangeNotifier {
  final GetAlbumsUseCase getAlbumsUseCase;
  AlbumsProvider(this.getAlbumsUseCase);

  List<Album> albums = [];
  bool isLoading = false;
  bool isFromCache = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await getAlbumsUseCase();
    isLoading = false;

    result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
      },
      (dataWithSource) {
        albums = dataWithSource.data;
        isFromCache = dataWithSource.isFromCache;
        notifyListeners();
      },
    );
  }
}
