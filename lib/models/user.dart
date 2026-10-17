class User {
  final int? userId;
  final String fullName;
  final String email;
  final String passwordHash;
  final String phone;
  final String address;

  const User({
    this.userId,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    this.phone = '',
    this.address = '',
  });

  User copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? passwordHash,
    String? phone,
    String? address,
  }) {
    return User(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'phone': phone,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as int?,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      phone: (map['phone'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
    );
  }
}
