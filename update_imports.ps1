# Script para actualizar todos los imports después de reorganizar el proyecto

$replacements = @{
    # Agents
    "package:alquilamelo_app/agent/AddPropertyScreen.dart" = "package:alquilamelo_app/features/agents/presentation/pages/add_property_screen.dart"
    "package:alquilamelo_app/agent/AgentInquiriesScreen.dart" = "package:alquilamelo_app/features/agents/presentation/pages/agent_inquiries_screen.dart"
    "package:alquilamelo_app/agent/AgentLoginScreen.dart" = "package:alquilamelo_app/features/agents/presentation/pages/agent_login_screen.dart"
    "package:alquilamelo_app/agent/AgentPropertiesScreen.dart" = "package:alquilamelo_app/features/agents/presentation/pages/agent_properties_screen.dart"
    "package:alquilamelo_app/agent/AgentRegisterScreen.dart" = "package:alquilamelo_app/features/agents/presentation/pages/agent_register_screen.dart"
    "package:alquilamelo_app/agent/EditPropertyScreen.dart" = "package:alquilamelo_app/features/agents/presentation/pages/edit_property_screen.dart"
    "package:alquilamelo_app/agent/AgentDashboard.dart" = "package:alquilamelo_app/features/agents/presentation/pages/agent_dashboard.dart"
    
    # Auth
    "package:alquilamelo_app/auth/LoginScreen.dart" = "package:alquilamelo_app/features/auth/presentation/pages/login_screen.dart"
    "package:alquilamelo_app/auth/RegisterScreen.dart" = "package:alquilamelo_app/features/auth/presentation/pages/register_screen.dart"
    
    # Appointments (citas)
    "package:alquilamelo_app/citas/AgentContactScreen.dart" = "package:alquilamelo_app/features/appointments/presentation/pages/agent_contact_screen.dart"
    
    # Favorites
    "package:alquilamelo_app/favoritos/FavoritesScreen.dart" = "package:alquilamelo_app/features/favorites/presentation/pages/favorites_screen.dart"
    
    # Home
    "package:alquilamelo_app/home/HomeScreen.dart" = "package:alquilamelo_app/features/home/presentation/pages/home_screen.dart"
    "package:alquilamelo_app/home/PropertyDetailScreen.dart" = "package:alquilamelo_app/features/home/presentation/pages/property_detail_screen.dart"
    
    # User
    "package:alquilamelo_app/user/EditProfileScreen.dart" = "package:alquilamelo_app/features/user/presentation/pages/edit_profile_screen.dart"
    "package:alquilamelo_app/user/ProfileScreen.dart" = "package:alquilamelo_app/features/user/presentation/pages/profile_screen.dart"
    
    # Services to datasources
    "package:alquilamelo_app/services/agent_service.dart" = "package:alquilamelo_app/features/agents/data/datasources/agent_service_legacy.dart"
    "package:alquilamelo_app/services/auth_service.dart" = "package:alquilamelo_app/features/auth/data/datasources/auth_service_legacy.dart"
    "package:alquilamelo_app/services/user_service.dart" = "package:alquilamelo_app/features/user/data/datasources/user_service_legacy.dart"
    "package:alquilamelo_app/services/property_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/property_service_legacy.dart"
    "package:alquilamelo_app/services/imagekit_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/imagekit_service_legacy.dart"
    "package:alquilamelo_app/services/imagekit_web_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/imagekit_web_service_legacy.dart"
    "package:alquilamelo_app/services/shared_preferences_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/shared_preferences_service_legacy.dart"
    
    # Models to entities
    "package:alquilamelo_app/models/app_models.dart" = "package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart"
    
    # Widgets
    "package:alquilamelo_app/widgets/" = "package:alquilamelo_app/features/shared/presentation/widgets/"
    
    # Core
    "package:alquilamelo_app/AlquilameloApp.dart" = "package:alquilamelo_app/core/alquilamelo_app.dart"
    "package:alquilamelo_app/SplashScreen.dart" = "package:alquilamelo_app/features/shared/presentation/pages/splash_screen.dart"
    "package:alquilamelo_app/config/" = "package:alquilamelo_app/core/config/"
}

Write-Host "Iniciando actualizacion de imports..." -ForegroundColor Green

# Obtener todos los archivos .dart
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

$totalFiles = $dartFiles.Count
$currentFile = 0
$updatedFiles = 0

foreach ($file in $dartFiles) {
    $currentFile++
    Write-Progress -Activity "Actualizando imports" -Status "Archivo $currentFile de $totalFiles" -PercentComplete (($currentFile / $totalFiles) * 100)
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        $content = $content -replace [regex]::Escape($old), $new
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $updatedFiles++
        Write-Host "Actualizado: $($file.FullName)" -ForegroundColor Cyan
    }
}

Write-Host "`nProceso completado!" -ForegroundColor Green
Write-Host "Archivos analizados: $totalFiles" -ForegroundColor Yellow
Write-Host "Archivos actualizados: $updatedFiles" -ForegroundColor Yellow
