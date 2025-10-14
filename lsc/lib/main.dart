import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/auth_provider.dart';
import 'providers/lecture_provider.dart';
import 'providers/recording_provider.dart'; // ADD THIS IMPORT
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/recording/recording_screen.dart'; // ADD THIS IMPORT
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LectureProvider()),
        ChangeNotifierProvider(create: (_) => RecordingProvider()), // ADD THIS
      ],
      child: MaterialApp(
        title: 'LSC - Lecture Speed Controller',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: Constants.splashRoute,
        routes: {
          Constants.splashRoute: (context) => const SplashScreen(),
          Constants.onboardingRoute: (context) => const OnboardingScreen(),
          Constants.loginRoute: (context) => const LoginScreen(),
          Constants.registerRoute: (context) => const RegisterScreen(),
          Constants.homeRoute: (context) => const HomeScreen(),
          Constants.recordingRoute: (context) => const RecordingScreen(), // ADD THIS
        },
      ),
    );
  }
}