// lib/models/user_model.dart
class ClerkUser {
  final String id;
  final String email;
  final String? firstName;

  ClerkUser({required this.id, required this.email, this.firstName});

  factory ClerkUser.fromJson(Map<String, dynamic> json) {
    return ClerkUser(
      id: json['id'],
      email: json['email_addresses'][0]['email_address'],
      firstName: json['first_name'],
    );
  }
}
