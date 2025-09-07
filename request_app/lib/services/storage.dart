import 'package:shared_preferences/shared_preferences.dart';
import 'package:request_app/models/user.dart';

Future<User> loadUserFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString('id') ?? '';
  final username = prefs.getString('username') ?? '';
  final role = prefs.getString('role') ?? 'user';
  final token = prefs.getString('token') ?? '';

  return User(id: id, username: username, role: role, token: token);
}

Future<void> saveUserToStorage(User user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', user.id);
  await prefs.setString('username', user.username);
  await prefs.setString('role', user.role);
  await prefs.setString('token', user.token);
}

Future<void> clearUserFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('id');
  await prefs.remove('username');
  await prefs.remove('role');
  await prefs.remove('token');
}
