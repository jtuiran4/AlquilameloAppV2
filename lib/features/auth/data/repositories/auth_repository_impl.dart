import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';
import 'package:alquilamelo_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:alquilamelo_app/features/auth/data/datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl remoteDataSource;
  final AuthLocalDataSourceImpl localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await remoteDataSource.signInWithEmailAndPassword(email, password);

      // Cache user data locally
      if (result.success && result.user != null) {
        await localDataSource.cacheUserId(result.user!.id);
        await localDataSource.cacheUserProfile(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      final result = await remoteDataSource.signUpWithEmailAndPassword(email, password, name);

      // Cache user data locally
      if (result.success && result.user != null) {
        await localDataSource.cacheUserId(result.user!.id);
        await localDataSource.cacheUserProfile(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final result = await remoteDataSource.signInWithGoogle();

      // Cache user data locally
      if (result.success && result.user != null) {
        await localDataSource.cacheUserId(result.user!.id);
        await localDataSource.cacheUserProfile(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearAuthCache();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      // Try to get from remote first
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        // Update local cache
        await localDataSource.cacheUserId(remoteUser.id);
        await localDataSource.cacheUserProfile(remoteUser);
        return remoteUser;
      }

      // Fallback to local cache
      return await localDataSource.getCachedUserProfile();
    } catch (e) {
      // Fallback to local cache
      return await localDataSource.getCachedUserProfile();
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return await remoteDataSource.isUserLoggedIn();
    } catch (e) {
      // Check local cache as fallback
      final userId = await localDataSource.getCachedUserId();
      return userId != null;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    try {
      final remoteId = await remoteDataSource.getCurrentUserId();
      if (remoteId != null) {
        await localDataSource.cacheUserId(remoteId);
        return remoteId;
      }

      return await localDataSource.getCachedUserId();
    } catch (e) {
      return await localDataSource.getCachedUserId();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    return await remoteDataSource.resetPassword(email);
  }
}