import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}
class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _owners = [];
  Map<String, dynamic>? _selectedOwner;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredOwners = []; 
  final String apiUrl = "http://localhost:5002"; 
  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  String decryptPassword(String encryptedText) {
    try {
      final parts = encryptedText.split(":");
      if (parts.length != 2) return "Invalid format";

      final ivHex = parts[0]; 
      final encryptedHex = parts[1];
      final key = encrypt.Key.fromUtf8("sukeshpavanjayakrishnanarasaredd");
      final iv = encrypt.IV.fromBase16(ivHex);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase16(encryptedHex), iv: iv);
      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return "Error decrypting";
    }
  }
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get-owners"));
      if (response.statusCode == 200) {
        final ownersData = json.decode(response.body);
        setState(() {
          _owners = ownersData is List ? List<Map<String, dynamic>>.from(ownersData) : [];
          _filteredOwners = _owners; 
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }
  Future<void> _deleteOwner(String username) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/delete-owner/$username"));
      if (response.statusCode == 200) {
        setState(() {
          _owners.removeWhere((owner) => owner['username'] == username);
          _filteredOwners.removeWhere((owner) => owner['username'] == username);
          _selectedOwner = null; 
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Owner deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete owner')));
      }
    } catch (error) {
      print("Error deleting owner: $error");
    }
  }
  void _filterOwners(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOwners = _owners; 
      } else {
        _filteredOwners = _owners
            .where((owner) =>
                owner['name'].toLowerCase().contains(query.toLowerCase()) ||
                owner['shopname'].toLowerCase().contains(query.toLowerCase()) ||
                owner['username'].toLowerCase().contains(query.toLowerCase()))
            .toList(); 
      }
    });
  }
  Future<void> _updateOwner() async {
    if (_selectedOwner == null) return;
    TextEditingController nameController = TextEditingController(text: _selectedOwner!['name']);
    TextEditingController shopController = TextEditingController(text: _selectedOwner!['shopname']);
    TextEditingController addressController = TextEditingController(text: _selectedOwner!['address']);
    TextEditingController phoneController = TextEditingController(text: _selectedOwner!['phone']);
    TextEditingController userController = TextEditingController(text: _selectedOwner!['username']);
    TextEditingController latitudeController = TextEditingController(text: _selectedOwner!['latitude']);
    TextEditingController longitudeController = TextEditingController(text: _selectedOwner!['longitude']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Owner Details'),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
                  TextField(controller: shopController, decoration: InputDecoration(labelText: 'Shop Name')),
                  TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
                  TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
                  TextField(controller: userController, decoration: InputDecoration(labelText: 'Username')),
                  TextField(controller: latitudeController, decoration: InputDecoration(labelText: 'Latitude')),
                  TextField(controller: longitudeController, decoration: InputDecoration(labelText: 'Longitude')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                final updatedData = {
                  "name": nameController.text,
                  "shopname": shopController.text,
                  "address": addressController.text,
                  "phone": phoneController.text,
                  "username": userController.text,
                  "latitude": latitudeController.text,
                  "longitude": longitudeController.text
                };
                try {
                  final response = await http.put(
                    Uri.parse("$apiUrl/update-owner/${_selectedOwner!['username']}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(updatedData),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchData(); 
                      _selectedOwner = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Owner updated successfully')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update owner')));
                  }
                } catch (error) {
                  print("Error updating owner: $error");
                }
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
  void _toggleOwnerDetails(Map<String, dynamic> owner) {
    setState(() {
      if (_selectedOwner == owner) {
        _selectedOwner = null;
      } else {
        _selectedOwner = owner;
        _showOwnerDetailsDialog(); 
      }
    });
  }
  Widget _buildOwnerList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterOwners, 
            ),
            SizedBox(height: 10),
            Text("Registered Owners", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Divider(),
            _filteredOwners.isEmpty
                ? Center(child: Text("No owners found", style: TextStyle(color: Colors.grey)))
                : Column(
                    children: _filteredOwners.map((owner) {
                      return ListTile(
                        leading: Icon(Icons.store, color: Colors.green),
                        title: Text("${owner['name']} - ${owner['shopname']}"),
                        subtitle: Text("Username: ${owner['username']}"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _toggleOwnerDetails(owner), 
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _showOwnerDetailsDialog() {
    if (_selectedOwner == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Owner Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Name: ${_selectedOwner!['name']}"),
                  Text("Shop: ${_selectedOwner!['shopname']}"),
                  Text("Address: ${_selectedOwner!['address']}"),
                  Text("Phone: ${_selectedOwner!['phone']}"),
                  Text("Username: ${_selectedOwner!['username']}"),
                  Text("Password: ${decryptPassword(_selectedOwner!['password'])}"),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    _updateOwner();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("Update", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    _deleteOwner(_selectedOwner!['username']);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Do you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/adminLogin');
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRoleMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 150,
        overlay.size.height - 200,
        10,
        10,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Owner Register'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ownerRegister');
            },
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _fetchData,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showLogoutDialog(context);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildOwnerList(),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FloatingActionButton(
            child: Icon(Icons.more_vert),
            onPressed: () => _showRoleMenu(context),
          ),
        ),
      ),
    );
  }
}