class AppConfig {
  static const String appName = 'LSC';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl =
      'http://192.168.1.42:8000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  // static const String baseUrl = 'https://your-domain.com/api'; // Production

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyIsFirstTime = 'is_first_time';

  // BLE Configuration
  static const String clickerServiceUUID =
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String clickerCharUUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String clickerDeviceName = 'LSC-Clicker';

  // Pagination
  static const int itemsPerPage = 20;

  // Audio Settings
  static const int maxRecordingDuration = 14400; // 4 hours in seconds
  static const int audioQualityBitrate = 128000; // 128kbps
}
