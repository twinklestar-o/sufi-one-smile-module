import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sufi_one/app/modules/smile/constants/constants.dart';
import '../models/user.dart';

class ProfileController {
  Future<User> fetchUser() async {
    final response = await http.get(Uri.parse(Url + 'profile/1'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
