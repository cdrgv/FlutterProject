import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class OwnerRegisterScreen extends StatefulWidget {
  @override
  _OwnerRegisterScreenState createState() => _OwnerRegisterScreenState();
}       
class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ownerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int _currentStep = 1;
  Future<void> _register() async {
    final url = Uri.parse("http://localhost:5002/register-owner");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text,
        "shopname": _shopController.text,
        "address": _addressController.text,
        "phone": _phoneController.text,
        "latitude": _latitudeController.text,
        "longitude": _longitudeController.text,
        "username": _ownerController.text,
        "password": _passwordController.text,
      }),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registered Successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData["message"])),
      );
    }
  }
  Widget _buildContainer1() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Owner Name', Icons.person),
        SizedBox(height: 20),
        _buildTextField(_shopController, 'Shop Name', Icons.shop),
        SizedBox(height: 20),
        _buildTextField(_addressController, 'Address', Icons.location_on),
        SizedBox(height: 20),
        _buildTextField(_ownerController, 'Username', Icons.person_outline),
        SizedBox(height: 20),
        _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
        SizedBox(height: 30),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: Text('Next'),
          ),
        ),
      ],
    );
  }
  Widget _buildContainer2() {
    return Column(
      children: [
        _buildTextField(_phoneController, 'Phone Number', Icons.phone),
        SizedBox(height: 20),
        _buildTextField(_latitudeController, 'Latitude', Icons.map),
        SizedBox(height: 20),
        _buildTextField(_longitudeController, 'Longitude', Icons.map),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: Text('Previous'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showConfirmationPage();
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ],
    );
  }
  void _showConfirmationPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Registration"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmationRow("Owner Name", _nameController.text),
                _buildConfirmationRow("Shop Name", _shopController.text),
                _buildConfirmationRow("Address", _addressController.text),
                _buildConfirmationRow("Username", _ownerController.text),
                _buildConfirmationRow("Phone", _phoneController.text),
                _buildConfirmationRow("Latitude", _latitudeController.text),
                _buildConfirmationRow("Longitude", _longitudeController.text),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Edit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _register();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "New Owner Registration",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  _currentStep == 1 ? _buildContainer1() : _buildContainer2(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
