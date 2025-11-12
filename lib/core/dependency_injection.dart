import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared domain
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';
import 'package:alquilamelo_app/features/shared/domain/usecases/property_usecases.dart';

// Shared data
import 'package:alquilamelo_app/features/shared/data/datasources/property_remote_datasource.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/property_local_datasource.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/imagekit_datasource_impl.dart';
import 'package:alquilamelo_app/features/shared/data/repositories/property_repository_impl.dart';

// Shared presentation
import 'package:alquilamelo_app/features/shared/presentation/controllers/property_controller.dart';

// Auth domain
import 'package:alquilamelo_app/features/auth/domain/usecases/auth_usecases.dart';

// Auth data
import 'package:alquilamelo_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:alquilamelo_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:alquilamelo_app/features/auth/data/repositories/auth_repository_impl.dart';

// Auth presentation
import 'package:alquilamelo_app/features/auth/presentation/controllers/auth_controller.dart';

// Agents domain
import 'package:alquilamelo_app/features/agents/domain/usecases/agent_usecases.dart';

// Agents data
import 'package:alquilamelo_app/features/agents/data/datasources/agent_remote_datasource.dart';
import 'package:alquilamelo_app/features/agents/data/repositories/agent_repository_impl.dart';

// Agents presentation
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // External dependencies
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final prefs = await SharedPreferences.getInstance();

    // Shared Data sources
    final propertyRemoteDataSource = PropertyRemoteDataSourceImpl(firestore);
    final propertyLocalDataSource = PropertyLocalDataSourceImpl(prefs);
    final imageKitDataSource = ImageKitDataSourceImpl();

    // Shared Repositories
    final propertyRepository = PropertyRepositoryImpl(
      remoteDataSource: propertyRemoteDataSource,
      localDataSource: propertyLocalDataSource,
    );

    // Shared Use cases
    final getPropertiesUseCase = GetPropertiesUseCase(propertyRepository);
    final getPropertyByIdUseCase = GetPropertyByIdUseCase(propertyRepository);
    final getPropertiesByAgentUseCase = GetPropertiesByAgentUseCase(propertyRepository);
    final getFavoritePropertiesUseCase = GetFavoritePropertiesUseCase(propertyRepository);
    final toggleFavoriteUseCase = ToggleFavoriteUseCase(propertyRepository);
    final isFavoriteUseCase = IsFavoriteUseCase(propertyRepository);
    final incrementViewsUseCase = IncrementPropertyViewsUseCase(propertyRepository);
    final getRecentPropertiesUseCase = GetRecentPropertiesUseCase(propertyRepository);
    final getFeaturedPropertiesUseCase = GetFeaturedPropertiesUseCase(propertyRepository);

    // Shared Controllers
    final propertyController = PropertyController();
    propertyController.init(
      getPropertiesUseCase: getPropertiesUseCase,
      getPropertyByIdUseCase: getPropertyByIdUseCase,
      getPropertiesByAgentUseCase: getPropertiesByAgentUseCase,
      getFavoritePropertiesUseCase: getFavoritePropertiesUseCase,
      toggleFavoriteUseCase: toggleFavoriteUseCase,
      isFavoriteUseCase: isFavoriteUseCase,
      incrementViewsUseCase: incrementViewsUseCase,
      getRecentPropertiesUseCase: getRecentPropertiesUseCase,
      getFeaturedPropertiesUseCase: getFeaturedPropertiesUseCase,
    );

    // Auth Data sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(auth, firestore);
    final authLocalDataSource = AuthLocalDataSourceImpl(prefs);

    // Auth Repositories
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    // Auth Use cases
    final signInUseCase = SignInWithEmailAndPasswordUseCase(authRepository);
    final signUpUseCase = SignUpWithEmailAndPasswordUseCase(authRepository);
    final signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository);
    final signOutUseCase = SignOutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    final isUserLoggedInUseCase = IsUserLoggedInUseCase(authRepository);
    final resetPasswordUseCase = ResetPasswordUseCase(authRepository);

    // Auth Controllers
    final authController = AuthController();
    authController.init(
      signInUseCase: signInUseCase,
      signUpUseCase: signUpUseCase,
      signInWithGoogleUseCase: signInWithGoogleUseCase,
      signOutUseCase: signOutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      isUserLoggedInUseCase: isUserLoggedInUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
    );

    // Agents Data sources
    final agentRemoteDataSource = AgentRemoteDataSourceImpl(
      firestore: firestore,
      auth: auth,
      imageService: imageKitDataSource,
    );

    // Agents Repositories
    final agentRepository = AgentRepositoryImpl(
      remoteDataSource: agentRemoteDataSource,
    );

    // Agents Use cases
    final createAgentProfileUseCase = CreateAgentProfileUseCase(agentRepository);
    final getCurrentAgentProfileUseCase = GetCurrentAgentProfileUseCase(agentRepository);
    final isCurrentUserAgentUseCase = IsCurrentUserAgentUseCase(agentRepository);
    final addPropertyUseCase = AddPropertyUseCase(agentRepository);
    final getAgentPropertiesUseCase = GetAgentPropertiesUseCase(agentRepository);
    final getAgentStatsUseCase = GetAgentStatsUseCase(agentRepository);
    final getAgentInquiriesUseCase = GetAgentInquiriesUseCase(agentRepository);
    final updateInquiryStatusUseCase = UpdateInquiryStatusUseCase(agentRepository);
    final togglePropertyActiveUseCase = TogglePropertyActiveUseCase(agentRepository);
    final updatePropertyUseCase = UpdatePropertyUseCase(agentRepository);
    final uploadImagesUseCase = UploadImagesUseCase(agentRepository);
    final deletePropertyUseCase = DeletePropertyUseCase(agentRepository);

    // Agents Controllers
    final agentController = AgentController();
    agentController.init(
      createAgentProfileUseCase: createAgentProfileUseCase,
      getCurrentAgentProfileUseCase: getCurrentAgentProfileUseCase,
      isCurrentUserAgentUseCase: isCurrentUserAgentUseCase,
      addPropertyUseCase: addPropertyUseCase,
      getAgentPropertiesUseCase: getAgentPropertiesUseCase,
      getAgentStatsUseCase: getAgentStatsUseCase,
      getAgentInquiriesUseCase: getAgentInquiriesUseCase,
      updateInquiryStatusUseCase: updateInquiryStatusUseCase,
      togglePropertyActiveUseCase: togglePropertyActiveUseCase,
      updatePropertyUseCase: updatePropertyUseCase,
      uploadImagesUseCase: uploadImagesUseCase,
      deletePropertyUseCase: deletePropertyUseCase,
    );

    // Register with GetX
    Get.put<PropertyController>(propertyController, permanent: true);
    Get.put<PropertyRepository>(propertyRepository, permanent: true);
    Get.put<AuthController>(authController, permanent: true);
    Get.put<AuthRepository>(authRepository, permanent: true);
    Get.put<AgentController>(agentController, permanent: true);
    Get.put<AgentRepositoryImpl>(agentRepository, permanent: true);
  }
}