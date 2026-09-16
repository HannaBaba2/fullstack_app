import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final int id;
  final int userId;
  final String title;

  const Album({required this.id, required this.userId, required this.title});

  @override
  List<Object?> get props => [id, userId, title];
}
