import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

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
    final response = await http.get(Uri.parse('http://localhost:5002/search?shopname=$query'));
    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body);
      });
    } else {
      _showSnackbar("Failed to fetch shops");
    }
  }

  void sendSms(String phoneNumber) async {
    final Uri smsUri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      _showSnackbar("Could not open SMS app");
    }
  }

  void _callPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackbar("Could not launch dialer");
    }
  }

  void openGoogleMaps(String latitude, String longitude) async {
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      _showSnackbar("Could not open Google Maps");
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text('Do you want to logout?', style: GoogleFonts.montserrat()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutShopDialog() {
    if (_selectedShop == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_selectedShop!['shopname']} - Details', style: GoogleFonts.montserrat()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.location_on, _selectedShop!['address']!),
            _infoRow(Icons.phone, _selectedShop!['phone']!),
            if (_selectedShop!['latitude'] != null && _selectedShop!['longitude'] != null)
              _infoRow(Icons.map, "Lat: ${_selectedShop!['latitude']}\nLng: ${_selectedShop!['longitude']}"),
            SizedBox(height: 10),
            _infoRow(Icons.info_outline, "Status: ${_selectedShop!['status']}"),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Close", style: GoogleFonts.montserrat()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.montserrat(fontSize: 14))),
      ],
    ),
  );

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.montserrat())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0.92),
        title: Text('User Dashboard', style: GoogleFonts.montserrat(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () { _showLogoutDialog(context); },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient BG
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (w > 500)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.25, -0.3),
                      radius: 1.2,
                      colors: [
                        Colors.deepPurple.withOpacity(0.08),
                        Colors.white.withOpacity(0.84),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              child: FadeInDown(
                duration: Duration(milliseconds: 700),
                child: Container(
                  width: w < 450 ? w * 0.98 : w < 800 ? w * 0.65 : 600,
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: w < 500 ? 13 : 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.13),
                          blurRadius: 16,
                          offset: Offset(2, 6))
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.montserrat(),
                          decoration: InputDecoration(
                            hintText: 'Search shop by name...',
                            labelText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Color(0xFFf8f2fa),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                          ),
                          onChanged: _searchShops,
                        ),
                      ),
                      SizedBox(height: 14),
                      // Dynamic Search Results or Shop Card
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 420),
                        child: _searchResults.isNotEmpty
                            ? ListView.separated(
                                key: ValueKey("resultList"),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (_, __) => SizedBox(height: 4),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final shop = _searchResults[index];
                                  return ZoomIn(
                                    duration: Duration(milliseconds: 340 + 45 * index),
                                    child: Card(
                                      color: Colors.deepPurple[50],
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.deepPurple[100],
                                          child: Icon(Icons.store, color: Colors.deepPurple),
                                        ),
                                        title: Text(shop['shopname'], style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                                        subtitle: Text(shop['address'], style: GoogleFonts.montserrat(fontSize: 13)),
                                        trailing: Icon(Icons.arrow_forward_ios, size: 15, color: Colors.deepPurple),
                                        onTap: () {
                                          setState(() {
                                            _selectedShop = {
                                              'shopname': shop['shopname'],
                                              'address': shop['address'],
                                              'status': shop['status'],
                                              'phone': shop['phone'],
                                              'latitude': shop['latitude'],
                                              'longitude': shop['longitude'],
                                            };
                                            _showIcons = true;
                                            _searchResults = [];
                                            _searchController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )
                            : _selectedShop != null
                                ? _buildSelectedShopCard()
                                : Center(
                                    key: ValueKey("empty"),
                                    child: Text(
                                      'Search and select a shop',
                                      style: GoogleFonts.montserrat(color: Colors.grey[600]),
                                    ),
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

  Widget _buildSelectedShopCard() {
    final status = _selectedShop!['status']!;
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'resume':
        statusColor = Colors.amber.shade700;
        statusLabel = "Resumed";
        break;
      case 'open':
        statusColor = Colors.green.shade600;
        statusLabel = "Open";
        break;
      default:
        statusColor = Colors.redAccent.shade700;
        statusLabel = "Closed";
    }
    return FadeIn(
      duration: Duration(milliseconds: 600),
      child: Card(
        elevation: 7,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.deepPurple[50],
                    child: Icon(Icons.store, size: 27, color: Colors.deepPurple),
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedShop!['shopname']!, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(_selectedShop!['address'] ?? '', style: GoogleFonts.montserrat(fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.montserrat(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 30),
              _showIcons
                  ? _buildActionIcons()
                  : Center(
                      child: OutlinedButton.icon(
                        onPressed: () { setState(() => _showIcons = true); },
                        icon: Icon(Icons.expand_more, color: Colors.deepPurple),
                        label: Text("Actions", style: GoogleFonts.montserrat()),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                      ),
                    ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
                  label: Text('Back', style: GoogleFonts.montserrat()),
                  onPressed: () =>
                      setState(() {
                        _selectedShop = null;
                        _showIcons = false;
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcons() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.08),
                blurRadius: 11,
                offset: Offset(1, 5),
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                    _selectedShop!['longitude']!,
                  );
                } else {
                  _showSnackbar("Location not available");
                }
              }),
              _actionIcon(Icons.phone, 'Call', () {
                if (_selectedShop != null && _selectedShop!['phone'] != null) {
                  _callPhoneNumber(_selectedShop!['phone']!);
                }
              }),
              _actionIcon(Icons.info, 'About', () {
                _showAboutShopDialog();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.deepPurple.withOpacity(0.14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple[100],
            radius: 20,
            child: Icon(icon, color: Colors.deepPurple, size: 24),
          ),
          SizedBox(height: 4),
          Text(label, style: GoogleFonts.montserrat(fontSize: 13)),
        ],
      ),
    );
  }
}
