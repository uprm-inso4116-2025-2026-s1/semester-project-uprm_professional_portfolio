import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/cubits/auth/auth_cubit.dart';
import '../../../core/cubits/auth/auth_state.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spaceLG,
              vertical: UIConstants.spaceSM,
            ),
            child: Container(
              constraints: BoxConstraints(minHeight: 400), // Ensures layout
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: UIConstants.spaceXL),
                    // Logo with 'Sign In:' overlaid near the bottom
                    SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/logo/professional_portfolio_logo_with_txt.png',
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                'Sign In:',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        // Successful login is handled by the router's redirect.
                      },
                      builder: (context, state) {
                        return CustomButton(
                          text: 'Sign In',
                          onPressed: _handleLogin,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),

                    const SizedBox(height: UIConstants.spaceMD),

                    // OR divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.spaceMD),
                          child: Text(
                            'OR',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: UIConstants.spaceMD),

                    // Social sign in buttons
                    CustomButton(
                      text: 'Sign in with Google',
                      onPressed: () {
                        // TODO: Implement Google sign in
                      },
                      icon: Image.asset('assets/logo/google_logo.png',
                          height: 24),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),

                    const SizedBox(height: UIConstants.spaceMD),

                    CustomButton(
                      text: 'Sign in with LinkedIn',
                      onPressed: () {
                        // TODO: Implement LinkedIn sign in
                      },
                      icon: Image.asset('assets/logo/linkedin_logo.png',
                          height: 24),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),

                    const SizedBox(height: UIConstants.spaceMD),

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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    // Use AuthCubit to login
    context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }
}
