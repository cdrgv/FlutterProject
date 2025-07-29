import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

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
  bool _isLoading = false;

  // === API methods (your logic as before) ===
  // ... [Use your existing _login, _sendOtp, _verifyOtp, _resetPassword, _showAlertDialog methods here, unchanged] ...
  Future<void> _login() async {
    setState(() => _isLoading = true);
    final emailOrUsername = _emailOrUsernameController.text.trim();
    final password = _passwordController.text.trim();
    if (emailOrUsername.isEmpty || password.isEmpty) {
      _showAlertDialog("Error", "Please fill in all fields");
      setState(() => _isLoading = false);
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
      if (response.statusCode == 200 && responseData.containsKey("token")) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", responseData["token"]);
        if (_selectedRole == 'owner') {
          if (responseData.containsKey("username") && responseData.containsKey("shopname")) {
            Navigator.pushNamed(
              context,
              '/ownerDashboard',
              arguments: {
                'username': responseData["username"],
                'shopname': responseData["shopname"],
              },
            );
            setState(() => _isLoading = false);
            return;
          } else {
            _showAlertDialog("Error", "Invalid owner data received.");
            setState(() => _isLoading = false);
            return;
          }
        }
        Navigator.pushNamed(context, '/dashboard');
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Invalid credentials");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
    setState(() => _isLoading = false);
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text(message, style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleSelectionButtons() {
    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(16),
        color: Colors.deepPurple[400],
        fillColor: Colors.deepPurpleAccent.withOpacity(0.15),
        selectedColor: Colors.white,
        selectedBorderColor: Colors.deepPurple,
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
        isSelected: [_selectedRole == 'user', _selectedRole == 'owner'],
        onPressed: (i) => setState(() => _selectedRole = i == 0 ? 'user' : 'owner'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Text('User', style: TextStyle(
              color: _selectedRole == 'user' ? Colors.white : Colors.deepPurple,
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Text('Owner', style: TextStyle(
              color: _selectedRole == 'owner' ? Colors.white : Colors.deepPurple,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        SizedBox(height: 5),
        TextFormField(
          controller: _emailOrUsernameController,
          style: GoogleFonts.montserrat(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF7F7FA),
            labelText: _selectedRole == 'user' ? 'Email' : 'Username',
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(13)
            ),
            prefixIcon: Icon(_selectedRole == 'user' ? Icons.email : Icons.person),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          style: GoogleFonts.montserrat(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF7F7FA),
            labelText: 'Password',
            labelStyle: GoogleFonts.montserrat(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(13)
            ),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              backgroundColor: Colors.deepPurple,
              elevation: 4,
            ),
            child: _isLoading
                 ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ))
                 : Text('Login', style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Text("Login", style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple[900],
        )),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple[900]),
          onPressed: () => Navigator.pushNamed(context, '/overview'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent.shade100,
        child: Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
        tooltip: "Admin Login",
        onPressed: () => Navigator.pushNamed(context, '/adminLogin'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // BLUR for extra glass effect
          if (w > 650)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: FadeInDown(
              duration: Duration(milliseconds: 700),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: w < 500 ? 6 : 0),
                width: w < 420 ? w * 0.98 : w < 700 ? w * 0.85 : w * 0.47,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 23),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.86),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.10),
                            blurRadius: 23,
                            offset: Offset(6, 12),
                          )
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFa18cd1),
                              radius: 46,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('web/logo1.png', height: 62),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text("Sign in to your Account", 
                              style: GoogleFonts.montserrat(
                                fontSize: 23, fontWeight: FontWeight.bold,
                                color: Color(0xFF481e99)
                              )
                            ),
                            SizedBox(height: 18),
                            _buildRoleSelectionButtons(),
                            SizedBox(height: 24),
                            _buildLoginForm(),
                            // Forgot password logic
                            if (_selectedRole == "user" && !_isOtpSent) ... [
                              SizedBox(height: 12),
                              TextButton(
                                onPressed: _sendOtp,
                                child: Text("Forgot Password?",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                            if (_isOtpSent && !_isOtpVerified) ...[
                              Divider(height: 32),
                              Text("Enter OTP sent to your email",
                                style: GoogleFonts.montserrat(
                                  color: Colors.deepPurple[600],
                                )
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: _otpController,
                                style: GoogleFonts.montserrat(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF7F7FA),
                                  labelText: "Enter OTP",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13)),
                                  prefixIcon: Icon(Icons.verified),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                  backgroundColor: Colors.deepPurpleAccent),
                                onPressed: _verifyOtp,
                                child: Text("Verify OTP", 
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontWeight: FontWeight.bold
                                  )),
                              ),
                            ],
                            if (_isOtpVerified) ... [
                              Divider(height: 32),
                              Text("Reset your password",
                                style: GoogleFonts.montserrat(
                                  color: Colors.deepPurple[600],
                                ),
                              ),
                              SizedBox(height: 6),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: true,
                                style: GoogleFonts.montserrat(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF7F7FA),
                                  labelText: "New Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13)),
                                  prefixIcon: Icon(Icons.lock_reset),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                  backgroundColor: Colors.deepPurpleAccent),
                                onPressed: _resetPassword,
                                child: Text("Reset Password", 
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontWeight: FontWeight.bold
                                  )),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
