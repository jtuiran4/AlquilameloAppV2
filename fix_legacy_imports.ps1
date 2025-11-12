# Script para arreglar imports en archivos legacy

Write-Host "Arreglando imports en archivos legacy..." -ForegroundColor Green

# Mapeo de rutas relativas a rutas absolutas
$relativeToAbsolute = @{
    # From legacy datasources
    "../models/app_models.dart" = "package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart"
    "shared_preferences_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/shared_preferences_service_legacy.dart"
    "imagekit_web_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/imagekit_web_service_legacy.dart"
    "../config/imagekit_config.dart" = "package:alquilamelo_app/core/imagekit_config.dart"
    
    # From pages que se movieron
    "../services/agent_service.dart" = "package:alquilamelo_app/features/agents/data/datasources/agent_service_legacy.dart"
    "../services/auth_service.dart" = "package:alquilamelo_app/features/auth/data/datasources/auth_service_legacy.dart"
    "../services/user_service.dart" = "package:alquilamelo_app/features/user/data/datasources/user_service_legacy.dart"
    "../services/property_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/property_service_legacy.dart"
    "../services/shared_preferences_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/shared_preferences_service_legacy.dart"
    "../widgets/image_picker_web_widget.dart" = "package:alquilamelo_app/features/shared/presentation/widgets/image_picker_web_widget.dart"
    "../widgets/property_image_carousel.dart" = "package:alquilamelo_app/features/shared/presentation/widgets/property_image_carousel.dart"
    
    # Navigation imports
    "../auth/LoginScreen.dart" = "package:alquilamelo_app/features/auth/presentation/pages/login_screen.dart"
    "../home/PropertyDetailScreen.dart" = "package:alquilamelo_app/features/home/presentation/pages/property_detail_screen.dart"
    "EditProfileScreen.dart" = "package:alquilamelo_app/features/user/presentation/pages/edit_profile_screen.dart"
    
    # Services from shared
    "../services/imagekit_web_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/imagekit_web_service_legacy.dart"
    
    # Main
    "services/shared_preferences_service.dart" = "package:alquilamelo_app/features/shared/data/datasources/shared_preferences_service_legacy.dart"
}

$filesUpdated = 0
$totalReplacements = 0

# Obtener todos los archivos .dart
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $replacementsInFile = 0
    
    foreach ($relative in $relativeToAbsolute.Keys) {
        $absolute = $relativeToAbsolute[$relative]
        $pattern = "import\s+['""]" + [regex]::Escape($relative) + "['""]"
        $replacement = "import '$absolute'"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $replacementsInFile++
            $totalReplacements++
        }
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $filesUpdated++
        Write-Host "Actualizado: $($file.FullName) ($replacementsInFile reemplazos)" -ForegroundColor Cyan
    }
}

Write-Host "`n=== Resumen ===" -ForegroundColor Green
Write-Host "Archivos actualizados: $filesUpdated" -ForegroundColor Yellow
Write-Host "Total de reemplazos: $totalReplacements" -ForegroundColor Yellow
Write-Host "Proceso completado!" -ForegroundColor Green
