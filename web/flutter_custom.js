{{flutter_js}}

// Configuración personalizada para centrar la app en web
window.addEventListener('DOMContentLoaded', function() {
  // Configurar Flutter para que use el contenedor específico
  _flutter.loader.load({
    hostElement: document.getElementById('flutter-target')
  });
});