import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'superadminpage.dart';
import 'adminpage.dart';
class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String _selectedAdmin = 'admin1';
  final TextEditingController _adminUserController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _admin2UserController = TextEditingController();
  final TextEditingController _admin2PasswordController = TextEditingController();
  Future<void> _loginSuperAdmin() async {
    final url = Uri.parse('http://localhost:5002/superadminlogin');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _adminUserController.text,
          "password": _adminPasswordController.text,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAdminPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }
  }
  Future<void> _loginAdmin() async {
    final url = Uri.parse('http://localhost:5002/admin-login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _admin2UserController.text,
          "password": _admin2PasswordController.text,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }
  }
  Widget _buildAdminSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedAdmin = 'admin1'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedAdmin == 'admin1' ? Colors.blue : Colors.grey,
            ),
            child: Text(
              'Super Admin',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedAdmin = 'admin2'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedAdmin == 'admin2' ? Colors.blue : Colors.grey,
            ),
            child: Text(
              'Admin',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSuperAdminLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _adminUserController,
          decoration: InputDecoration(
            labelText: 'Super Admin Username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _adminPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loginSuperAdmin,
          child: Text('Login'),
        ),
      ],
    );
  }
  Widget _buildAdminLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _admin2UserController,
          decoration: InputDecoration(
            labelText: 'Admin Username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _admin2PasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loginAdmin,
          child: Text('Login'),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Login")),
      backgroundColor: const Color.fromARGB(255, 247, 3, 3),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
                ),
                child: Column(
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
                    _buildAdminSelectionButtons(),
                    SizedBox(height: 20),
                    _selectedAdmin == 'admin1' ? _buildSuperAdminLoginForm() : _buildAdminLoginForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
