import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
class SuperAdminPage extends StatefulWidget {
  @override
  _SuperAdminPageState createState() => _SuperAdminPageState();
}
class _SuperAdminPageState extends State<SuperAdminPage> {
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedOwner;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _owners = [];
  List<Map<String, dynamic>> _admins = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _filteredOwners = [];
  List<Map<String, dynamic>> _filteredAdmins = [];
  String selectedRole = "users"; 
  final String apiUrl = "http://localhost:5002"; 
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
    setState(() {
      if (selectedRole == "users") {
        _filteredUsers = _searchController.text.isEmpty
            ? _users
            : _users
                .where((user) =>
                    user['email'].toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();
      } else if (selectedRole == "owners") {
        _filteredOwners = _searchController.text.isEmpty
            ? _owners
            : _owners
                .where((owner) =>
                    owner['shopname'].toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();
      } else if (selectedRole == "admins") {
        _filteredAdmins = _searchController.text.isEmpty
            ? _admins
            : _admins
                .where((admin) =>
                    admin['username'].toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();
      }
    });
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
  Future<void> _deleteOwner(String username) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete Owner'),
        content: Text('Are you sure you want to delete this owner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
  if (!confirmDelete) return;
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleting owner...')),
    );
    final response = await http.delete(Uri.parse("$apiUrl/delete-owner/$username"));
    if (response.statusCode == 200) {
      setState(() {
        _admins.removeWhere((owner) => owner['username'] == username);
        _filteredAdmins.removeWhere((owner) => owner['username'] == username);
        _selectedOwner = null; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Owner deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete owner')));
    }
  } catch (error) {
    print("Error deleting owner: $error");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting owner')));
  }
}
  Future<void> _deleteUser(String email) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
  if (!confirmDelete) return;
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleting user...')),
    );
    final response = await http.delete(Uri.parse("$apiUrl/delete-user/$email"));
    if (response.statusCode == 200) {
      setState(() {
        _admins.removeWhere((user) => user['email'] == email);
        _filteredAdmins.removeWhere((user) => user['email'] == email);
        _selectedOwner = null; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user')));
    }
  } catch (error) {
    print("Error deleting user: $error");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting user')));
  }
}
  Future<void> _deleteAdmin(String username) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete Admin'),
        content: Text('Are you sure you want to delete this admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
  if (!confirmDelete) return;
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleting admin...')),
    );
    final response = await http.delete(Uri.parse("$apiUrl/delete-admin/$username"));
    if (response.statusCode == 200) {
      setState(() {
        _admins.removeWhere((admin) => admin['username'] == username);
        _filteredAdmins.removeWhere((admin) => admin['username'] == username);
        _selectedOwner = null; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete admin')));
    }
  } catch (error) {
    print("Error deleting admin: $error");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting admin')));
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
  Future<void> _fetchData() async {
    try {
      final usersResponse = await http.get(Uri.parse("$apiUrl/get-users"));
      final ownersResponse = await http.get(Uri.parse("$apiUrl/get-owners"));
      final adminsResponse = await http.get(Uri.parse("$apiUrl/get-admins"));
      if (usersResponse.statusCode == 200 &&
          ownersResponse.statusCode == 200 &&
          adminsResponse.statusCode == 200) {
        final usersData = json.decode(usersResponse.body);
        final ownersData = json.decode(ownersResponse.body);
        final adminsData = json.decode(adminsResponse.body);
        setState(() {
          _users = usersData is List ? List<Map<String, dynamic>>.from(usersData) : [];
          _owners = ownersData is List ? List<Map<String, dynamic>>.from(ownersData) : [];
          _admins = adminsData is List ? List<Map<String, dynamic>>.from(adminsData) : [];
          _filteredUsers = _users; 
          _filteredOwners = _owners;
          _filteredAdmins = _admins;
        });
      } else {
        print("Failed to fetch data. Status codes: Users(${usersResponse.statusCode}), Owners(${ownersResponse.statusCode}), Admins(${adminsResponse.statusCode})");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }
  Widget _buildUserCard(Map<String, dynamic> user) {
    final String email = user['email']?.toString() ?? "Unknown";
    final String encryptedPassword = user['password']?.toString() ?? "Unknown";
    final String password = decryptPassword(encryptedPassword);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6, 
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text(email),
                subtitle: Text("Password: $password"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _selectedOwner = user; 
                      _updateUser(); 
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Update", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectedOwner = user; 
                      _deleteUser(user['email']); 
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOwnerCard(Map<String, dynamic> owner) {
    final String name = owner['name']?.toString() ?? "Unknown";
    final String shopName = owner['shopname']?.toString() ?? "Unknown";
    final String address = owner['address']?.toString() ?? "Unknown";
    final String phone = owner['phone']?.toString() ?? "Unknown";
    final String username = owner['username']?.toString() ?? "Unknown";
    final String encryptedPassword = owner['password']?.toString() ?? "Unknown";
    final String password = decryptPassword(encryptedPassword);
    final String latitude = owner['latitude']?.toString() ?? "Unknown";
    final String longitude = owner['longitude']?.toString() ?? "Unknown";
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Owner Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.store, color: Colors.green),
                title: Text("$name - $shopName"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address: $address"),
                    Text("Phone Number: $phone"),
                    Text("Username: $username"),
                    Text("Password: $password"),
                    Text("Latitude: $latitude"),
                    Text("Longitude: $longitude"),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _selectedOwner = owner; 
                      _updateOwner(); 
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Update", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectedOwner = owner; 
                      _deleteOwner(owner['username']); 
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildAdminCard(Map<String, dynamic> admin) {
    final String name = admin['name']?.toString() ?? "Unknown";
    final String address = admin['address']?.toString() ?? "Unknown";
    final String username = admin['username']?.toString() ?? "Unknown";
    final String encryptedPassword = admin['password']?.toString() ?? "Unknown";
    final String password = decryptPassword(encryptedPassword);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address: $address"),
                    Text("Username: $username"),
                    Text("Password: $password"),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                       _selectedOwner = admin; 
                      _updateAdmin(); 
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Update", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectedOwner = admin; 
                      _deleteAdmin(admin['username']);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoleButton("users"),
                _buildRoleButton("owners"),
                _buildRoleButton("admins"),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: selectedRole == "users"
                  ? _buildUserList()
                  : selectedRole == "owners"
                      ? _buildOwnerList()
                      : _buildAdminList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.more_vert),
        onPressed: () {
          _showRoleMenu(context);
        },
      ),
    );
  }
  Widget _buildRoleButton(String role) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedRole = role;
          _searchController.clear(); 
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedRole == role ? Colors.blue : Colors.grey,
      ),
      child: Text(role),
    );
  }
  Widget _buildUserList() {
    return _filteredUsers.isEmpty
        ? Center(child: Text("No matching users found"))
        : ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return ListTile(
                title: Text(user['email']),
                subtitle: Text("Password: ${decryptPassword(user['password'])}"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("User Details"),
                        content: _buildUserCard(user),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
  }
  Widget _buildOwnerList() {
    return _filteredOwners.isEmpty
        ? Center(child: Text("No matching owners found"))
        : ListView.builder(
            itemCount: _filteredOwners.length,
            itemBuilder: (context, index) {
              final owner = _filteredOwners[index];
              return ListTile(
                title: Text(owner['shopname']),
                subtitle: Text("Address: ${owner['address']}"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Owner Details"),
                        content: _buildOwnerCard(owner),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
  }
  Widget _buildAdminList() {
    return _filteredAdmins.isEmpty
        ? Center(child: Text("No matching admins found"))
        : ListView.builder(
            itemCount: _filteredAdmins.length,
            itemBuilder: (context, index) {
              final admin = _filteredAdmins[index];
              return ListTile(
                title: Text(admin['username']),
                subtitle: Text("Password: ${decryptPassword(admin['password'])}"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Admin Details"),
                        content: _buildAdminCard(admin),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
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
            title: Text('Admin Register'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/adminRegister');
            },
          ),
        ),
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
}