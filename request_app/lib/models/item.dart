class Item {
  const Item({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.status,
    this.reassignedTo,
    this.requestName,
    this.requestId,
    this.originalReceiver,
    this.notes,
  });
  final String id;
  final String name;
  final String type;
  final int quantity;
  final String status;
  final String? reassignedTo;
  final String? requestName;
  final String? requestId;
  final String? originalReceiver;
  final String? notes;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? '',
      reassignedTo: json['reassignedTo'] ?? '',
      requestName: json['requestName'],
      requestId: json['requestId'],
      originalReceiver: json['originalReceiver'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'status': status,
      'reassignedTo': reassignedTo,
      'requestName': requestName,
      'requestId': requestId,
      'originalReceiver': originalReceiver,
      'notes': notes,
    };
  }
}