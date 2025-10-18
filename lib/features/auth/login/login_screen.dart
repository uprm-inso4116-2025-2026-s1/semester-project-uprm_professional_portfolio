import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/validators.dart';
import 'login_controller.dart';

// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _controller = LoginController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spaceLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Logo and title
                Icon(
                  Icons.work,
                  size: UIConstants.iconXL * 2,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: UIConstants.spaceLG),
                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spaceMD),
                Text(
                  'Sign in to continue to UPRM Professional Portfolio',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spaceXXL),

                // Email field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: UIConstants.spaceLG),

                // Password field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Password'),
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: UIConstants.spaceMD),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: UIConstants.spaceLG),

                // Login button
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: _controller.isLoading,
                    );
                  },
                ),

                const SizedBox(height: UIConstants.spaceLG),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go(AppConstants.signupRoute);
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final result = await _controller.login(
    _emailController.text.trim(),
    _passwordController.text,
  );

  if (mounted) {
    if (result.success) {
      // No manual navigation — Supabase will trigger the GoRouter redirect automatically
      // once auth state changes (login event detected).
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Login failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

}
