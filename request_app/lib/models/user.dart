class User {
  final String id;
  final String username;
  final String role;
  final String token;
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.token,

  });

  factory User.empty() {
    return User(id: '', username: '', role: 'user', token: '');
  }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'] ?? json['user']['_id'] ?? '',
      username: json['user']['username'] ?? '',
      role: json['user']['role'] ?? '',
      token: json['token'] ?? ''
    );
  }

  bool get isReceiver => role == 'receiver';
  bool get isEndUser => role == 'end_user';

  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role, token: $token}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.role == role &&
        other.token == token;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ role.hashCode ^ token.hashCode;
  }
}
