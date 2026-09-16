import 'package:fullstack_app/features/albums/domain/entities/album.dart';

class AlbumModel extends Album {
  const AlbumModel({required super.id, required super.userId, required super.title});

  factory AlbumModel.fromJson(Map<String, dynamic> json) => AlbumModel(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'title': title};
}
