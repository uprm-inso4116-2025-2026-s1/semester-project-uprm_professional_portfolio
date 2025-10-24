import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uprm_professional_portfolio/features/profiles/jobseeker_profile/widgets/jobseeker_info_card.dart';
import '../../../core/constants/ui_constants.dart';
import 'jobseeker_profile_controller.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  late final JobSeekerProfileController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = JobSeekerProfileController();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

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

          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: viewInsets > 0 ? viewInsets + 12 : 0),
            child: FloatingActionButton(
              onPressed: _onSave,
              tooltip: 'Done',
              backgroundColor: const Color(0xFF2B7D61),
              foregroundColor: Colors.white,
              child: const Icon(Icons.check, size: 32),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          body: SafeArea(
            child: Form(
              key: ctrl.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  UIConstants.spaceLG,
                  UIConstants.spaceLG,
                  UIConstants.spaceLG,
                  120,
                ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  void _onSave() {
    if (!(ctrl.formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
            'Please fill in the required information.',
            style: TextStyle(
                color: Colors.white
            )
        ),
      ));
      return;
    }

    final draft = ctrl.toDraftMap(); // or ctrl.toModel(id: ..., userId: ...)
    debugPrint('JobSeeker draft -> $draft');


    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: const Text(
          'Profile saved (UI only).',
          style: TextStyle(
              color: Colors.white
          )
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),
      margin: const EdgeInsets.all(16),
    ));
  }
}
