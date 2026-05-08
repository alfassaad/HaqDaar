import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:myapp/src/core/models/transaction_model.dart' as models;
import 'package:myapp/src/core/models/user_model.dart';
import 'package:myapp/src/core/services/firestore_service.dart';

class AppProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  UserProfile _user = UserProfile(
    id: 'NOT_LOGGED_IN',
    name: 'New User',
    role: UserRole.recipient,
    balance: 0.0,
    qrCode: '',
    phoneNumber: '',
  );

  List<models.Transaction> _transactions = [];
  bool _hasNewNotification = false;
  bool _isInitialized = false;
  StreamSubscription? _userSub;
  StreamSubscription? _txSub;
  StreamSubscription? _authSub;

  List<UserProfile> _allUsers = [];

  AppProvider() {
    _listenToAuthChanges();
  }

  bool get isInitialized => _isInitialized;

  void _listenToAuthChanges() {
    _authSub = _auth.authStateChanges().listen((authUser) async {
      if (authUser != null) {
        // User is logged in
        final profile = await _firestoreService.getUser(authUser.uid);
        if (profile != null) {
          _user = profile;
        } else {
          // If profile doesn't exist yet, we'll wait for the stream or a manual save
          _user = UserProfile(
            id: authUser.uid,
            name: authUser.displayName ?? 'New User',
            balance: 0.0,
            qrCode: jsonEncode({'id': authUser.uid, 'type': 'recipient'}),
            phoneNumber: authUser.phoneNumber,
          );
        }
        _initStreams();
      } else {
        // User is logged out
        _clearUserData();
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  void _clearUserData() {
    _userSub?.cancel();
    _txSub?.cancel();
    _transactions = [];
    _user = UserProfile(
      id: 'NOT_LOGGED_IN',
      name: 'Logged Out',
      role: UserRole.recipient,
      balance: 0.0,
      qrCode: '',
      phoneNumber: '',
    );
  }

  bool get hasNewNotification => _hasNewNotification;

  void clearNotifications() {
    _hasNewNotification = false;
    notifyListeners();
  }

  void _initStreams() {
    if (_user.id == 'NOT_LOGGED_IN') return;
    
    _userSub?.cancel();
    _txSub?.cancel();

    if (_user.isAdmin) {
      _firestoreService.getAllUsers().then((users) {
        _allUsers = users;
        notifyListeners();
      });
    }

    _userSub = _firestoreService.streamUser(_user.id).listen(
      (user) {
        _user = user;
        notifyListeners();
      },
      onError: (e) => debugPrint('User Stream Error: $e'),
    );

    _txSub = _firestoreService.streamTransactions(_user.id).listen(
      (txs) {
        if (_transactions.isNotEmpty && txs.length > _transactions.length) {
          if (txs.first.type == models.TransactionType.credit) {
            _hasNewNotification = true;
          }
        }
        _transactions = txs;
        notifyListeners();
      },
      onError: (e) => debugPrint('Transaction Stream Error: $e'),
    );
  }

  UserProfile get user => _user;
  List<UserProfile> get allUsers => List.unmodifiable(_allUsers);
  bool get isAuthenticated => _user.id != 'NOT_LOGGED_IN';
  
  Future<UserProfile?> getUser(String userId) async {
    return await _firestoreService.getUser(userId);
  }

  List<models.Transaction> get transactions => List.unmodifiable(_transactions);

  Future<bool> sendMoney({required String receiverId, required double amount}) async {
    final success = await _firestoreService.sendMoney(
      senderId: _user.id,
      receiverId: receiverId,
      amount: amount,
    );
    return success;
  }

  Future<void> login({
    required String name, 
    required String cnic, 
    required String phone,
    UserRole role = UserRole.recipient,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) return;

    try {
      // Try to sync with Firestore using the Firebase UID
      final existingUser = await _firestoreService.getUser(authUser.uid).timeout(const Duration(seconds: 4));
      
      if (existingUser != null) {
        _user = existingUser;
      } else {
        _user = UserProfile(
          id: authUser.uid,
          name: name,
          cnic: cnic,
          role: role,
          balance: 0.0,
          qrCode: jsonEncode({'id': authUser.uid, 'name': name, 'role': role.name, 'type': 'haqdaar_v1'}),
          phoneNumber: phone,
        );
        await _firestoreService.saveUser(_user).timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore Error: $e');
      rethrow;
    }
    
    _initStreams();
    notifyListeners();
  }

  void logout() async {
    await _auth.signOut();
  }

  bool get isBiometricEnabled => _user.biometricEnabled;
  bool get isNotificationsEnabled => _user.notificationsEnabled;

  void toggleBiometric(bool value) async {
    await updateProfile(biometricEnabled: value);
  }

  void toggleNotifications(bool value) async {
    await updateProfile(notificationsEnabled: value);
  }

  Future<void> setPasscode(String pin) async {
    _user = _user.copyWith(passcode: pin);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name, 
    String? phoneNumber, 
    String? cnic,
    UserRole? role,
    String? profileImageUrl,
    bool? biometricEnabled, 
    bool? notificationsEnabled
  }) async {
    final updatedUser = _user.copyWith(
      name: name ?? _user.name,
      phoneNumber: phoneNumber ?? _user.phoneNumber,
      cnic: cnic ?? _user.cnic,
      role: role ?? _user.role,
      profileImageUrl: profileImageUrl ?? _user.profileImageUrl,
      biometricEnabled: biometricEnabled ?? _user.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? _user.notificationsEnabled,
    );
    _user = updatedUser;
    await _firestoreService.saveUser(_user);
    notifyListeners();
  }

  Future<bool> uploadProfilePicture(File imageFile) async {
    final url = await _firestoreService.uploadProfileImage(_user.id, imageFile);
    if (url != null) {
      await updateProfile(profileImageUrl: url);
      return true;
    }
    return false;
  }

  Future<void> adminUpdateUser(String userId, {String? name, String? cnic, UserRole? role}) async {
    if (!_user.isAdmin) return;
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updatedUser = _allUsers[index].copyWith(
        name: name ?? _allUsers[index].name,
        cnic: cnic ?? _allUsers[index].cnic,
        role: role ?? _allUsers[index].role,
      );
      _allUsers[index] = updatedUser;
      
      // Persist to Firestore
      await _firestoreService.saveUser(updatedUser);
      
      notifyListeners();
    }
  }

  Future<void> adminDeleteUser(String userId) async {
    if (!_user.isAdmin) return;
    _allUsers.removeWhere((u) => u.id == userId);
    await _firestoreService.deleteUser(userId);
    notifyListeners();
  }

  Future<void> adminAddUser(UserProfile newUser) async {
    if (!_user.isAdmin) return;
    _allUsers.add(newUser);
    await _firestoreService.saveUser(newUser);
    notifyListeners();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _txSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
