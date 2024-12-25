class User {
  final String id;
  final String? name;
  final String? lastName;
  final String? email;
  final String? password;

  const User({
    required this.id,
    this.name,
    this.lastName,
    this.email,
    this.password,
  });
}
