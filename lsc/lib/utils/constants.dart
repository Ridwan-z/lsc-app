class Constants {
  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String lectureDetailRoute = '/lecture-detail';
  static const String recordingRoute = '/recording';

  // Error Messages
  static const String networkError = 'Tidak ada koneksi internet';
  static const String serverError = 'Terjadi kesalahan pada server';
  static const String unknownError = 'Terjadi kesalahan yang tidak diketahui';

  // Success Messages
  static const String loginSuccess = 'Login berhasil!';
  static const String registerSuccess = 'Registrasi berhasil!';
  static const String logoutSuccess = 'Logout berhasil!';

  // Validation Messages
  static const String emailRequired = 'Email harus diisi';
  static const String emailInvalid = 'Format email tidak valid';
  static const String passwordRequired = 'Password harus diisi';
  static const String passwordMinLength = 'Password minimal 8 karakter';
  static const String passwordNotMatch = 'Password tidak cocok';
  static const String nameRequired = 'Nama harus diisi';

  // Priority Colors
  static const Map<String, String> priorityColors = {
    'high': '#FF6B6B',
    'medium': '#FFD700',
    'low': '#87CEEB',
  };

  // Status
  static const Map<String, String> lectureStatus = {
    'recording': 'Sedang Merekam',
    'processing': 'Sedang Diproses',
    'completed': 'Selesai',
    'failed': 'Gagal',
  };
}
