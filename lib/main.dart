import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/theme/theme_provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';
import 'package:myapp/src/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:myapp/src/auth/presentation/screens/login_screen.dart';
import 'package:myapp/src/features/home/presentation/screens/home_screen.dart';
import 'package:myapp/src/features/qr/presentation/screens/qr_screen.dart';
import 'package:myapp/src/features/history/presentation/screens/history_screen.dart';
import 'package:myapp/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:myapp/src/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:myapp/src/features/profile/presentation/screens/security_settings_screen.dart';
import 'package:myapp/src/features/profile/presentation/screens/support_screens.dart';
import 'package:myapp/src/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:myapp/src/features/scaffold/presentation/screens/scaffold_screen.dart';
import 'package:myapp/src/features/scan_and_pay/presentation/screens/scan_and_pay_screen.dart';
import 'package:myapp/src/features/payment/presentation/screens/payment_confirmation_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
      child: const HaqDaarApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) {
    final appProvider = context.read<AppProvider>();
    if (!appProvider.isInitialized) return null;

    final loggingIn = state.matchedLocation == '/login';
    final onboarding = state.matchedLocation == '/';

    if (!appProvider.isAuthenticated && !loggingIn && !onboarding) {
      return '/login';
    }
    if (appProvider.isAuthenticated && (loggingIn || onboarding)) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/scan-and-pay',
      builder: (context, state) => const ScanAndPayScreen(),
    ),
    GoRoute(
      path: '/confirm-payment',
      builder: (context, state) => PaymentConfirmationScreen(
        merchantId: state.extra as String? ?? '',
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/qr',
          builder: (context, state) => const QRScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const ProfileEditScreen(),
            ),
            GoRoute(
              path: 'security',
              builder: (context, state) => const SecuritySettingsScreen(),
            ),
            GoRoute(
              path: 'help',
              builder: (context, state) => const HelpCenterScreen(),
            ),
            GoRoute(
              path: 'privacy',
              builder: (context, state) => const PrivacyPolicyScreen(),
            ),
            GoRoute(
              path: 'about',
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: 'admin',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class HaqDaarApp extends StatelessWidget {
  const HaqDaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF006A4E);

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        primary: primarySeedColor,
        onPrimary: Colors.white,
        surface: const Color(0xFFF8FAF9), // Very light mint-white for crispness
        onSurface: const Color(0xFF1A1C1B), // Deep charcoal for readability
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primarySeedColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: const Color(0xFF1A1C1B), // Darker title for better scanning
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          disabledBackgroundColor: const Color(0xFFE0E0E0), // Clear grey for disabled
          disabledForegroundColor: const Color(0xFF9E9E9E), // Readable but "off" text
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),
    );

    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF40C5A0), // Brighter mint for dark mode visibility
      onPrimary: Colors.black,
      surface: const Color(0xFF121212),
      onSurface: Colors.white,
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: darkColorScheme.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: darkColorScheme.primary,
          disabledBackgroundColor: const Color(0xFF333333),
          disabledForegroundColor: const Color(0xFF757575),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'HaqDaar',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
