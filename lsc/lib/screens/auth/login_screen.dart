import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Helpers.showSnackBar(context, Constants.loginSuccess);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo & Title
                FadeInDown(
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('🎓', style: TextStyle(fontSize: 50)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Selamat Datang\nKembali!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: const Text(
                    'Login untuk melanjutkan pembelajaran',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 500),
                  child: CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Masukkan password',
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

                const SizedBox(height: 10),

                // Forgot Password
                FadeInRight(
                  delay: const Duration(milliseconds: 600),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: const Text('Lupa Password?'),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: CustomButton(
                    text: 'Login',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: 30),

                // Divider
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ATAU',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Register Link
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(Constants.registerRoute);
                        },
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            color: Color(0xFF87CEEB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
