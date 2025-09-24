import 'package:flutter/material.dart';
import 'auth/auth_service.dart';
import 'auth/login_page.dart';
import 'screens/dashboard_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le service d'authentification
  await AuthService.initialize();

  runApp(const ApsApp());
}

class ApsApp extends StatelessWidget {
  const ApsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elliora Banking',
      theme: AppTheme.lightTheme, // Utilisation du thème reproduisant Next.js
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget qui gère la navigation initiale selon l'état d'authentification
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(
                  'assets/images/elliora_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Elliora Banking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const DashboardPage() : const LoginPage();
  }
}
