import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

// 1. ENTITY
class UserEntity {
  final String uid;
  final String email;
  final String? displayName;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
  });

  String? get photoURL => null;
}

// 2. REPOSITORY INTERFACE
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<Either<Failure, void>> updateUserProfile(
      String uid, Map<String, dynamic> data);

  // NEW METHODS
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> updateUsername(String uid, String newName);
}

// 3. USECASES
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<Either<Failure, UserEntity>> call(String email, String password) =>
      repository.login(email, password);
}

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);
  Future<Either<Failure, UserEntity>> call(String email, String password) =>
      repository.signUp(email, password);
}

class UpdateUserUseCase {
  final AuthRepository repository;
  UpdateUserUseCase(this.repository);
  Future<Either<Failure, void>> call(String uid, Map<String, dynamic> data) =>
      repository.updateUserProfile(uid, data);
}

// NEW USE CASES
class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);
  Future<Either<Failure, void>> call(String email) =>
      repository.resetPassword(email);
}

class UpdateUsernameUseCase {
  final AuthRepository repository;
  UpdateUsernameUseCase(this.repository);
  Future<Either<Failure, void>> call(String uid, String newName) =>
      repository.updateUsername(uid, newName);
}
