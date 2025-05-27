import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import 'register_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _otherKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 30),
            Image.asset('web/logo1.png', height: 40),
            SizedBox(width: 30),
            _buildNavButton("Home", _homeKey),
            _buildNavButton("Our Services", _aboutKey),
            _buildNavButton("About us", _otherKey),
          ],
        ),
        actions: [
          HoverMenuButton(),
        ],
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HomeSection(homeKey: _homeKey),
            AboutSection(aboutKey: _aboutKey),
            OtherSection(otherKey: _otherKey),
            FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, GlobalKey key) {
    return TextButton(
      onPressed: () => _scrollToSection(key),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 18,fontFamily: 'TimesNewRoman'),
      ),
    );
  }
}

class HoverMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.person, color: Colors.white),
      onSelected: (value) {
        Navigator.pushNamed(context, value == 0 ? '/login' : '/register');
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Login'),
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Register'),
          ),
        ),
      ],
    );
  }
}

class HomeSection extends StatelessWidget {
  final GlobalKey homeKey;
  const HomeSection({required this.homeKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: homeKey,
      children: [
        SizedBox(height: 50),
        ImageSlider(),
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              Text(
                "Welcome to Our Website!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,fontFamily: 'TimesNewRoman'),
              ),
              SizedBox(height: 10),
              Text(
                "Your time is valuable—make the most of it with instant store status updates! No more arriving at closed shops or searching endlessly for open stores."
                 "With real-time tracking and smart search features, you’ll always know where to go and when. Shop smarter, plan better, and enjoy a stress-free experience every time!",
                style: TextStyle(fontSize: 18,fontFamily: 'TimesNewRoman'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  final GlobalKey aboutKey;
  const AboutSection({required this.aboutKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: aboutKey,
      padding: EdgeInsets.all(50),
      child: Column(
        children: [
          Text(
            "Our Services",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,fontFamily: 'TimesNewRoman'),
          ),
          SizedBox(height: 10),
          Text(
            "Discover a smarter way to navigate your local shopping scene. Our platform offers real-time insights into the operating status of nearby stores, "
            "providing instant updates on whether shops are open, closed, or resuming services. Explore the convenience of knowing before you go, saving you valuable time and effort. Stay informed and connected to your local community by easily accessing the latest"
            "information on store availability at your fingertips. Experience efficient planning and effortless local exploration with the benefits of real-time information for your everyday needs.",
            style: TextStyle(fontSize: 18,fontFamily: 'TimesNewRoman'),
          ),
        ],
      ),
    );
  }
}

class OtherSection extends StatelessWidget {
  final GlobalKey otherKey;
  const OtherSection({required this.otherKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: otherKey,
      padding: EdgeInsets.all(50),
      child: Column(
        children: [
          Text(
            "About us",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,fontFamily: 'TimesNewRoman'),
          ),
          SizedBox(height: 10),
          Text(
            "Tired of wasted trips to closed stores? Get instant updates on local shop statuses right at your fingertips. Know if your favorite businesses are open, closed, or have just resumed operations."

"Easily browse and search for shops by category to find exactly what you're looking for. Save valuable time and effort by checking the status before you head out."

"Plan your day more efficiently, knowing which shops in your area are currently available. Stay informed about temporary closures and reopenings in your local vicinity."

"Connect with the businesses in your community and support local commerce with this convenient service. Access real-time information about store availability with ease."

"Experience a smarter way to shop and explore your local area. Get the information you need, when you need it, about the stores around you.",
            style: TextStyle(fontSize: 18,fontFamily: 'TimesNewRoman'),
          ),
        ],
      ),
    );
  }
}

class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isForward = true; // Determines the scrolling direction
  final List<String> images = ['web/status.jpg', 'web/x.jpg', 'web/y.jpg', 'web/z.jpg'];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_isForward) {
        if (_currentPage < images.length - 1) {
          _currentPage++;
        } else {
          _isForward = false; // Reverse direction
          _currentPage--;
        }
      } else {
        if (_currentPage > 0) {
          _currentPage--;
        } else {
          _isForward = true; // Forward direction
          _currentPage++;
        }
      }

      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500), // Smooth transition
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 700,
        width: 1500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 3,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                fit: BoxFit.cover, 
                width: double.infinity,
                height: 400,
              );
            },
          ),
        ),
      ),
    );
  }
}
class FooterSection extends StatelessWidget {
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.blueGrey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSocialIcon('web/facebook.png', 'https://www.facebook.com'),
          SizedBox(width: 20),
          _buildSocialIcon('web/xlogo.png', 'https://www.twitter.com'),
          SizedBox(width: 20),
          _buildSocialIcon('web/youtube.png', 'https://www.youtube.com'),
          SizedBox(width: 20),
          _buildSocialIcon('web/github.png', 'https://www.github.com'),
          SizedBox(width: 20),
          _buildSocialIcon('web/instagram.png', 'https://www.instagram.com'),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Image.asset(
        assetPath,
        width: 40,
        height: 40,
      ),
    );
  }
}
