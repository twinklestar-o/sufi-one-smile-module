class LoginModel {
  final String email;
  final String password;

  LoginModel({required this.email, required this.password});

  // Untuk membuat model dari Map (misalnya dari JSON)
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  // Untuk mengubah model menjadi Map (misalnya untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  String toString() => 'LoginModel(email: $email, password: $password)';
}
