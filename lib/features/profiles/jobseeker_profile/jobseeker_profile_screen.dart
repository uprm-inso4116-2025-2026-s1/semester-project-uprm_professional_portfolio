import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';
// import 'jobseeker_profile_controller.dart'; // TODO: Uncomment when implementing forms

// JobSeeker profile setup screen
class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  // final _controller = JobSeekerProfileController(); // TODO: Use when implementing forms

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(
                Icons.school,
                size: UIConstants.iconXL * 1.5,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: UIConstants.spaceLG),
              Text(
                'Student Profile Setup',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spaceMD),
              Text(
                'Create your professional portfolio to connect with recruiters.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spaceXXL),

              // TODO: Add form fields for job seeker profile
              // - Major
              // - Graduation year
              // - Bio
              // - Skills
              // - Interests
              // - Portfolio links

              const Expanded(
                child: Center(
                  child: Text(
                    'Form fields will be implemented here\n\n'
                    '• Major\n'
                    '• Graduation Year\n'
                    '• Bio\n'
                    '• Skills\n'
                    '• Interests\n'
                    '• Portfolio Links\n'
                    '• Resume Upload\n'
                    '• Job Preferences',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Placeholder save button
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile setup will be implemented'),
                    ),
                  );
                },
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
