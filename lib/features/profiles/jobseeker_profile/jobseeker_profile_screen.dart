import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uprm_professional_portfolio/features/profiles/jobseeker_profile/widgets/jobseeker_info_card.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../components/custom_button.dart';
import 'jobseeker_profile_controller.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  late final JobSeekerProfileController ctrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ctrl = JobSeekerProfileController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Try to load existing profile from storage
    final storageService = StorageService();
    final savedProfile = await storageService.retrieveJobSeekerProfileFromLocalStorage();

    if (savedProfile != null) {
      ctrl.loadFromModel(savedProfile);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while profile is being loaded
    if (_isLoading) {
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

    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 56,
          backgroundColor: const Color(0xFF2B7D61),
          foregroundColor: Colors.white,
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          centerTitle: true,
          title: Image.asset(
            'assets/logo/professional_portfolio_logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: ctrl.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_pin_circle,
                    size: UIConstants.iconXL * 1.5,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: UIConstants.spaceLG),
                  Text(
                    'Job Seeker Profile Setup',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spaceMD),
                  Text(
                    'Fill out your details so recruiters can discover you.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spaceLG),
                  JobSeekerProfileCard(ctrl: ctrl),

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
      ),
    );
  }

  void _onSave() async {
    if (!(ctrl.formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please fill in the required information.',
            style: TextStyle(color: Colors.white)),
      ));
      return;
    }

    final draft = ctrl.toDraftMap(); // or ctrl.toModel(id: ..., userId: ...)
    debugPrint('JobSeeker draft -> $draft');

    // Save profile to storage
    final model = ctrl.toModel(id: 'temp', userId: 'temp-user');
    final storageService = StorageService();
    await storageService.persistJobSeekerProfileLocally(model);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: const Text('Profile created successfully!',
            style: TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));

      // Navigate to welcome screen after profile creation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppConstants.welcomeRoute);
        }
      });
    }
  }
}
