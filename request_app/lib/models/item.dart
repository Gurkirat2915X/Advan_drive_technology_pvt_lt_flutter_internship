class Item {
  const Item({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.status,
  });
  final String id;
  final String name;
  final String type;
  final int quantity;
  final String status;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
    };
  }
}