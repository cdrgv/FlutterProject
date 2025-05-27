import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  String _selectedRole = 'user';
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  Future<void> _login() async {
    final emailOrUsername = _emailOrUsernameController.text.trim();
    final password = _passwordController.text.trim();
    if (emailOrUsername.isEmpty || password.isEmpty) {
      _showAlertDialog("Error", "Please fill in all fields");
      return;
    }
     String url;
  Map<String, String> requestBody;
  if (_selectedRole == 'user') {
    url = "http://localhost:5002/login"; 
    requestBody = {
      "email": emailOrUsername,
      "password": password,
    };
  } else {
    url = "http://localhost:5002/owner-login"; 
    requestBody = {
      "username": emailOrUsername,
      "password": password,
    };
  }
    try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );
    final responseData = jsonDecode(response.body);
    print("API Response: ${response.body}"); 
    if (response.statusCode == 200 && responseData.containsKey("token")) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", responseData["token"]);
      if (_selectedRole == 'owner') {
        if (responseData.containsKey("username") && responseData.containsKey("shopname")) {
          String username = responseData["username"];
          String shopName = responseData["shopname"];
          print("Owner Login Successful: Username=$username, Shop=$shopName"); 
          Navigator.pushNamed(
            context,
            '/ownerDashboard',
            arguments: {
              'username': username,
              'shopname': shopName,
            },
          );
          return;
        } else {
          print("Owner API response missing 'username' or 'shopName'");
          _showAlertDialog("Error", "Invalid owner data received.");
          return;
        }
      }
      print("User Login Successful");
      Navigator.pushNamed(context, '/dashboard');
    } else {
      _showAlertDialog("Error", responseData["error"] ?? "Invalid credentials");
    }
  } catch (e) {
    _showAlertDialog("Error", "Failed to connect to the server");
  }
}
  Future<void> _sendOtp() async {
    final email = _emailOrUsernameController.text.trim();
    if (email.isEmpty) {
      _showAlertDialog("Error", "Please enter your email");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5002/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _isOtpSent = true);
        _showAlertDialog("Success", "OTP sent to your email");
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Failed to send OTP");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
  }
  Future<void> _verifyOtp() async {
    final email = _emailOrUsernameController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showAlertDialog("Error", "Please enter the OTP");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5002/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _isOtpVerified = true);
        _showAlertDialog("Success", "OTP Verified. You can reset your password");
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Invalid OTP");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
  }
  Future<void> _resetPassword() async {
    final email = _emailOrUsernameController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      _showAlertDialog("Error", "Please enter a new password");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5002/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showAlertDialog("Success", "Password reset successfully. You can now login.");
        setState(() {
          _isOtpSent = false;
          _isOtpVerified = false;
        });
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Failed to reset password");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
  }
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  Widget _buildRoleSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedRole = 'user'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedRole == 'user'
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            child: Text(
              'User',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedRole = 'owner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedRole == 'owner'
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            child: Text(
              'Owner',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailOrUsernameController,
          decoration: InputDecoration(
            labelText: _selectedRole == 'user' ? 'Email' : 'Username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(_selectedRole == 'user' ? Icons.email : Icons.person),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _login,
          child: Text('Login'),
        ),
      ],
    );
  }
  
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Login"),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
    ),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.white, // Purple background
      child: Icon(Icons.admin_panel_settings, color: Colors.black),
      onPressed: () => {
        Navigator.pushNamed(context, '/adminLogin')
      }
    ),
    body: Container(
      color: Colors.red, // Set background color to red
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.5, // Responsive width
          decoration: BoxDecoration(
            color: Colors.white, // White background for contrast
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.red,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(
                      'web/logo1.png',
                      height: 250,
                      width: 250,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _buildRoleSelectionButtons(),
                SizedBox(height: 20),
                _buildLoginForm(),
                if (_selectedRole == "user" && !_isOtpSent)
                  TextButton(
                    onPressed: _sendOtp,
                    child: Text("Forgot Password?"),
                  ),
                if (_isOtpSent && !_isOtpVerified) ...[
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: "Enter OTP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.verified),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: Text("Verify OTP"),
                  ),
                ],
                if (_isOtpVerified) ...[
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text("Reset Password"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
