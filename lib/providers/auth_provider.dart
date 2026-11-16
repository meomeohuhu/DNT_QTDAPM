import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserRole _activeRole = UserRole.customer;
  final List<UserModel> _allMockUsers = MockDataService.getMockUsers();

  UserModel? get currentUser => _currentUser;
  UserRole get activeRole => _activeRole;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _activeRole = await StorageService.getActiveRole();
    _currentUser = _allMockUsers.firstWhere(
      (u) => u.role == _activeRole,
      orElse: () => _allMockUsers.first,
    );
    notifyListeners();
  }

  /// Switch the active role seamlessly for multi-role demonstration
  Future<void> switchRole(UserRole newRole) async {
    _activeRole = newRole;
    _currentUser = _allMockUsers.firstWhere(
      (u) => u.role == newRole,
      orElse: () => _allMockUsers.first,
    );
    await StorageService.saveActiveRole(newRole);
    notifyListeners();
  }

  void login(String email, String password) {
    final matched = _allMockUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => _allMockUsers.first,
    );
    _currentUser = matched;
    _activeRole = matched.role;
    StorageService.saveActiveRole(_activeRole);
    notifyListeners();
  }

  void logout() {
    switchRole(UserRole.customer);
  }
}

