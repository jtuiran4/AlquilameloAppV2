import 'package:get/get.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/auth/domain/usecases/auth_usecases.dart';

class AuthController extends GetxController {
  // Use cases
  late final SignInWithEmailAndPasswordUseCase _signInUseCase;
  late final SignUpWithEmailAndPasswordUseCase _signUpUseCase;
  late final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final IsUserLoggedInUseCase _isUserLoggedInUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;

  // Estado reactivo
  final Rx<UserProfile?> currentUser = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString error = ''.obs;

  // Form state
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString name = ''.obs;
  final RxString phone = ''.obs;

  // Inicializar use cases
  void init({
    required SignInWithEmailAndPasswordUseCase signInUseCase,
    required SignUpWithEmailAndPasswordUseCase signUpUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsUserLoggedInUseCase isUserLoggedInUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) {
    _signInUseCase = signInUseCase;
    _signUpUseCase = signUpUseCase;
    _signInWithGoogleUseCase = signInWithGoogleUseCase;
    _signOutUseCase = signOutUseCase;
    _getCurrentUserUseCase = getCurrentUserUseCase;
    _isUserLoggedInUseCase = isUserLoggedInUseCase;
    _resetPasswordUseCase = resetPasswordUseCase;
  }

  // Verificar estado de autenticación al inicializar
  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Verificar si el usuario está autenticado
  Future<void> checkAuthStatus() async {
    try {
      isAuthenticated.value = await _isUserLoggedInUseCase.execute();
      if (isAuthenticated.value) {
        await loadCurrentUser();
      }
    } catch (e) {
      isAuthenticated.value = false;
      error.value = e.toString();
    }
  }

  // Cargar usuario actual
  Future<void> loadCurrentUser() async {
    try {
      final user = await _getCurrentUserUseCase.execute();
      currentUser.value = user;
      isAuthenticated.value = user != null;
    } catch (e) {
      currentUser.value = null;
      isAuthenticated.value = false;
      error.value = e.toString();
    }
  }

  // Iniciar sesión con email y contraseña
  Future<bool> signIn() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      error.value = 'Por favor completa todos los campos';
      return false;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _signInUseCase.execute(email.value, password.value);

      if (result.success) {
        currentUser.value = result.user;
        isAuthenticated.value = true;
        clearForm();
        return true;
      } else {
        error.value = result.error ?? 'Error desconocido';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Registrarse con email y contraseña
  Future<bool> signUp() async {
    if (email.value.isEmpty || password.value.isEmpty || name.value.isEmpty) {
      error.value = 'Por favor completa todos los campos';
      return false;
    }

    if (password.value != confirmPassword.value) {
      error.value = 'Las contraseñas no coinciden';
      return false;
    }

    if (password.value.length < 6) {
      error.value = 'La contraseña debe tener al menos 6 caracteres';
      return false;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _signUpUseCase.execute(email.value, password.value, name.value);

      if (result.success) {
        currentUser.value = result.user;
        isAuthenticated.value = true;
        clearForm();
        return true;
      } else {
        error.value = result.error ?? 'Error desconocido';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _signInWithGoogleUseCase.execute();

      if (result.success) {
        currentUser.value = result.user;
        isAuthenticated.value = true;
        return true;
      } else {
        error.value = result.error ?? 'Error desconocido';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    isLoading.value = true;
    error.value = '';

    try {
      await _signOutUseCase.execute();
      currentUser.value = null;
      isAuthenticated.value = false;
      clearForm();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword() async {
    if (email.value.isEmpty) {
      error.value = 'Por favor ingresa tu correo electrónico';
      return false;
    }

    isLoading.value = true;
    error.value = '';

    try {
      await _resetPasswordUseCase.execute(email.value);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Limpiar formulario
  void clearForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    phone.value = '';
    error.value = '';
  }

  // Validar email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validar contraseña
  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra y un número';
    }
    return null;
  }

  // Validar nombre
  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (name.trim().length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    return null;
  }
}