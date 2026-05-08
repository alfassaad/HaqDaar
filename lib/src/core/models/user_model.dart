enum UserRole {
  recipient,
  donor,
  merchant,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.recipient:
        return 'Verified HaqDaar (Recipient)';
      case UserRole.donor:
        return 'Aid Donor / Philanthropist';
      case UserRole.merchant:
        return 'Registered Merchant';
      case UserRole.admin:
        return 'System Administrator / Super User';
    }
  }
}

class UserProfile {
  final String id; // This should be the Firebase UID
  final String name;
  final String? cnic;
  final UserRole role;
  final double balance;
  final String qrCode;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? passcode;
  final bool biometricEnabled;
  final bool notificationsEnabled;

  UserProfile({
    required this.id,
    required this.name,
    this.cnic,
    this.role = UserRole.recipient,
    required this.balance,
    required this.qrCode,
    this.phoneNumber,
    this.profileImageUrl,
    this.passcode,
    this.biometricEnabled = true,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cnic': cnic,
      'role': role.name,
      'balance': balance,
      'qrCode': qrCode,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'passcode': passcode,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cnic: map['cnic'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'recipient'),
        orElse: () => UserRole.recipient,
      ),
      balance: (map['balance'] ?? 0.0).toDouble(),
      qrCode: map['qrCode'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      passcode: map['passcode'],
      biometricEnabled: map['biometricEnabled'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  bool get canDisburse => role == UserRole.donor;
  bool get canClaimAid => role == UserRole.recipient;
  bool get isMerchant => role == UserRole.merchant;
  bool get canSendP2P => role != UserRole.merchant && role != UserRole.donor;
  bool get isAdmin => role == UserRole.admin;

  UserProfile copyWith({
    String? id,
    String? name,
    String? cnic,
    UserRole? role,
    double? balance,
    String? qrCode,
    String? phoneNumber,
    String? profileImageUrl,
    String? passcode,
    bool? biometricEnabled,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      cnic: cnic ?? this.cnic,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      qrCode: qrCode ?? this.qrCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      passcode: passcode ?? this.passcode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
