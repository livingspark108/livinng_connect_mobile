import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled4/user.dart';

import 'forgotpass.dart';

class WhatsAppLoginWithUsername extends StatefulWidget {
  const WhatsAppLoginWithUsername({super.key});

  @override
  State<WhatsAppLoginWithUsername> createState() => _WhatsAppLoginWithUsernameState();
}

class _WhatsAppLoginWithUsernameState extends State<WhatsAppLoginWithUsername> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both username and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
          'https://livingconnect.in/api/user/login-process?email=$username&password=$password');

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(url, headers: headers);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['data']['token'];
        final tokenType = jsonResponse['data']['token_type'];
        final user = jsonResponse['data']['user']['user'];
        final message = jsonResponse['data']['message'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token_type', tokenType);
        await prefs.setString('email', user['email']);
        await prefs.setString('first_name', user['first_name']);
        await prefs.setString('last_name', user['last_name']);
        await prefs.setString('mobile_number', user['mobile_number']);
        await prefs.setString('role', user['role']);

        if(user['vendor_uuid']!=null){
        await prefs.setString('vendorid', user['vendor_uuid'])??"";}
        await prefs.setInt('userid', user['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Login successful")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              /* username: user.name,
                      profile: user.image,*/
            ),
          ),
        );
        // Navigate to a new screen if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Wrong Credential"),
        ));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/logo.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to LivingConnect',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Enter your username and password to continue.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 30, top: 8),
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to Forgot Password screen
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('AGREE AND CONTINUE', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}