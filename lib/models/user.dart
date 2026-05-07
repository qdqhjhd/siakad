class User {
  String identifier;
  String username;
  String password;
  String nama;
  String role;
  String? kodeProdi;

  User({
    required this.identifier,
    required this.username,
    required this.password,
    required this.nama,
    required this.role,
    this.kodeProdi,
  });
}
