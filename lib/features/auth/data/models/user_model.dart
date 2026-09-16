import 'package:fullstack_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  final String? refreshToken;

  const UserModel({
    required super.email,
    required super.token,
    this.refreshToken,
  });
}
