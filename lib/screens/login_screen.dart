import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'registration_screen.dart';
import 'user_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'police_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _identifier = '';
  String _password = '';
  String _role = 'Driver';
  final List<String> _roles = ['Driver', 'Admin', 'Police'];
  bool _isLogin = true;
  String? _errorMessage;

  // Improved email regex for validation
  final _emailRegex = RegExp(r'^[\w-\.]+@[\w-]+(\.[\w-]+)+\$?');

  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your email';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _errorMessage = null);
      if (_isLogin) {
        final success = await AuthService.login(_identifier, _password, _role);
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', _identifier);
          if (_role == 'Driver') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const UserDashboardScreen(),
              ),
            );
          } else if (_role == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else if (_role == 'Police') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PoliceDashboardScreen(),
              ),
            );
          } else {
            // Organization or other roles
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const UserDashboardScreen(),
              ),
            );
          }
        } else {
          setState(
            () => _errorMessage = 'Invalid credentials. Please try again.',
          );
        }
      } else {
        final registered = await AuthService.register(
          _identifier,
          _password,
          _role,
        );
        if (registered) {
          setState(() {
            _isLogin = true;
            _errorMessage = 'Registration successful! Please log in.';
          });
        } else {
          setState(() => _errorMessage = 'User already exists. Please log in.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background-image.jpg', // visually best for login background
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(
              0.45,
            ), // dark overlay for readability
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Image.asset(
                        'assets/smartid-icon.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Text(
                      'Smart Driver ID',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? 'Sign in to your account'
                          : 'Create a new account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateIdentifier,
                                onSaved: (val) => _identifier = val!.trim(),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                                validator: _validatePassword,
                                onSaved: (val) => _password = val!,
                              ),
                              const SizedBox(height: 18),
                              DropdownButtonFormField<String>(
                                value: _role,
                                decoration: InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items:
                                    _roles
                                        .map(
                                          (role) => DropdownMenuItem(
                                            value: role,
                                            child: Text(role),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (val) => setState(() => _role = val!),
                              ),
                              const SizedBox(height: 22),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color:
                                          _errorMessage ==
                                                  'Registration successful! Please log in.'
                                              ? Colors.blueAccent.shade700
                                              : Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text(
                                    _isLogin ? 'Sign In' : 'Register',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed:
                                    () => setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin
                                      ? "Don't have an account? Register"
                                      : "Already have an account? Sign In",
                                  style: TextStyle(
                                    color: Colors.blueAccent.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '© 2025 Smart Driver ID. All rights reserved.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Replace the old PoliceScreen with a simple wrapper
class PoliceScreen extends StatelessWidget {
  const PoliceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PoliceDashboardScreen();
  }
}
