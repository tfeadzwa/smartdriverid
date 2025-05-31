class User {
  final String identifier;
  final String password;
  final String role;
  final String? name;
  final String? dob;
  final String? address;
  final String? nationalId;
  final String? licenseClass;
  final String? licenseIssueDate;
  final String? licenseExpiryDate;
  final String? endorsements;

  User({
    required this.identifier,
    required this.password,
    required this.role,
    this.name,
    this.dob,
    this.address,
    this.nationalId,
    this.licenseClass,
    this.licenseIssueDate,
    this.licenseExpiryDate,
    this.endorsements,
  });
}
