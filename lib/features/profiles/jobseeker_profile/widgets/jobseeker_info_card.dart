import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../jobseeker_profile_controller.dart';

class JobSeekerProfileCard extends StatelessWidget {
  const JobSeekerProfileCard({super.key, required this.ctrl});

  final JobSeekerProfileController ctrl;

  @override
  Widget build(BuildContext context) => Card(
      color: const Color(0xFFE1FFF5),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _SectionTitle('About You'),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Major:',
              hint: 'e.g., Computer Science',
              controller: ctrl.majorCtrl,
              validator: ctrl.requiredField,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Graduation Year:',
              hint: 'e.g., 2026',
              controller: ctrl.gradYearCtrl,
              keyboardType: TextInputType.number,
              validator: ctrl.optionalInt,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Bio:',
              hint: 'Short summary about you',
              controller: ctrl.bioCtrl,
              validator: ctrl.requiredField,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Location:',
              hint: 'City / Region',
              controller: ctrl.locationCtrl,
              validator: ctrl.requiredField,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Phone Number:',
              hint: 'e.g., +17875551212',
              controller: ctrl.phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: ctrl.requiredField,
            ),

            const SizedBox(height: 20),
            const _SectionTitle('Job Preferences'),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I am currently a student'),
              value: ctrl.isStudent,
              onChanged: ctrl.setIsStudent,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final per = constraints.maxWidth / 3;
                  return SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      minimumSize: WidgetStatePropertyAll(Size(per, 40)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: [
                      ButtonSegment(
                        value: 'internship',
                        label: SizedBox(
                          width: per,
                          child: const Center(
                            child: Text('Internship', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                      ButtonSegment(
                        value: 'full-time',
                        label: SizedBox(
                          width: per,
                          child: const Center(
                            child: Text('Full-time', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                      ButtonSegment(
                        value: 'part-time',
                        label: SizedBox(
                          width: per,
                          child: const Center(
                            child: Text('Part-time', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ],
                    selected: {ctrl.jobType},
                    onSelectionChanged: (s) => ctrl.setJobType(s.first),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Willing to relocate'),
              value: ctrl.willingToRelocate,
              onChanged: ctrl.setWillingToRelocate,
            ),

            const SizedBox(height: 20),
            const _SectionTitle('Skills & Interests'),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Skills (comma-separated):',
              hint: 'e.g., Dart, Flutter, Firebase',
              controller: ctrl.skillsCtrl,
              validator: ctrl.requiredField,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Interests (comma-separated):',
              hint: 'e.g., Mobile, Backend, AI',
              controller: ctrl.interestsCtrl,
              validator: ctrl.requiredField,
              maxLines: 2,
            ),

            const SizedBox(height: 20),
            const _SectionTitle('Links (optional)'),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Portfolio URL:',
              hint: 'https://your-website.com',
              controller: ctrl.portfolioUrlCtrl,
              keyboardType: TextInputType.url,
              validator: ctrl.optionalUrl,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'LinkedIn URL:',
              hint: 'https://linkedin.com/in/username',
              controller: ctrl.linkedinUrlCtrl,
              keyboardType: TextInputType.url,
              validator: ctrl.optionalUrl,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'GitHub URL:',
              hint: 'https://github.com/username',
              controller: ctrl.githubUrlCtrl,
              keyboardType: TextInputType.url,
              validator: ctrl.optionalUrl,
            ),

            const SizedBox(height: 20),
            const _SectionTitle('Resume'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: ctrl.uploading
                  ? null
                  : () async {
                final err = await ctrl.pickResume();
                if (!context.mounted) {
                  return;
                }
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                } else if (ctrl.resumeName != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${ctrl.resumeName}')),
                  );
                }
              },
              icon: ctrl.uploading
                  ? const SizedBox(
                  height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file),
              label: Text(
                ctrl.resumeName == null
                    ? 'Upload PDF (≤ 5 MB)'
                    : 'Selected: ${ctrl.resumeName} ${ctrl.resumePrettySize != null ? "(${ctrl.resumePrettySize})" : ""}',
                overflow: TextOverflow.ellipsis,
              ),
            ),

          ],
        ),
      ),
    );
}

/* ---------- Helpers ---------- */

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600
            )
        ),
        const SizedBox(height: UIConstants.spaceSM),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700
        ),
        textAlign: TextAlign.start,
      ),
    );
}
