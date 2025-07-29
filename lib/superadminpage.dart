import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:ui'; // <-- Add this line

class SuperAdminPage extends StatefulWidget {
  @override
  _SuperAdminPageState createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _selectedOwner;
  List<Map<String, dynamic>> _users = [], _owners = [], _admins = [];
  List<Map<String, dynamic>> _filteredUsers = [], _filteredOwners = [], _filteredAdmins = [];
  Map<String, dynamic>? _selected;
  String selectedRole = "users";
  final String apiUrl = "http://localhost:5002";

  // Add missing methods
  Future<void> _updateAdmin() async {
  if (_selectedOwner == null) return;
  TextEditingController nameController = TextEditingController(text: _selectedOwner!['name']);
  TextEditingController addressController = TextEditingController(text: _selectedOwner!['address']);
  TextEditingController userController = TextEditingController(text: _selectedOwner!['username']);
  showDialog(
    context: context,
    builder: (context) {
      bool isLoading = false; 
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Update Admin Details'),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
                    TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
                    TextField(controller: userController, decoration: InputDecoration(labelText: 'Username')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context), 
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null 
                    : () async {
                        setState(() {
                          isLoading = true; 
                        });
                        final updatedData = {
                          "name": nameController.text,
                          "address": addressController.text,
                          "username": userController.text,
                        };
                        try {
                          final response = await http.put(
                            Uri.parse("$apiUrl/update-admin/${_selectedOwner!['username']}"),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(updatedData),
                          );
                          if (response.statusCode == 200) {
                            setState(() {
                              _fetchData(); 
                              _selectedOwner = null; 
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Admin updated successfully')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update admin')));
                          }
                        } catch (error) {
                          print("Error updating admin: $error");
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('An error occurred while updating admin')));
                        } finally {
                          setState(() {
                            isLoading = false; 
                          });
                          Navigator.pop(context); 
                        }
                      },
                child: isLoading
                    ? CircularProgressIndicator() 
                    : Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _deleteAdmin(String username) async {
    // TODO: Implement delete admin logic (e.g., send delete request to backend)
    try {
      final response = await http.delete(Uri.parse('$apiUrl/delete-admin/$username'));
      if (response.statusCode == 200) {
        setState(() {
          _admins.removeWhere((admin) => admin['username'] == username);
          _filteredAdmins.removeWhere((admin) => admin['username'] == username);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin deleted successfully'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete admin'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting admin: $e'))
      );
    }
  }

  Future<void> _updateUser() async {
    if (_selectedOwner == null) return;
    TextEditingController emailController = TextEditingController(text: _selectedOwner!['email']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update User Details'),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email:')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                final updatedData = {
                  "email": emailController.text,
                };
                try {
                  final response = await http.put(
                    Uri.parse("$apiUrl/update-user/${_selectedOwner!['email']}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(updatedData),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchData(); 
                      _selectedOwner = null; 
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User updated successfully')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update user')));
                  }
                } catch (error) {
                  print("Error updating user: $error");
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

  Future<void> _deleteUser(String email) async {
    // TODO: Implement delete user logic
    try {
      final response = await http.delete(Uri.parse('$apiUrl/delete-user/$email'));
      if (response.statusCode == 200) {
        setState(() {
          _users.removeWhere((user) => user['email'] == email);
          _filteredUsers.removeWhere((user) => user['email'] == email);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e'))
      );
    }
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

  Future<void> _deleteOwner(String username) async {
    // TODO: Implement delete owner logic
    try {
      final response = await http.delete(Uri.parse('$apiUrl/delete-owner/$username'));
      if (response.statusCode == 200) {
        setState(() {
          _owners.removeWhere((owner) => owner['username'] == username);
          _filteredOwners.removeWhere((owner) => owner['username'] == username);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Owner deleted successfully'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete owner'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting owner: $e'))
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      if (selectedRole == "users") {
        _filteredUsers = q.isEmpty ? _users : _users.where((u) => (u['email'] ?? '').toLowerCase().contains(q)).toList();
      } else if (selectedRole == "owners") {
        _filteredOwners = q.isEmpty ? _owners : _owners.where((o) => (o['shopname'] ?? '').toLowerCase().contains(q)).toList();
      } else {
        _filteredAdmins = q.isEmpty ? _admins : _admins.where((a) => (a['username'] ?? '').toLowerCase().contains(q)).toList();
      }
    });
  }

  Future<void> _fetchData() async {
    try {
      final usersResponse = await http.get(Uri.parse("$apiUrl/get-users"));
      final ownersResponse = await http.get(Uri.parse("$apiUrl/get-owners"));
      final adminsResponse = await http.get(Uri.parse("$apiUrl/get-admins"));
      if (usersResponse.statusCode == 200 && ownersResponse.statusCode == 200 && adminsResponse.statusCode == 200) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(json.decode(usersResponse.body));
          _owners = List<Map<String, dynamic>>.from(json.decode(ownersResponse.body));
          _admins = List<Map<String, dynamic>>.from(json.decode(adminsResponse.body));
          _filteredUsers = _users;
          _filteredOwners = _owners;
          _filteredAdmins = _admins;
        });
      }
    } catch (err) {
      print("Error loading data: $err");
    }
  }

  String decryptPassword(String encryptedText) {
    try {
      final parts = encryptedText.split(":");
      if (parts.length != 2) return "Invalid format";
      final ivHex = parts[0], encryptedHex = parts[1];
      final key = encrypt.Key.fromUtf8("sukeshpavanjayakrishnanarasaredd");
      final iv = encrypt.IV.fromBase16(ivHex);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      return encrypter.decrypt(encrypt.Encrypted.fromBase16(encryptedHex), iv: iv);
    } catch (_) { return "Error decrypting"; }
  }

  // Dialog and list item builders (see previous completions for update/delete logic...)

  Widget _buildRoleToggle() {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(16),
      fillColor: Colors.deepPurple,
      selectedColor: Colors.white,
      isSelected: [
        selectedRole == "users", selectedRole == "owners", selectedRole == "admins"
      ],
      onPressed: (i) {
        setState(() {
          selectedRole = ["users", "owners", "admins"][i];
          _searchController.clear();
        });
      },
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text("Users", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text("Owners", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text("Admins", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _listCard({required Widget leading, required String title, String? subtitle, required void Function() onTap}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: leading,
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.montserrat(fontSize: 13)) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }

  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) return Center(child: Text("No matching users found", style: GoogleFonts.montserrat()));
    return ListView.separated(
      itemCount: _filteredUsers.length,
      separatorBuilder: (_, __) => SizedBox(height: 6),
      itemBuilder: (c, i) {
        final user = _filteredUsers[i];
        return ZoomIn(
          duration: Duration(milliseconds: 220 + 40*i),
          child: _listCard(
            leading: CircleAvatar(backgroundColor: Colors.deepPurple[100], child: Icon(Icons.person, color: Colors.deepPurple)),
            title: user['email'],
            subtitle: "Password: ${decryptPassword(user['password'])}",
            onTap: () => _showDetailDialog(title: "User Details", child: _buildUserDetail(user))
          ),
        );
      },
    );
  }

  Widget _buildUserDetail(Map<String, dynamic> user) {
    return _detailCard([
      _detailLine("Email", user['email']),
      _detailLine("Password", decryptPassword(user['password'])),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _updateBtn(() { _selected = user; _updateUser(); }),
          _deleteBtn(() { _selected = user; _deleteUser(user['email']); }),
        ],
      ),
    ]);
  }

  Widget _buildOwnerList() {
    if (_filteredOwners.isEmpty) return Center(child: Text("No matching owners found", style: GoogleFonts.montserrat()));
    return ListView.separated(
      itemCount: _filteredOwners.length,
      separatorBuilder: (_, __) => SizedBox(height: 6),
      itemBuilder: (c, i) {
        final owner = _filteredOwners[i];
        return ZoomIn(
          duration: Duration(milliseconds: 240 + 40*i),
          child: _listCard(
            leading: CircleAvatar(backgroundColor: Colors.green[100], child: Icon(Icons.store, color: Colors.green)),
            title: owner['shopname'],
            subtitle: "Address: ${owner['address']}",
            onTap: () => _showDetailDialog(title: "Owner Details", child: _buildOwnerDetail(owner))
          ),
        );
      },
    );
  }

  Widget _buildOwnerDetail(Map<String, dynamic> o) {
    return _detailCard([
      _detailLine("Name", o['name']),
      _detailLine("Shop", o['shopname']),
      _detailLine("Address", o['address']),
      _detailLine("Phone", o['phone']),
      _detailLine("Username", o['username']),
      _detailLine("Password", decryptPassword(o['password'])),
      _detailLine("Latitude", o['latitude']),
      _detailLine("Longitude", o['longitude']),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _updateBtn(() { _selected = o; _updateOwner(); }),
          _deleteBtn(() { _selected = o; _deleteOwner(o['username']); }),
        ],
      ),
    ]);
  }

  Widget _buildAdminList() {
    if (_filteredAdmins.isEmpty) return Center(child: Text("No matching admins found", style: GoogleFonts.montserrat()));
    return ListView.separated(
      itemCount: _filteredAdmins.length,
      separatorBuilder: (_, __) => SizedBox(height: 6),
      itemBuilder: (c, i) {
        final admin = _filteredAdmins[i];
        return ZoomIn(
          duration: Duration(milliseconds: 260 + 45*i),
          child: _listCard(
            leading: CircleAvatar(backgroundColor: Colors.blue[100], child: Icon(Icons.admin_panel_settings, color: Colors.blue[900])),
            title: admin['username'],
            subtitle: "Password: ${decryptPassword(admin['password'])}",
            onTap: () => _showDetailDialog(title: "Admin Details", child: _buildAdminDetail(admin))
          ),
        );
      },
    );
  }

  Widget _buildAdminDetail(Map<String, dynamic> a) {
    return _detailCard([
      _detailLine("Name", a['name']),
      _detailLine("Address", a['address']),
      _detailLine("Username", a['username']),
      _detailLine("Password", decryptPassword(a['password'])),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _updateBtn(() { _selected = a; _updateAdmin(); }),
          _deleteBtn(() { _selected = a; _deleteAdmin(a['username']); }),
        ],
      ),
    ]);
  }

  Widget _detailCard(List<Widget> children) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
  Widget _detailLine(String title, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text("$title: ${value ?? 'Unknown'}", style: GoogleFonts.montserrat(fontSize: 15)),
  );
  Widget _updateBtn(VoidCallback cb) => TextButton.icon(
    icon: Icon(Icons.edit, color: Colors.deepPurple),
    label: Text('Update', style: GoogleFonts.montserrat(color: Colors.deepPurple)),
    onPressed: cb,
    style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  );
  Widget _deleteBtn(VoidCallback cb) => TextButton.icon(
    icon: Icon(Icons.delete, color: Colors.red),
    label: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red)),
    onPressed: cb,
    style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  );

  void _showDetailDialog({required String title, required Widget child}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 21)),
        content: SingleChildScrollView(child: child),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );
  }

  void _showRoleMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 21),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
              title: Text('Admin Register', style: GoogleFonts.montserrat()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/adminRegister');
              },
            ),
            ListTile(
              leading: Icon(Icons.store, color: Colors.green),
              title: Text('Owner Register', style: GoogleFonts.montserrat()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ownerRegister');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Do you want to logout?', style: GoogleFonts.montserrat()),
        actions: <Widget>[
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          FilledButton(
            child: Text('Logout'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/adminLogin');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        backgroundColor: Colors.deepPurple.withOpacity(0.93),
        elevation: 9,
        title: Text('Super Admin Dashboard', style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22,
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () => _fetchData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: Text('Add', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: () => _showRoleMenu(context),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFA7BFE8), Color(0xFFF3F8FF)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1080),
              margin: EdgeInsets.symmetric(horizontal: 7, vertical: 16),
              child: GlassCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w < 700 ? 8 : 44, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Search
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: w < 500 ? 9 : 12, horizontal: 7),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.montserrat(),
                          decoration: InputDecoration(
                            hintText: "Search by Email / Shop / Username...",
                            filled: true,
                            fillColor: Color(0xFFF9F8FB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildRoleToggle(),
                      SizedBox(height: 20),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: selectedRole == "users"
                              ? _buildUserList()
                              : selectedRole == "owners"
                                  ? _buildOwnerList()
                                  : _buildAdminList(),
                        ),
                      ),
                    ],
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

// Glassmorphism reusable card
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.93),
            borderRadius: BorderRadius.circular(19),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.07),
                blurRadius: 28,
                offset: Offset(2, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
