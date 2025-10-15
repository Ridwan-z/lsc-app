import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/lecture_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_widget.dart';
import '../../models/lecture_model.dart';
import '../../models/category_model.dart';
import '../lecture/add_lecture_dialog.dart';
import '../category/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  String? _selectedCategoryId;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  void _loadData() {
    final lectureProvider = Provider.of<LectureProvider>(
      context,
      listen: false,
    );
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      lectureProvider.loadLectures(refresh: true);
      categoryProvider.loadCategories();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final lectureProvider = Provider.of<LectureProvider>(
        context,
        listen: false,
      );
      if (!lectureProvider.isLoading && lectureProvider.hasMore) {
        lectureProvider.loadLectures();
      }
    }
  }

  void _onRecordPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddLectureDialog(),
      ),
    );
  }

  void _showProfileMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonTopRight = button.localToGlobal(
      button.size.topRight(Offset.zero),
      ancestor: overlay,
    );

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonTopRight.dx,
        buttonTopRight.dy,
        buttonTopRight.dx,
        buttonTopRight.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              const Text('Logout'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleProfileMenuSelection(value);
      }
    });
  }

  void _handleProfileMenuSelection(String value) {
    switch (value) {
      case 'profile':
        _showProfileDialog();
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
    }
  }

  void _showProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C5F77),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF87CEEB),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF87CEEB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileInfo('Nama', user?['name'] ?? 'User'),
              const SizedBox(height: 12),
              _buildProfileInfo('Email', user?['email'] ?? '-'),
              const SizedBox(height: 12),
              if (user?['institution'] != null) ...[
                _buildProfileInfo('Universitas', user!['institution']),
                const SizedBox(height: 12),
              ],
              if (user?['major'] != null) ...[
                _buildProfileInfo('Jurusan', user!['major']),
                const SizedBox(height: 12),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Langganan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C5F77),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?['subscription_type'] == 'premium'
                          ? 'Premium'
                          : 'Free',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: user?['subscription_type'] == 'premium'
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF87CEEB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          (user?['storage_used'] ?? 0) /
                          (user?['storage_limit'] ?? 1),
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF87CEEB),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Helpers.formatFileSize(user?['storage_used'] ?? 0)} / ${Helpers.formatFileSize(user?['storage_limit'] ?? 1073741824)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2C5F77),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(Constants.loginRoute);
              Helpers.showSnackBar(context, 'Logout berhasil!');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _navigateToCategoriesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final lectureProvider = Provider.of<LectureProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final user = authProvider.user;

    final filteredLectures = _getFilteredLectures(lectureProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildHeaderSection(user, lectureProvider),
            ),
            SliverToBoxAdapter(
              child: _buildCategoriesSection(categoryProvider),
            ),
            SliverToBoxAdapter(child: _buildTabBar()),
          ];
        },
        body: _buildLecturesList(lectureProvider, filteredLectures),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onRecordPressed,
        backgroundColor: const Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeaderSection(
    Map<String, dynamic>? user,
    LectureProvider lectureProvider,
  ) {
    return Container(
      color: const Color(0xFF87CEEB),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(
                        child: const Text(
                          'Selamat Datang!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeInLeft(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          user?['name'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FadeInRight(
                  child: GestureDetector(
                    onTap: _showProfileMenu,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Kuliah',
                  '${lectureProvider.totalLectures}',
                  Icons.library_books_outlined,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Durasi',
                  Helpers.formatDuration(lectureProvider.totalDuration),
                  Icons.timer_outlined,
                  const Color(0xFFFFB84D),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Favorit',
                  '${lectureProvider.favoriteCount}',
                  Icons.favorite_outline,
                  const Color(0xFFFF6B6B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5F77),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(CategoryProvider categoryProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5F77),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CategoryChip(
                  label: 'Semua',
                  isSelected: _selectedCategoryId == null,
                  onTap: () => setState(() => _selectedCategoryId = null),
                ),
                ...categoryProvider.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: CategoryChip(
                      label: category.name,
                      color: category.color != null
                          ? Color(
                              int.parse(
                                category.color!.replaceFirst('#', '0xFF'),
                              ),
                            )
                          : const Color(0xFF87CEEB),
                      isSelected: _selectedCategoryId == category.categoryId,
                      onTap: () => setState(
                        () => _selectedCategoryId = category.categoryId,
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: _navigateToCategoriesScreen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF87CEEB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: 16,
                            color: const Color(0xFF87CEEB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF87CEEB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1),
          SizedBox(
            height: 50,
            child: Row(
              children: [_buildTab('Semua', 0), _buildTab('Favorit', 1)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int tabIndex) {
    final isSelected = _currentTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tabIndex),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF87CEEB)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF87CEEB) : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLecturesList(
    LectureProvider lectureProvider,
    List<LectureModel> lectures,
  ) {
    if (lectureProvider.isLoading && lectures.isEmpty) {
      return const LoadingWidget(message: 'Memuat kuliah...');
    }

    if (lectures.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => lectureProvider.loadLectures(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lectures.length + (lectureProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == lectures.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF87CEEB)),
                ),
              ),
            );
          }

          final lecture = lectures[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LectureCard(
              lecture: lecture,
              onTap: () {
                Helpers.showSnackBar(context, 'Membuka: ${lecture.title}');
              },
              onToggleFavorite: () {
                lectureProvider.toggleFavorite(lecture.lectureId);
              },
              onMoreOptions: () {
                Helpers.showSnackBar(
                  context,
                  'Opsi lainnya untuk: ${lecture.title}',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.library_books_outlined,
              size: 60,
              color: Color(0xFF87CEEB),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Perkuliahan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C5F77),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan perkuliahan yang ingin anda rekam dulu dengan menekan tombol dibawah',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRecordPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87CEEB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Buat Sekarang'),
          ),
        ],
      ),
    );
  }

  List<LectureModel> _getFilteredLectures(LectureProvider lectureProvider) {
    List<LectureModel> lectures = lectureProvider.lectures;

    if (_selectedCategoryId != null) {
      lectures = lectureProvider.getLecturesByCategory(_selectedCategoryId);
    }

    switch (_currentTab) {
      case 1:
        lectures = lectures.where((lecture) => lecture.isFavorite).toList();
        break;
    }

    return lectures;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
