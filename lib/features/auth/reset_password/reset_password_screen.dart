import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/app_constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  final _auth = AuthService();

  late final StreamSubscription<AuthState> _sub;
  bool _recoveryActive = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    // Detect recovery session (deep link opens the app → Supabase emits PasswordRecovery)
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.passwordRecovery && mounted) {
        setState(() => _recoveryActive = true);
      }
    });

    // If app was already opened via recovery and session is present, allow form right away.
    // (Supabase creates a session when the link is handled)
    if (Supabase.instance.client.auth.currentSession != null) {
      _recoveryActive = true;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pwdCtrl.text != _pwd2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (!_recoveryActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active recovery session. Open the reset link again.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await _auth.updatePassword(_pwdCtrl.text);
    setState(() => _submitting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please sign in.')),
      );
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.loginRoute, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Could not update password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_recoveryActive)
              const Padding(
                padding: EdgeInsets.only(bottom: UIConstants.spaceLG),
                child: Text(
                  'Open the password reset link from your email to activate this screen.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _pwdCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                    validator: _validatePassword,
                    enabled: _recoveryActive,
                  ),
                  const SizedBox(height: UIConstants.spaceLG),
                  TextFormField(
                    controller: _pwd2Ctrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: _validatePassword,
                    enabled: _recoveryActive,
                  ),
                  const SizedBox(height: UIConstants.spaceXL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!_recoveryActive || _submitting) ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
