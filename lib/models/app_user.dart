class AppUser {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role; // admin | driver | customer

  bool isBlocked;

  AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.isBlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'isBlocked': isBlocked,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        password: json['password'] as String,
        role: json['role'] as String,
        isBlocked: json['isBlocked'] as bool? ?? false,
      );
}
