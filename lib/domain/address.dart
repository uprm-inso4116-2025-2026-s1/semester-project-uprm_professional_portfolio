class Address {
  final String line1;
  final String? line2;
  final String city;
  final String region;      // "" allowed if N/A
  final String postalCode;
  final String countryCode; // ISO-3166 alpha-2 (e.g. PR, US)

  const Address._({
    required this.line1,
    required this.line2,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.countryCode,
  });

  factory Address({
    required String line1,
    String? line2,
    required String city,
    required String region,
    required String postalCode,
    required String countryCode,
  }) {
    String norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');
    final cc = countryCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(cc)) {
      throw ArgumentError('countryCode must be ISO-3166 alpha-2');
    }
    if (line1.trim().isEmpty) throw ArgumentError('line1 required');
    if (city.trim().isEmpty) throw ArgumentError('city required');
    if (postalCode.trim().isEmpty) throw ArgumentError('postalCode required');

    return Address._(
      line1: norm(line1),
      line2: (line2 == null || line2.trim().isEmpty) ? null : norm(line2),
      city: norm(city),
      region: norm(region),
      postalCode: norm(postalCode),
      countryCode: cc,
    );
  }

  Map<String, Object?> toMap() => {
    'line1': line1,
    'line2': line2,
    'city': city,
    'region': region,
    'postalCode': postalCode,
    'countryCode': countryCode,
  };

  factory Address.fromMap(Map<String, Object?> m) => Address(
    line1: (m['line1'] as String?) ?? '',
    line2: m['line2'] as String?,
    city: (m['city'] as String?) ?? '',
    region: (m['region'] as String?) ?? '',
    postalCode: (m['postalCode'] as String?) ?? '',
    countryCode: (m['countryCode'] as String?) ?? '',
  );

  @override
  bool operator ==(Object o) =>
      o is Address &&
      o.line1 == line1 &&
      o.line2 == line2 &&
      o.city == city &&
      o.region == region &&
      o.postalCode == postalCode &&
      o.countryCode == countryCode;

  @override
  int get hashCode =>
      Object.hash(line1, line2, city, region, postalCode, countryCode);
}
