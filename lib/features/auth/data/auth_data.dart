import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/auth_domain.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'height': 0,
      'weight': 0,
      'age': 0,
      'gender': '',
      'goal': '',
      'isOnboardingComplete': false,
    };
  }
}

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> logout();
  User? getCurrentUser();
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);

  // NEW METHODS
  Future<void> resetPassword(String email);
  Future<void> updateUsername(String uid, String newName);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebase(result.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(e.message ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel.fromFirebase(result.user!);

      await firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toDocument());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw const ServerFailure("Failed to update profile");
    }
  }

  // NEW: Password Reset
  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(e.message ?? "Failed to send reset email");
    }
  }

  // NEW: Update Username
  @override
  Future<void> updateUsername(String uid, String newName) async {
    try {
      // 1. Update in Firebase Auth (Display Name)
      await firebaseAuth.currentUser?.updateDisplayName(newName);

      // 2. Update in Firestore
      await firestore
          .collection('users')
          .doc(uid)
          .update({'displayName': newName});
    } catch (e) {
      throw const ServerFailure("Failed to update username");
    }
  }
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(
      String email, String password) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      return Right(user);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = remoteDataSource.getCurrentUser();
    if (user != null) {
      return UserModel.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
      String uid, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateUserProfile(uid, data);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  // NEW
  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  // NEW
  @override
  Future<Either<Failure, void>> updateUsername(
      String uid, String newName) async {
    try {
      await remoteDataSource.updateUsername(uid, newName);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
