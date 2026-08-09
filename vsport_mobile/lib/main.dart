import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';

void main() {
  runApp(const VSportApp());
}

/// Điều hướng toàn cục — để ApiClient đẩy người dùng về màn hình đăng nhập khi phiên hết hạn
/// (refresh token cũng không dùng được nữa).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class VSportApp extends StatefulWidget {
  const VSportApp({super.key});

  @override
  State<VSportApp> createState() => _VSportAppState();
}

class _VSportAppState extends State<VSportApp> {
  @override
  void initState() {
    super.initState();
    ApiClient.instance.onSessionExpired = () {
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(LoginScreen.route, (_) => false);
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V-SPORT',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0B4F9E),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        RootShell.route: (_) => const RootShell(),
      },
    );
  }
}
