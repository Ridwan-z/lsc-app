import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../utils/helpers.dart';
import 'add_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(category: category),
    );
  }

  void _showDeleteConfirmation(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<CategoryProvider>(context, listen: false)
                    .deleteCategory(category.categoryId);
                if (!mounted) return;
                Helpers.showSnackBar(context, 'Kategori berhasil dihapus');
              } catch (e) {
                if (!mounted) return;
                Helpers.showSnackBar(context, 'Error: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: const Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProvider.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Kategori',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tambahkan kategori untuk mengorganisir perkuliahan Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showAddCategoryDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF87CEEB),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tambah Kategori'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryProvider.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: category.color != null
                                ? Color(int.parse(
                                    category.color!.replaceFirst('#', '0xFF')))
                                : const Color(0xFF87CEEB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(category.name),
                        subtitle: Text(
                          '${category.lecturesCount} perkuliahan',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showEditCategoryDialog(category),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _showDeleteConfirmation(category),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}