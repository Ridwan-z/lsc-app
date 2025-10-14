import 'api_service.dart';
import 'storage_service.dart';
import '../config/app_config.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? institution,
    String? major,
  }) async {
    final uuid = Uuid();

    // Generate UUID yang valid
    final userId = uuid.v4();
    final settingId = uuid.v4();
    final body = {
      'id': userId,
      'setting_id': settingId,
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'default_recording_quality': 'auto', // String saja
      'auto_backup': 1, // atau true
      'auto_transcribe': 1, // atau true
      'default_playback_speed': 1.0, // decimal
      'skip_silence': 1, // atau true
      'notification_enabled': 1, // atau true
      'theme': 'light', // String
      'language': 'id', // String
      if (institution != null && institution.isNotEmpty)
        'institution': institution,
      if (major != null && major.isNotEmpty) 'major': major,
    };

    final response = await _api.post('/register', body);

    if (response['success'] == true) {
      // Save token
      final token = response['data']['access_token'];
      await _storage.setSecure(AppConfig.keyToken, token);

      // Save user data
      await _storage.setString(
        AppConfig.keyUser,
        response['data']['user'].toString(),
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await _api.post('/logout', {}, requiresAuth: true);

    // Clear local storage
    await _storage.deleteSecure(AppConfig.keyToken);
    await _storage.remove(AppConfig.keyUser);

    return response;
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get('/me', requiresAuth: true);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final body = {'email': email, 'password': password};

    final response = await _api.post('/login', body);

    if (response['success'] == true) {
      // Save token
      final token = response['data']['access_token'];
      await _storage.setSecure(AppConfig.keyToken, token);

      // Save user data
      await _storage.setString(
        AppConfig.keyUser,
        response['data']['user'].toString(),
      );
    }

    return response;
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getSecure(AppConfig.keyToken);
    return token != null && token.isNotEmpty;
  }
}
