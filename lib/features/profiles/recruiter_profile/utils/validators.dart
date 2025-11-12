class Validators {
  Validators._();

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? requiredHttpUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final u = Uri.tryParse(v.trim());
    final ok = u != null &&
        (u.scheme == 'http' || u.scheme == 'https') &&
        u.host.isNotEmpty;
    return ok ? null : 'Enter a valid URL (http/https)';
  }
}
