enum UserRole {
  customer,
  farmer,
  supplier,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Người tiêu dùng';
      case UserRole.farmer:
        return 'Nhà sản xuất (Nông hộ)';
      case UserRole.supplier:
        return 'Nhà cung cấp (Kho vận)';
      case UserRole.admin:
        return 'Quản trị viên (Admin)';
    }
  }

  String get shortTag {
    switch (this) {
      case UserRole.customer:
        return 'KH';
      case UserRole.farmer:
        return 'NSX';
      case UserRole.supplier:
        return 'NCC';
      case UserRole.admin:
        return 'ADM';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? address;
  final String? farmName;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.farmName,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'address': address,
      'farmName': farmName,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      address: map['address'],
      farmName: map['farmName'],
      avatarUrl: map['avatarUrl'],
    );
  }
}

