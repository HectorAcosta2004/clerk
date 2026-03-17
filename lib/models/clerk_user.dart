// lib/models/clerk_user.dart
class ClerkUser {
  final String id;
  final String email;
  final String? firstName;
  final String? imageUrl;

  ClerkUser({
    required this.id,
    required this.email,
    this.firstName,
    this.imageUrl,
  });

  factory ClerkUser.fromJson(Map<String, dynamic> json) {
    return ClerkUser(
      id: json['id'],
      email: json['email_addresses'][0]['email_address'],
      firstName: json['first_name'],
      imageUrl: json['image_url'],
    );
  }
}
