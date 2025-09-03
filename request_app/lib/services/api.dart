import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:request_app/models/request.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/variables.dart';

const headers = {'Content-Type': 'application/json', 'User-Agent': "True"};

Future<User> loginUser(String username, String password) async {
  Uri url = Uri.parse('$backendUrl/auth/login');
  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode({'username': username, 'password': password}),
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return User.fromJson(data);
  } else {
    throw Exception('Failed to login');
  }
}

Future<bool> isLoggedIn(User cur) async {
  Uri url = Uri.parse('$backendUrl/verifyToken');
  final response = await http.get(
    url,
    headers: {...headers, 'Cookie': 'token=${cur.token}'},
  );
  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<List<Map<String, String>>> getReceivers(User cur) async {
  Uri url = Uri.parse('$backendUrl/receivers');
  final response = await http.get(url, headers: {...headers, 'Cookie': 'token=${cur.token}'});
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data as List)
        .map((receiver) => {
              'id': receiver['_id']?.toString() ?? '',
              'username': receiver['username']?.toString() ?? '',
            })
        .toList();
  } else {
    throw Exception('Failed to load receivers');
  }
}

Future<List<Request>> getRequests(User cur) async {
  Uri url = Uri.parse('$backendUrl/request/all');
  final response = await http.get(
    url,
    headers: {...headers, 'Cookie': 'token=${cur.token}'},
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final requestsList = data['requests'] as List;
    return requestsList.map((request) => Request.fromJson(request)).toList();
  } else {
    throw Exception('Failed to load requests');
  }
}