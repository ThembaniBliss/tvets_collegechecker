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
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                fillColor: Colors.blueGrey[50],
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                fillColor: Colors.blueGrey[50],
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _signInOrSignUp, // Disable button during loading
              // ignore: sort_child_properties_last
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
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
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
