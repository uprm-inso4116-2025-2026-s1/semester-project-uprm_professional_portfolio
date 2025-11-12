import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/cubits/auth/auth_cubit.dart';
import '../../core/cubits/auth/auth_state.dart';

/// Settings screen with profile access and logout
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(UIConstants.spaceXL),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spaceMD),
                      Text(
                        user.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spaceSM),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spaceSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spaceMD,
                          vertical: UIConstants.spaceSM,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.role == AppConstants.recruiterRole
                                  ? Icons.business
                                  : Icons.school,
                              size: 16,
                            ),
                            const SizedBox(width: UIConstants.spaceSM),
                            Text(
                              user.role == AppConstants.recruiterRole
                                  ? 'Recruiter'
                                  : 'Job Seeker',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: UIConstants.spaceLG),

                // Settings options
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'View and edit your profile',
                  onTap: () {
                    // Navigate to profile based on role
                    if (user.role == AppConstants.recruiterRole) {
                      context.push(AppConstants.recruiterProfileRoute);
                    } else {
                      context.push(AppConstants.jobseekerProfileRoute);
                    }
                  },
                ),
                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    // TODO: Navigate to notifications settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Change app language',
                  onTap: () {
                    // TODO: Navigate to language settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and support',
                  onTap: () {
                    // TODO: Navigate to help
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    // TODO: Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),

                const SizedBox(height: UIConstants.spaceXL),

                // Logout button
                Padding(
                  padding: const EdgeInsets.all(UIConstants.spaceLG),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.spaceMD,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: UIConstants.spaceLG),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().logout();
              context.go(AppConstants.loginRoute);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spaceLG,
        vertical: UIConstants.spaceSM,
      ),
    );
  }
}
