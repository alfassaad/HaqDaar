class AppConstants {
  static const String appName = 'HaqDaar';
  static const String appVersion = '1.0.0';
  
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double avatarRadius = 60.0;
  static const double borderRadius = 16.0;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  static const int minPasscodeLength = 4;
  static const int maxQRCodeLength = 200;
  static const int transactionPageSize = 20;
  
  static const String qrCodeType = 'haqdaar_v1';
  static const String merchantIdPrefix = 'haqdaar_';
  
  static const List<String> weakPasscodes = [
    '0000', '1111', '2222', '3333', '4444', 
    '5555', '6666', '7777', '8888', '9999', 
    '1234', '4321', '0123', '3210'
  ];
  
  static const String dateFormatFull = 'MMM dd, yyyy';
  static const String dateFormatShort = 'yyyy-MM-dd';
  static const String dateFormatTime = 'h:mm a';
  static const String dateFormatDateTime = 'MMM d, h:mm a';
}

class FirestoreCollections {
  static const String users = 'users';
  static const String transactions = 'transactions';
  static const String userProfiles = 'user_profiles';
}

class RouteNames {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String qr = '/qr';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profileSecurity = '/profile/security';
  static const String profileHelp = '/profile/help';
  static const String profilePrivacy = '/profile/privacy';
  static const String profileAbout = '/profile/about';
  static const String profileAdmin = '/profile/admin';
  static const String scanAndPay = '/scan-and-pay';
  static const String confirmPayment = '/confirm-payment';
}