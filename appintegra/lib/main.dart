import 'package:flutter/material.dart';
import 'package:appintegra/pages/home.dart';
import 'package:appintegra/pages/AtuadoresPage.dart';
import 'package:appintegra/pages/ChatPage.dart';
import 'package:appintegra/pages/MonitoringPage.dart';
import 'package:appintegra/pages/SettingsPage.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agro IoT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavbarPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0D25),
              Color(0xFF4B0082),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.memory_outlined,
                  size: 90,
                  color: Colors.deepPurpleAccent.shade100,
                ),
                const SizedBox(height: 20),
                Text(
                  'AgroTech',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurpleAccent.shade100,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By: D3G Technology',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurpleAccent.shade200.withOpacity(0.7),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  _NavbarPageState createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 2;

  static const List<Widget> _widgetOptions = <Widget>[
    AtuadoresPage(),
    MonitoringPage(),
    HomePage(),
    ChatPage(),
    SettingsPage(),
  ];

  final List<String> _titles = [
    'Atuadores',
    'Sensores',
    'Home',
    'Chat',
    'Ajustes',
  ];

  final List<IconData> _icons = [
    Icons.tune,
    Icons.insights,
    Icons.home,
    Icons.chat_bubble,
    Icons.settings,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: _buildCupertinoTabBar(),
    );
  }

  Widget _buildCupertinoTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[0], size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[0], size: 26),
            ),
            label: _titles[0],
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[1], size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[1], size: 26),
            ),
            label: _titles[1],
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[2], size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[2], size: 26),
            ),
            label: _titles[2],
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[3], size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[3], size: 26),
            ),
            label: _titles[3],
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[4], size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(_icons[4], size: 26),
            ),
            label: _titles[4],
          ),
        ],
      ),
    );
  }
}
