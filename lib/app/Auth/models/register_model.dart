class RegisterModel {
  String name;
  String email;
  String no_telp;
  String password;

  RegisterModel({
    required this.name,
    required this.email,
    required this.no_telp,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'no_telp': no_telp,
      'password': password,
      'password_confirmation': password, // tambahkan untuk konfirmasi
    };
  }
}
