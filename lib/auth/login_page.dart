import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api_client.dart';
import '../utils/validate.dart';
import '../theme/app_colors.dart';
import 'auth_service.dart';
import '../screens/dashboard_page.dart';

/// Page de connexion utilisateur
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Navigation vers le dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur de connexion';

        if (e is ApiException) {
          errorMessage = e.message;
        } else {
          errorMessage = e.toString();
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginBackground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section - reproduction exacte du Next.js
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            margin: const EdgeInsets.only(right: 16),
                            child: Image.asset(
                              'assets/images/elliora_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ).animate().slideY(
                            begin: 20,
                            duration: 500.ms,
                            delay: 200.ms,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                    'Elliora Banking',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  )
                                  .animate()
                                  .slideY(
                                    begin: 20,
                                    duration: 500.ms,
                                    delay: 300.ms,
                                  )
                                  .fadeIn(),
                              Text(
                                    'Secure Digital Banking',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  )
                                  .animate()
                                  .slideY(
                                    begin: 20,
                                    duration: 500.ms,
                                    delay: 300.ms,
                                  )
                                  .fadeIn(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),

                  // Carte de connexion glassmorphism - reproduction exacte du Next.js
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 560,
                      borderRadius: 24,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.3),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.2),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            // Header de la carte
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to your secure banking account',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Formulaire
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Champ nom d'utilisateur
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Username',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color: Colors.white.withOpacity(0.5),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _usernameController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your username',
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                            hintStyle: GoogleFonts.inter(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          validator:
                                              ValidationUtils.validateUsername,
                                          textInputAction: TextInputAction.next,
                                          style: GoogleFonts.inter(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Champ mot de passe
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.lock,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Password',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color: Colors.white.withOpacity(0.5),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_showPassword,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your password',
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                  left: 16,
                                                  right: 48,
                                                  top: 16,
                                                  bottom: 16,
                                                ),
                                            hintStyle: GoogleFonts.inter(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _showPassword =
                                                      !_showPassword;
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.all(8),
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                ),
                                                child: Icon(
                                                  _showPassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          validator:
                                              ValidationUtils.validatePassword,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) =>
                                              _handleLogin(),
                                          style: GoogleFonts.inter(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 32),

                                  // Bouton de connexion
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: _isLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Connecting...',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Sign In',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
