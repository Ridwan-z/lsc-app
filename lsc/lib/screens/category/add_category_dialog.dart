import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../utils/helpers.dart';

class AddCategoryDialog extends StatefulWidget {
  final CategoryModel? category;

  const AddCategoryDialog({super.key, this.category});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final List<Color> _availableColors = [
    const Color(0xFF87CEEB), // Light Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFB84D), // Orange
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF607D8B), // Blue Grey
  ];

  Color _selectedColor = const Color(0xFF87CEEB);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      // Use the colorValue getter from CategoryModel
      _selectedColor = widget.category!.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );

      if (widget.category == null) {
        // Add new category
        await categoryProvider.createCategory(
          name: _nameController.text.trim(),
          color: _selectedColor,
        );

        if (!mounted) return;
        Helpers.showSnackBar(context, 'Kategori berhasil ditambahkan');
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Update existing category
        await categoryProvider.updateCategory(
          categoryId: widget.category!.categoryId,
          name: _nameController.text.trim(),
          color: _selectedColor,
        );

        if (!mounted) return;
        Helpers.showSnackBar(context, 'Kategori berhasil diperbarui');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Extract error message
      String errorMessage = 'Terjadi kesalahan';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      } else {
        errorMessage = e.toString();
      }

      Helpers.showSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category == null ? 'Tambah Kategori' : 'Edit Kategori',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5F77),
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF87CEEB),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kategori tidak boleh kosong';
                        }
                        if (value.trim().length > 100) {
                          return 'Nama kategori maksimal 100 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Warna',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C5F77),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) {
                        final isSelected = _selectedColor.value == color.value;
                        return GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() => _selectedColor = color);
                                },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF2C5F77),
                                      width: 3,
                                    )
                                  : Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF87CEEB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    widget.category == null
                                        ? 'Tambah'
                                        : 'Simpan',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
