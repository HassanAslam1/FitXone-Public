import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/home_provider.dart';
import 'package:the_fit_xone/features/diet/presentation/providers/diet_provider.dart';

import 'features/auth/data/auth_data.dart';
import 'features/auth/domain/auth_domain.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as app_auth;

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Diet
  sl.registerFactory(() => DietProvider());

  // ! Features - Home
  sl.registerFactory(() => HomeProvider(sharedPreferences: sl()));

  // ! Features - Auth
  sl.registerFactory(
    () => app_auth.AuthProvider(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      updateUserUseCase: sl(),
      resetPasswordUseCase: sl(), // New
      updateUsernameUseCase: sl(), // New
      authRepository: sl(),
      sharedPreferences: sl(),
    ),
  );

  // 2. Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl())); // New
  sl.registerLazySingleton(() => UpdateUsernameUseCase(sl())); // New

  // 3. Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // 4. Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // ! External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
