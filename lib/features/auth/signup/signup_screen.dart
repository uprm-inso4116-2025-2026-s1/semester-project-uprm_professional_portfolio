import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../components/role_selection_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/cubits/auth/auth_cubit.dart';

// Signup screen with role selection
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.loginRoute),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.spaceLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Join UPRM Professional Portfolio',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spaceMD),
                Text(
                  'Choose your role to get started',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spaceXL),

                // Role selection
                Text(
                  'I am a...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConstants.spaceMD),

                RoleSelectionCard(
                  title: 'Job Seeker / Student',
                  description:
                      'Looking for internships, jobs, or career opportunities',
                  icon: Icons.school,
                  isSelected: _selectedRole == AppConstants.jobseekerRole,
                  onTap: () => setState(
                      () => _selectedRole = AppConstants.jobseekerRole),
                ),
                const SizedBox(height: UIConstants.spaceMD),

                RoleSelectionCard(
                  title: 'Recruiter',
                  description: 'Representing a company and looking for talent',
                  icon: Icons.business,
                  isSelected: _selectedRole == AppConstants.recruiterRole,
                  onTap: () => setState(
                      () => _selectedRole = AppConstants.recruiterRole),
                ),
                const SizedBox(height: UIConstants.spaceXL),

                // Form fields
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: UIConstants.spaceLG),

                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: UIConstants.spaceLG),

                CustomTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: UIConstants.spaceLG),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: UIConstants.spaceXL),

                // Terms and conditions
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spaceLG),

                // Next button
                CustomButton(
                  text: 'Next',
                  onPressed: _handleNext,
                ),

                const SizedBox(height: UIConstants.spaceLG),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go(AppConstants.loginRoute);
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext() async {
    // Validate role selection
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your role'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Create user account using AuthCubit
    await context.read<AuthCubit>().signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          _selectedRole!,
        );

    if (mounted) {
      // Navigate to profile form based on role
      if (_selectedRole == AppConstants.recruiterRole) {
        context.go(AppConstants.recruiterProfileRoute);
      } else {
        context.go(AppConstants.jobseekerProfileRoute);
      }
    }
  }
}
