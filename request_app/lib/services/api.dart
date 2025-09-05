import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:request_app/models/item.dart';
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

Future<List<String>> getItemTypes(User user) async {
  Uri url = Uri.parse('$backendUrl/item/types');
  final response = await http.get(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['itemTypes'] ?? []);
  } else {
    throw Exception('Failed to load item types');
  }
}

    Future<List<Item>> getReassignment(User user) async {
  Uri url = Uri.parse('$backendUrl/reassignment/all');
  final response = await http.get(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data as List)
        .map((item) => Item.fromJson(item))
        .toList();
  } else {
    throw Exception('Failed to load reassigned items');
  }
}

Future<void> acceptReassignment(User user, String itemId) async {
  Uri url = Uri.parse('$backendUrl/reassignment/accept/$itemId');
  final response = await http.post(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
  );
  print(response.body);
  if (response.statusCode != 200) {
    throw Exception('Failed to accept reassignment');
  }
}

Future<void> rejectReassignment(User user, String itemId) async {
  Uri url = Uri.parse('$backendUrl/reassignment/reject/$itemId');
  final response = await http.post(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
  );
  print(response.body);
  if (response.statusCode != 200) {
    throw Exception('Failed to reject reassignment');
  }
}
Future<Request> createRequest(User user, Request request) async {
  Uri url = Uri.parse('$backendUrl/request/add');
  final response = await http.post(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
    body: jsonEncode(request.toJson()),
  );
  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    print('Created request data: $data');
    return Request.fromJson(data['request']);
  } else {
    print('Error response: ${response.body}');
    throw Exception('Failed to create request');
  }
}

Future<Request> updateRequest(User user, Request request) async {
  Uri url = Uri.parse('$backendUrl/request/update');
  final response = await http.post(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
    body: jsonEncode(request.toJson()),
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Request.fromJson(data['request']);
  } else {
    print('Error response: ${response.body}');
    throw Exception('Failed to update request');
  }
}

Future<Request> updateRequestWithReassignments(User user, Request request, List<Map<String, dynamic>> itemStates) async {
  Uri url = Uri.parse('$backendUrl/request/update');
  
  // Build request body with reassignment data
  Map<String, dynamic> requestData = request.toJson();
  
  // Add reassignment information for items
  List<Map<String, dynamic>> itemsWithReassignments = [];
  for (int i = 0; i < request.items.length; i++) {
    final item = request.items[i];
    final itemState = itemStates[i];
    
    Map<String, dynamic> itemData = item.toJson();
    
    // If item is reassigned, add the reassignment target and reason
    if (itemState['status'] == 'reassigned' && itemState['selectedReceiver'] != null) {
      itemData['reassignedTo'] = itemState['selectedReceiver']['id'];
      itemData['reassignmentReason'] = itemState['reassignmentReason'] ?? '';
    }
    
    itemsWithReassignments.add(itemData);
  }
  
  requestData['items'] = itemsWithReassignments;
  
  final response = await http.post(
    url,
    headers: {...headers, 'Cookie': 'token=${user.token}'},
    body: jsonEncode(requestData),
  );
  
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Request.fromJson(data['request']);
  } else {
    print('Error response: ${response.body}');
    throw Exception('Failed to update request with reassignments');
  }
}