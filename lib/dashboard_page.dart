import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Map<String, String>? _selectedShop;
  bool _showIcons = false;
  Future<void> _searchShops(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final response =
        await http.get(Uri.parse('http://localhost:5002/search?shopname=$query'));

    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body);
      });
    } else {
      print('Failed to fetch shops');
    }
  }
  void sendSms(String phoneNumber) async {
    final Uri smsUri = Uri.parse(
        'https://messages.google.com/web/conversations/new?recipient=$phoneNumber');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print("Could not open Google Messages Web");
    }
  }
  void _callPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("Could not launch dialer");
    }
  }
  void openGoogleMaps(String latitude, String longitude) async {
    final Uri googleMapsUri =
        Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      print("Could not open Google Maps");
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
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        leading: SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showLogoutDialog(context);
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
              onChanged: _searchShops,
            ),
            SizedBox(height: 10),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final shop = _searchResults[index];
                        return ListTile(
                          title: Text(shop['shopname']),
                          subtitle: Text(shop['address']),
                          onTap: () {
                            setState(() {
                              _selectedShop = {
                                'shopname': shop['shopname'],
                                'address': shop['address'],
                                'status': shop['status'],
                                'phone': shop['phone'],
                                'latitude': shop['latitude'],  // Store latitude
                                'longitude': shop['longitude'] // Store longitude
                              };
                              _searchResults = [];
                              _searchController.clear();
                            });
                          },
                        );
                      },
                    )
                  : _selectedShop != null
                      ? _buildSelectedShopCard()
                      : Center(child: Text('Search and select a shop')),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSelectedShopCard() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Padding(
          padding: EdgeInsets.only(bottom: _showIcons ? 350 : 400),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            title: Text(
              _selectedShop!['shopname']!,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedShop!['address']!,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Text("Status: "),
                    Text(
                      "${_selectedShop!['status']!}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedShop!['status'] == "resume"
                            ? Colors.yellow
                            : (_selectedShop!['status'] == "open"
                                ? Colors.green
                                : Colors.red),
                      ),
                    ),
                  ],
                ),
                if (_showIcons)
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: _buildActionIcons(),
                  ),
              ],
            ),
            onTap: () {
              setState(() {
                _showIcons = !_showIcons;
              });
            },
          ),
        ),
      ),
    );
  }
  Widget _buildActionIcons() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionIcon(Icons.message, 'Message', () {
            if (_selectedShop != null && _selectedShop!['phone'] != null) {
              sendSms(_selectedShop!['phone']!);
            }
          }),
          _actionIcon(Icons.location_on, 'Location', () {
            if (_selectedShop != null &&
                _selectedShop!['latitude'] != null &&
                _selectedShop!['longitude'] != null) {
              openGoogleMaps(
                _selectedShop!['latitude']!,
                _selectedShop!['longitude']!
              );
            } else {
              print("Latitude and Longitude not available");
            }
          }),
          _actionIcon(Icons.phone, 'Phone', () {
            if (_selectedShop != null && _selectedShop!['phone'] != null) {
              _callPhoneNumber(_selectedShop!['phone']!);
            }
          }),
          _actionIcon(Icons.info, 'About', () {
            print("About tapped");
          }),
        ],
      ),
    );
  }
  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}