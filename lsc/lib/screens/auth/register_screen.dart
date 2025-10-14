import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _institutionController = TextEditingController();
  final _majorController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _institutionController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmController.text,
      institution: _institutionController.text.trim(),
      major: _majorController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Helpers.showSnackBar(context, Constants.registerSuccess);
      Navigator.of(context).pushReplacementNamed(Constants.homeRoute);
    } else {
      Helpers.showSnackBar(
        context,
        result['message'] ?? Constants.unknownError,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                FadeInDown(
                  child: const Text(
                    'Buat Akun\nBaru',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Daftar untuk memulai pembelajaran',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

                // Name Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: CustomTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'John Doe',
                    prefixIcon: Icons.person_outline,
                    validator: Validators.validateName,
                  ),
                ),

                const SizedBox(height: 16),

                // Email Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 300),
                  child: CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                ),

                const SizedBox(height: 16),

                // Institution Field (Optional)
                FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: CustomTextField(
                    controller: _institutionController,
                    label: 'Universitas (Opsional)',
                    hint: 'Universitas Indonesia',
                    prefixIcon: Icons.school_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // Major Field (Optional)
                FadeInLeft(
                  delay: const Duration(milliseconds: 500),
                  child: CustomTextField(
                    controller: _majorController,
                    label: 'Jurusan (Opsional)',
                    hint: 'Teknik Informatika',
                    prefixIcon: Icons.book_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // Password Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 600),
                  child: CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Minimal 8 karakter',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: Validators.validatePassword,
                  ),
                ),

                const SizedBox(height: 16),

                // Password Confirmation Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 700),
                  child: CustomTextField(
                    controller: _passwordConfirmController,
                    label: 'Konfirmasi Password',
                    hint: 'Ketik ulang password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePasswordConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscurePasswordConfirm =
                              !_obscurePasswordConfirm,
                        );
                      },
                    ),
                    validator: (value) =>
                        Validators.validatePasswordConfirmation(
                          value,
                          _passwordController.text,
                        ),
                  ),
                ),

                const SizedBox(height: 30),

                // Register Button
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: CustomButton(
                    text: 'Daftar',
                    onPressed: _register,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: 20),

                // Login Link
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF87CEEB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
