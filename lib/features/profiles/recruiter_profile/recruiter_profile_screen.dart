import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../models/recruiter_profile.dart';
import 'recruiter_profile_card.dart';
import 'utils/validators.dart';

import 'widgets/hero_header.dart';
import 'widgets/save_fab.dart';
import 'widgets/snackbars.dart';

class RecruiterProfileScreen extends StatefulWidget {
  const RecruiterProfileScreen({super.key, this.initial});

  final RecruiterProfile? initial;

  @override
  State<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late RecruiterProfile _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial ??
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
  }

  void _onSave() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      AppSnackbars.error(context, 'Please fill in all required fields.');
      return;
    }

    // final toSave = _draft.copyWith(updatedAt: DateTime.now());
    // TODO: call controller/repository to persist

    AppSnackbars.success(context, 'Profile saved.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF2B7D61),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.push(AppConstants.signupRoute),
        ),
        title: Image.asset(
          'assets/logo/professional_portfolio_logo.png',
          height: 40, 
          fit: BoxFit.contain,
        ),
      ),
      floatingActionButton: SaveFAB(onPressed: _onSave),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                  model: _draft,
                  requiredValidator: Validators.required,
                  requiredUrlValidator: Validators.requiredHttpUrl,
                  onChanged: (updated) => setState(() => _draft = updated),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
