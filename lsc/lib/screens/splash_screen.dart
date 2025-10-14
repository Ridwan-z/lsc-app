import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    await Future.delayed(const Duration(seconds: 2));

    final storage = StorageService();
    final isFirstTime = await storage.getBool(AppConfig.keyIsFirstTime) ?? true;
    final token = await storage.getString(AppConfig.keyToken);

    if (!mounted) return;

    if (isFirstTime) {
      // First time user -> Onboarding
      Navigator.of(context).pushReplacementNamed(Constants.onboardingRoute);
    } else if (token != null && token.isNotEmpty) {
      // User already logged in -> Home
      Navigator.of(context).pushReplacementNamed(Constants.homeRoute);
    } else {
      // User not logged in -> Login
      Navigator.of(context).pushReplacementNamed(Constants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F6F9), Color(0xFF87CEEB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎓', style: TextStyle(fontSize: 80)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: const Text(
                  'Lecture Speed\nController',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: const Text(
                  'AI-Powered Learning Assistant',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 50),
              FadeInUp(
                duration: const Duration(milliseconds: 1400),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
