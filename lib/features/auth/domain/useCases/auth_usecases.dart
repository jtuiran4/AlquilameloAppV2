// Casos de uso para autenticación
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';

class SignInWithEmailAndPasswordUseCase {
  final AuthRepository repository;

  SignInWithEmailAndPasswordUseCase(this.repository);

  Future<AuthResult> execute(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}

class SignUpWithEmailAndPasswordUseCase {
  final AuthRepository repository;

  SignUpWithEmailAndPasswordUseCase(this.repository);

  Future<AuthResult> execute(String email, String password, String name) {
    return repository.signUpWithEmailAndPassword(email, password, name);
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<AuthResult> execute() {
    return repository.signInWithGoogle();
  }
}

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() {
    return repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserProfile?> execute() {
    return repository.getCurrentUser();
  }
}

class IsUserLoggedInUseCase {
  final AuthRepository repository;

  IsUserLoggedInUseCase(this.repository);

  Future<bool> execute() {
    return repository.isUserLoggedIn();
  }
}

class GetCurrentUserIdUseCase {
  final AuthRepository repository;

  GetCurrentUserIdUseCase(this.repository);

  Future<String?> execute() {
    return repository.getCurrentUserId();
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.resetPassword(email);
  }
}