import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/auth_domain.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  requiresOnboarding
}

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdateUsernameUseCase updateUsernameUseCase;
  final AuthRepository authRepository;
  final SharedPreferences sharedPreferences;

  // ✅ NEW: Firebase Instances for direct access in completeRegistration
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthProvider({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.updateUserUseCase,
    required this.resetPasswordUseCase,
    required this.updateUsernameUseCase,
    required this.authRepository,
    required this.sharedPreferences,
  });

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  // Onboarding Data
  int _age = 25;
  String _gender = "Male";
  int _height = 170;
  int _weight = 70;
  String _goal = "Get fit";

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  int get age => _age;
  String get gender => _gender;
  int get height => _height;
  int get weight => _weight;
  String get goal => _goal;

  // --- SETTERS ---
  void setAge(int value) {
    _age = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setHeight(int value) {
    _height = value;
    notifyListeners();
  }

  void setWeight(int value) {
    _weight = value;
    notifyListeners();
  }

  void setGoal(String value) {
    _goal = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }

  // --- AUTH METHODS ---

  Future<void> checkAuthStatus() async {
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser != null) {
      _user = currentUser;
      _status = AuthStatus.authenticated;
      await loadUserData(); // Ensure data is loaded on app start
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    final result = await loginUseCase(email, password);
    result.fold(
          (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
          (user) async {
        _user = user;
        _errorMessage = null;
        _status = AuthStatus.authenticated;
        sharedPreferences.setBool('is_logged_in', true);
        await loadUserData();
        notifyListeners();
      },
    );
  }

  // Keep existing signUp for backwards compatibility or alternative flows
  Future<void> signUp(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    final result = await signUpUseCase(email, password);
    result.fold(
          (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
          (user) {
        _user = user;
        _errorMessage = null;
        _status = AuthStatus.requiresOnboarding;
        sharedPreferences.setBool('is_logged_in', true);
        notifyListeners();
      },
    );
  }

  // --- ✅ NEW: COMPLETE REGISTRATION (All in one go) ---
  Future<void> completeRegistration({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String goal,
  }) async {
    // 1. Use existing status system for consistency
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. Create Auth User (Firebase)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Save ALL Data to Firestore immediately
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'age': age,
        'gender': gender,
        'weight': weight, // Saving as double/int based on input
        'height': height,
        'goal': goal,
        'isOnboardingComplete': true, // Mark as complete immediately
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Update Local Data State immediately (So UI works instantly)
      _age = age;
      _gender = gender;
      _weight = weight.toInt();
      _height = height.toInt();
      _goal = goal;

      // 5. Convert Firebase User to Domain UserEntity
      // We ask the repository to fetch the standardized UserEntity for us
      _user = await authRepository.getCurrentUser();

      // 6. Finalize Success State
      _status = AuthStatus.authenticated;
      sharedPreferences.setBool('is_logged_in', true);

    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message ?? "Registration failed";
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = "An unexpected error occurred: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    sharedPreferences.setBool('is_logged_in', false);
    _status = AuthStatus.unauthenticated;
    _user = null;
    // Reset defaults
    _age = 25;
    _weight = 70;
    _height = 170;
    _gender = "Male";
    notifyListeners();
  }

  // Legacy method - kept if needed for partial updates
  Future<void> completeOnboarding() async {
    if (_user == null) return;
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await updateUserUseCase(
      _user!.uid,
      {
        'age': _age,
        'gender': _gender,
        'height': _height,
        'weight': _weight,
        'goal': _goal,
        'isOnboardingComplete': true,
      },
    );

    result.fold(
          (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
          (_) {
        _status = AuthStatus.authenticated;
        notifyListeners();
      },
    );
  }

  Future<void> loadUserData() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();

      if (!doc.exists) return;

      final data = doc.data()!;
      _age = data['age'] ?? _age;
      // Handle potential Double vs Int type issues from Firestore safely
      _weight = (data['weight'] as num?)?.toInt() ?? _weight;
      _height = (data['height'] as num?)?.toInt() ?? _height;
      _gender = data['gender'] ?? _gender;
      _goal = data['goal'] ?? _goal;

      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load user data: $e");
    }
  }

  Future<void> updateUserProfile(
      {required String name, required String weight}) async {
    if (_user == null) return;

    notifyListeners();

    try {
      // 1. Update Name
      final nameResult = await updateUsernameUseCase(_user!.uid, name);
      if (nameResult.isLeft()) {
        _errorMessage = "Failed to update name";
        notifyListeners();
        return;
      }

      // 2. Update Weight
      int weightInt = int.tryParse(weight) ?? _weight;
      await updateUserUseCase(_user!.uid, {'weight': weightInt});

      // 3. Update Local State immediately
      _weight = weightInt;

      // 4. Reload UserEntity
      _user = await authRepository.getCurrentUser();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateWeight(int newWeight) async {
    if (_user == null) return;
    _weight = newWeight;
    notifyListeners();
    await updateUserUseCase(_user!.uid, {'weight': newWeight});
  }

  Future<void> resetPassword(String email) async {
    _status = AuthStatus.loading;
    notifyListeners();
    final result = await resetPasswordUseCase(email);
    result.fold((failure) {
      _status = AuthStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = "Reset email sent! Check your inbox.";
      notifyListeners();
    });
  }

  Future<void> updateUsername(String newName) async {
    if (_user == null) return;
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await updateUsernameUseCase(_user!.uid, newName);

    result.fold((failure) {
      _status = AuthStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) async {
      _user = await authRepository.getCurrentUser();
      _status = AuthStatus.authenticated;
      notifyListeners();
    });
  }
}