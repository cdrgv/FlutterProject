import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class OwnerDashboard extends StatefulWidget {
  final String username;
  final String shopName;
  OwnerDashboard({required this.username, required this.shopName});
  @override
  _OwnerDashboardState createState() => _OwnerDashboardState();
}
class _OwnerDashboardState extends State<OwnerDashboard> {
  String _currentStatus = 'closed';
  bool _showProfilePanel = false;
  Map<String, dynamic> _ownerDetails = {};
  bool _loadingOwnerDetails = true;
  @override
  void initState() {
    super.initState();
    _fetchOwnerDetails();
    _fetchShopStatus();
  }
  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'resume':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  Future<void> _fetchOwnerDetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5002/owner/${widget.username}'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _ownerDetails = decoded;
            _loadingOwnerDetails = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching owner details: $e");
    }
  }
  Future<void> _fetchShopStatus() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5002/shop-status/${widget.username}'));

      if (response.statusCode == 200) {
        setState(() {
          _currentStatus = jsonDecode(response.body)['status'];
        });
      }
    } catch (e) {
      print("Error fetching shop status: $e");
    }
  }
  Future<void> _updateStatus(String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5002/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username, 'status': newStatus}),
      );
      if (response.statusCode == 200) {
        setState(() => _currentStatus = newStatus);
      }
    } catch (e) {
      print("Error updating status: $e");
    }
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
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showProfilePanel) {
          setState(() {
            _showProfilePanel = false;
          });
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(widget.shopName),
              leading: IconButton(
                icon: Icon(Icons.account_circle, size: 30),
                onPressed: () {
                  setState(() {
                    _showProfilePanel = !_showProfilePanel;
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
            body: Center(
              child: Container(
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(50.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Current Status",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _currentStatus.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusButton('Closed', Colors.red),
                        SizedBox(width: 15),
                        _buildStatusButton('Resume', Colors.orange),
                        SizedBox(width: 15),
                        _buildStatusButton('Open', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _showProfilePanel ? 0 : -250, 
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, 
              child: Container(
                width: 250,
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              'web/logo1.png',
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Status Hub",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _showProfilePanel = false;
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: _ownerDetails.isNotEmpty &&
                                    _ownerDetails['profileImage'] != null
                                ? NetworkImage(_ownerDetails['profileImage'])
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: _ownerDetails.isEmpty ||
                                    _ownerDetails['profileImage'] == null
                                ? Icon(Icons.person, size: 30, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Hello, ${_ownerDetails['name'] ?? 'User'}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey, thickness: 1),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings, size: 30, color: Colors.blue),
                              SizedBox(width: 5),
                              Text("Settings", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 10), 
                          Row(
                            children: [
                              Icon(Icons.help_outline, size: 30, color: Colors.green),
                              SizedBox(width: 5), 
                              Text("Help", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildStatusButton(String label, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      onPressed: () => _updateStatus(label.toLowerCase()),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}