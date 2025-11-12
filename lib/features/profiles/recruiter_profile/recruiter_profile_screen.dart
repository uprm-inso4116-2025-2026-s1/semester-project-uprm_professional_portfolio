import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../models/recruiter_profile.dart';
import '../../../components/custom_button.dart';
import 'recruiter_profile_card.dart';
import 'utils/validators.dart';

import 'widgets/hero_header.dart';
import 'widgets/snackbars.dart';

class RecruiterProfileScreen extends StatefulWidget {
  const RecruiterProfileScreen({super.key, this.initial});

  final RecruiterProfile? initial;

  @override
  State<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  RecruiterProfile? _draft;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Try to load existing profile from storage
    final storageService = StorageService();
    final savedProfile = await storageService.getRecruiterProfile();

    setState(() {
      _draft = savedProfile ??
          RecruiterProfile(
            id: 'temp', // replace with real id from your auth/store
            userId: 'temp-user', // replace with real user id
            companyName: '',
            jobTitle: '',
            companyWebsite: null,
            bio: null,
            location: null,
            phoneNumber: null,
            industries: const [],
            createdAt: DateTime.now(),
            updatedAt: null,
          );
      _isLoading = false;
    });
  }

  void _onSave() async {
    if (_draft == null) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      AppSnackbars.error(context, 'Please fill in all required fields.');
      return;
    }

    // Save profile to storage
    final storageService = StorageService();
    await storageService.saveRecruiterProfile(_draft!);

    if (mounted) {
      AppSnackbars.success(context, 'Profile created successfully!');

      // Navigate to welcome screen after profile creation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppConstants.welcomeRoute);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while profile is being loaded
    if (_isLoading || _draft == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF2B7D61),
          title: Image.asset(
            'assets/logo/professional_portfolio_logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF2B7D61),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Image.asset(
          'assets/logo/professional_portfolio_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeroHeader(
                  icon: Icons.business,
                  title: 'Recruiter Profile Setup',
                  subtitle:
                      'Tell us about your company and role to help students find you.',
                  iconSize: UIConstants.iconXL,
                  spacing: UIConstants.spaceLG,
                ),
                const SizedBox(height: UIConstants.spaceLG),

                /// The form card edits `_draft` via onChanged.
                RecruiterProfileFormCard(
                  model: _draft!,
                  requiredValidator: Validators.required,
                  requiredUrlValidator: Validators.requiredHttpUrl,
                  onChanged: (updated) => setState(() => _draft = updated),
                ),

                const SizedBox(height: UIConstants.spaceXL),

                // Create Account button
                CustomButton(
                  text: 'Create Account',
                  onPressed: _onSave,
                ),

                const SizedBox(height: UIConstants.spaceLG),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
