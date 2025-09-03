import 'package:request_app/models/item.dart';

class Request {
  final String name;
  final String id;
  final String userId;
  final String status;
  final List<Item> items;
  final DateTime createdAt;
  final String receiverId;
  const Request({
    required this.name,
    required this.id,
    required this.userId,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.receiverId,
  });
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      name: json['name'] ?? '',
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      status: json['status'] ?? 'pending',
      receiverId: json['receiver'] ?? '',
      items: json['items'] != null
          ? List<Item>.from(
              json['items'].map((item) => Item.fromJson(item)).toList(),
            )
          : [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}
