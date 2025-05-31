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
  final List<String> _roles = ['Driver', 'Admin', 'Police', 'Organization'];
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
          // Save the current user identifier for session management
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', _identifier);

          // Show success dialog before navigating
          String roleDisplay = _role;
          if (_role == 'Organization') roleDisplay = 'Organization User';
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      const SizedBox(width: 8),
                      const Text('Login Successful'),
                    ],
                  ),
                  content: Text('Welcome, $roleDisplay!'),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
          );

          if (_role == 'Driver') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserDashboardScreen(),
              ),
            );
          } else if (_role == 'Admin') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else if (_role == 'Police') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PoliceScreen()),
            );
          } else if (_role == 'Organization') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrganizationScreen(),
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
          setState(() => _isLogin = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please log in.'),
            ),
          );
        } else {
          setState(
            () =>
                _errorMessage = 'This email/identifier is already registered.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.blueAccent.shade100,
                              child: Icon(
                                Icons.verified_user,
                                size: 44,
                                color: Colors.blueAccent.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isLogin ? 'Welcome Back!' : 'Create Account',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLogin
                                  ? 'Login to your Smart Driver ID'
                                  : 'Register for Smart Driver ID',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Colors.blueAccent.shade200,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: _validateIdentifier,
                              onSaved: (value) => _identifier = value!.trim(),
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.blueAccent.shade200,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              obscureText: true,
                              validator: _validatePassword,
                              onSaved: (value) => _password = value!,
                              autofillHints: const [AutofillHints.password],
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<String>(
                              value: _role,
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
                                  (value) => setState(() => _role = value!),
                              decoration: InputDecoration(
                                labelText: 'Role',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Colors.blueAccent.shade200,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  _isLogin ? 'Login' : 'Register',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
                                    ? 'Don\'t have an account? Register'
                                    : 'Already have an account? Login',
                                style: TextStyle(
                                  color: Colors.blueAccent.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => const AlertDialog(
                                        title: Text('Biometric Login'),
                                        content: Text(
                                          'Biometric login not implemented yet.',
                                        ),
                                      ),
                                );
                              },
                              icon: Icon(
                                Icons.fingerprint,
                                color: Colors.blueAccent.shade200,
                              ),
                              label: const Text(
                                'Login with Fingerprint/Face ID',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blueAccent.shade700,
                                side: BorderSide(
                                  color: Colors.blueAccent.shade100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
          ),
        ),
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

class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Organization!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_box),
              label: const Text('Register New Driver'),
              onPressed: () {
                // TODO: Implement driver registration
                showDialog(
                  context: context,
                  builder:
                      (context) => const AlertDialog(
                        title: Text('Register Driver'),
                        content: Text('Feature coming soon!'),
                      ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('View Organization Drivers'),
              onPressed: () {
                // TODO: Implement driver list
                showDialog(
                  context: context,
                  builder:
                      (context) => const AlertDialog(
                        title: Text('Organization Drivers'),
                        content: Text('Feature coming soon!'),
                      ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Organization Info'),
              onPressed: () {
                // TODO: Implement org info
                showDialog(
                  context: context,
                  builder:
                      (context) => const AlertDialog(
                        title: Text('Organization Info'),
                        content: Text('Feature coming soon!'),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
