import 'dart:convert';
import 'package:flutter/services.dart';

class UserProfile {
  String name;
  String phone;
  String email;
  String address;
  String username;
  String role;
  String cabang;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.username,
    required this.role,
    required this.cabang,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      username: json['username'],
      role: json['role'],
      cabang: json['cabang'],
    );
  }
}

// Load JSON from assets
Future<UserProfile> loadUserProfileFromJsonAsset() async {
  final jsonString = await rootBundle.loadString(
    'res/dummyData/profilepage/userdata.json',
  );
  final jsonMap = json.decode(jsonString);
  return UserProfile.fromJson(jsonMap);
}
