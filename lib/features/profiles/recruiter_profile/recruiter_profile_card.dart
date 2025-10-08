import 'package:flutter/material.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../models/recruiter_profile.dart';
import 'utils/validators.dart';

class RecruiterProfileFormCard extends StatelessWidget {
  const RecruiterProfileFormCard({
    super.key,
    required this.model,
    required this.onChanged,
    this.requiredValidator = Validators.required,
    this.requiredUrlValidator = Validators.requiredHttpUrl,
  });

  final RecruiterProfile model;
  final ValueChanged<RecruiterProfile> onChanged;

  /// Pluggable validators with sensible defaults.
  final String? Function(String?) requiredValidator;
  final String? Function(String?) requiredUrlValidator;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFE1FFF5),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _LabeledField(
            label: 'Company:',
            hint: 'Add your company here!',
            initialValue: model.companyName,
            validator: requiredValidator,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) =>
                onChanged(model.copyWith(companyName: v.trim())),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Job Title:',
            hint: 'Add your job here!',
            initialValue: model.jobTitle,
            validator: requiredValidator,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => onChanged(model.copyWith(jobTitle: v.trim())),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Company URL:',
            hint: 'Add your company website here!',
            initialValue: model.companyWebsite ?? '',
            keyboardType: TextInputType.url,
            validator: requiredUrlValidator,
            onChanged: (v) => onChanged(
              model.copyWith(
                companyWebsite: v.trim().isEmpty ? null : v.trim(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Bio:',
            hint: 'Set your bio here!',
            initialValue: model.bio ?? '',
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            // Bio is optional; keep validator if you want to force it.
            validator: requiredValidator,
            onChanged: (v) => onChanged(
              model.copyWith(bio: v.trim().isEmpty ? null : v.trim()),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField
            (
            label: 'Location:',
            hint: 'Set the city you work in!',
            initialValue: model.location ?? '',
            textCapitalization: TextCapitalization.words,
            validator: requiredValidator,
            onChanged: (v) => onChanged(
              model.copyWith(location: v.trim().isEmpty ? null : v.trim()),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Contact Information:',
            hint: 'Add your contact phone here!',
            initialValue: model.phoneNumber ?? '',
            keyboardType: TextInputType.phone,
            // Make it required or swap to a phone validator if you add one later.
            validator: requiredValidator,
            onChanged: (v) => onChanged(
              model.copyWith(phoneNumber: v.trim().isEmpty ? null : v.trim()),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.validator,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String hint;
  final String initialValue;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spaceSM),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
