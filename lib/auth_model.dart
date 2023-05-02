import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

// This class handles all user authentication.
class AuthModel with ChangeNotifier {
  final String _ip = "3.67.82.109";
  bool _isLoggedIn = false;
  String? _jwt;
  String? _username;
  String _statusMessage = '';

  String get ip => _ip;
  bool get isLoggedIn => _isLoggedIn;
  String? get jwt => _jwt;
  String? get username => _username;
  String get statusMessage => _statusMessage;

  void _setStatusMessage(String msg) {
    _statusMessage = msg;
    notifyListeners();
  }

  Future<void> _storeUserData(String jwt, String username) async {
    _isLoggedIn = true;
    _jwt = jwt;
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", true);
    prefs.setString("jwt", jwt);
    prefs.setString("username", username);
    notifyListeners();
  }

  Future<void> _clearUserData() async {
    _isLoggedIn = false;
    _jwt = null;
    _username = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", false);
    prefs.remove("jwt");
    prefs.remove("username");
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    if (isLoggedIn) {
      _jwt = prefs.getString("jwt");
      _username = prefs.getString("username");
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signUp(String username, String email, String password) async {
    final url = "http://$_ip:8080/user/signup/";
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        "username": username,
        "email": email,
        "password": hashedPassword,
      }),
      headers: {"Content-Type": "application/json"},
    );
    final responseData = json.decode(response.body);
    if (responseData["status"] == 0) {
      await _storeUserData(responseData["token"], responseData["username"]);
    } else {
      _setStatusMessage(responseData["msg"]);
    }
  }

  Future<void> logIn(String user, String password) async {
    final url = "http://$_ip:8080/user/login/";
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        "user": user,
        "password": hashedPassword,
      }),
      headers: {"Content-Type": "application/json"},
    );

    final responseData = json.decode(response.body);
    if (responseData["status"] == 0) {
      await _storeUserData(responseData["token"], responseData["username"]);
    } else {
      _setStatusMessage(responseData["msg"]);
    }
  }

  Future<void> logOut() async {
    await _clearUserData();
  }

  String _eludbyder = "";

  Future<String> getEludbyder() async {
    if (_eludbyder == "") {
      final url = "http://$_ip:8080/user/eludbyder/";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_jwt",
        },
      );
      _eludbyder = jsonDecode(response.body)["eludbyder"];
    }
    return _eludbyder;
  }

  void setEludbyder(String udbyder) {
    _eludbyder = udbyder;
    final url = "http://$_ip:8080/user/eludbyder/";
    http.post(
      Uri.parse(url),
      body: json.encode({
        "eludbyder": udbyder,
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_jwt",
      },
    );
  }
}
