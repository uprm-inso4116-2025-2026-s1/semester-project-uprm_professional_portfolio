import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';
// import 'recruiter_profile_controller.dart'; // TODO: Uncomment when implementing forms

// Recruiter profile setup screen
class RecruiterProfileScreen extends StatefulWidget {
  const RecruiterProfileScreen({super.key});

  @override
  State<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  // final _controller = RecruiterProfileController(); // TODO: Use when implementing forms

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
                Icons.business,
                size: UIConstants.iconXL * 1.5,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: UIConstants.spaceLG),
              Text(
                'Recruiter Profile Setup',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spaceMD),
              Text(
                'Tell us about your company and role to help students find you.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spaceXXL),

              // TODO: Add form fields for recruiter profile
              // - Company name
              // - Job title
              // - Company website
              // - Bio
              // - Location
              // - Industries

              const Expanded(
                child: Center(
                  child: Text(
                    'Form fields will be implemented here\n\n'
                    '• Company Name\n'
                    '• Job Title\n'
                    '• Company Website\n'
                    '• Bio\n'
                    '• Location\n'
                    '• Industries\n'
                    '• Contact Information',
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
