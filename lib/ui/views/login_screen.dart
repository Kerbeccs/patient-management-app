import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodels.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character image at the top
              Image.asset(
                isDarkMode
                    ? 'assets/logos/wave dark.png'
                    : 'assets/logos/wave light.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // Existing login form
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Show loading indicator
              if (authViewModel.isLoading) const CircularProgressIndicator(),

              // Error message
              if (authViewModel.errorMessage != null)
                Text(authViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authViewModel.isLoading
                    ? null
                    : () async {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        await authViewModel.login(email, password);
                        if (authViewModel.errorMessage == null) {
                          Navigator.pushReplacementNamed(context, '/patient');
                        }
                      },
                child: const Text("Login"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text("Don't have an account? Sign Up"),
              ),
              
              // Add divider with "or" text
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or sign in with',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              
              // Social sign in options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google sign in button
                  InkWell(
                    onTap: () async {
                      final success = await authViewModel.signInWithGoogle();
                      if (success) {
                        Navigator.pushReplacementNamed(context, '/patient');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/logos/google-37.png',
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ),
                  // Add more social sign in options here if needed
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
