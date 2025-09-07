class User {
  final String id;
  final String username;
  final String role;
  final String token;
  final bool isLoading;
  
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
    this.isLoading = false,
  });

  factory User.empty() {
    return User(id: '', username: '', role: '', token: '');
  }
  
  factory User.loading() {
    return User(id: '', username: '', role: '', token: '', isLoading: true);
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
  bool get isAuthenticated => token.isNotEmpty && !isLoading;

  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role, token: $token, isLoading: $isLoading}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.role == role &&
        other.token == token &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ role.hashCode ^ token.hashCode ^ isLoading.hashCode;
  }
}
