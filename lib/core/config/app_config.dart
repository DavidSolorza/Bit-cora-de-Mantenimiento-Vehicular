class AppConfig {
  static const String appName = 'Bitácora de Mantenimiento Vehicular';
  static const String vehicleModel = 'Renault Sandero Stepway';
  
  // URL Pública del Servidor Backend (Cloudflare)
  static const String apiBaseUrl = 'https://dashboard.servidor.blog';
  static const String apiSecretToken = 'Bearer core_backend_secret_key_2026';

  // Rutas de Endpoints REST
  static const String endpointDashboard = '/api/mantenimiento/dashboard';
  static const String endpointVehiculos = '/api/mantenimiento/vehiculos';
  static const String endpointRegistros = '/api/mantenimiento/registros';
  static const String endpointCategorias = '/api/mantenimiento/categorias';
  static const String endpointSalud = '/api/mantenimiento/salud';

  static const Duration timeoutDuration = Duration(seconds: 10);
}
