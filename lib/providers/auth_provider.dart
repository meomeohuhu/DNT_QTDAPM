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
    final role = await StorageService.getActiveRole();
    if (_currentUser == null) await _selectRole(role);
  }

  Future<void> _selectRole(UserRole role) async {
    final demoUser = _allMockUsers.firstWhere((user) => user.role == role);
    _activeRole = role;
    _currentUser = demoUser;
    final profile = await StorageService.getProfile(demoUser.id);
    if (!identical(_currentUser, demoUser)) return;
    _currentUser = profile ?? demoUser;
    notifyListeners();
  }

  /// Switch the active role for multi-role demonstration.
  Future<void> switchRole(UserRole newRole) async {
    await _selectRole(newRole);
    await StorageService.saveActiveRole(_activeRole);
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final user = _currentUser;
    if (user == null) return;
    final profile = UserModel(
      id: user.id,
      name: name,
      email: user.email,
      phone: phone,
      role: user.role,
      address: address,
      avatarUrl: user.avatarUrl,
      farmName: user.farmName,
    );
    await StorageService.saveProfile(profile);
    if (_currentUser?.id == user.id) {
      _currentUser = profile;
      notifyListeners();
    }
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

