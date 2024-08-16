import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final SupabaseClient supabaseClient;
  const LoginPage({super.key, required this.supabaseClient});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isSignUp = false; // Track whether the user is signing up or signing in

  Future<void> _signInOrSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
    });

    try {
      if (_isSignUp) {
        // Sign up (register)
        final response = await widget.supabaseClient.auth.signUp(
          email: email,
          password: password,
        );

        if (response.session != null) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomePage(supabaseClient: widget.supabaseClient),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Registration failed. Please try again.';
          });
        }
      } else {
        // Sign in (login)
        final response = await widget.supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.session != null) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomePage(supabaseClient: widget.supabaseClient),
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                'Login failed. Please check your credentials and try again.';
          });
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // App Logo or Title
              Icon(
                Icons.school,
                size: 100,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 20),
              Text(
                _isSignUp ? 'Sign Up' : 'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 40),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue.shade700),
                  ),
                  fillColor: Colors.blueGrey[50],
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue.shade700),
                  ),
                  fillColor: Colors.blueGrey[50],
                  filled: true,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // Sign In / Sign Up Button
              ElevatedButton(
                onPressed: _isLoading ? null : _signInOrSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading ? Colors.grey : Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        _isSignUp ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 20),
              // Toggle between Sign In / Sign Up
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Sign Up",
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              // Error Message
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
