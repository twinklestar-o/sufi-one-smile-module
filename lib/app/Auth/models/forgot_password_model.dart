class ForgotPasswordModel {
  final String email;

  ForgotPasswordModel({required this.email});

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() => {'email': email};
}
