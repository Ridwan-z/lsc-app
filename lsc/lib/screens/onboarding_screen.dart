import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Rekam Kuliah\nOtomatis',
      description:
          'Fokus dengarkan kuliah, biarkan kami yang mencatat. Rekam dengan kualitas audio terbaik.',
      emoji: '🎤',
      color: Color(0xFF87CEEB),
    ),
    OnboardingData(
      title: 'Transkrip &\nRingkasan AI',
      description:
          'Dapatkan transkrip lengkap dan ringkasan otomatis dari setiap kuliah dalam hitungan menit.',
      emoji: '🤖',
      color: Color(0xFF4CAF50),
    ),
    OnboardingData(
      title: 'Bookmark\nReal-time',
      description:
          'Tandai bagian penting saat kuliah berlangsung dengan smart clicker atau tap di layar.',
      emoji: '⭐',
      color: Color(0xFFFFB84D),
    ),
    OnboardingData(
      title: 'Belajar Lebih\nEfektif',
      description:
          'Flashcard otomatis, quiz interaktif, dan study tools untuk maksimalkan pembelajaran.',
      emoji: '📚',
      color: Color(0xFF9B7EBD),
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _finishOnboarding() async {
    final storage = StorageService();
    await storage.setBool(AppConfig.keyIsFirstTime, false);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Constants.loginRoute);
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LSC',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _pages[_currentPage].color,
                    ),
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(onPressed: _skip, child: const Text('Lewati')),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: _pages[_currentPage].color,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 10,
                  dotWidth: 10,
                  expansionFactor: 4,
                ),
              ),
            ),

            // Next/Finish button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Mulai Sekarang'
                        : 'Lanjut',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(data.emoji, style: const TextStyle(fontSize: 100)),
              ),
            ),
          ),
          const SizedBox(height: 50),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: data.color,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String emoji;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}
