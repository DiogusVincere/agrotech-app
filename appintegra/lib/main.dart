import 'package:flutter/material.dart';

import 'package:appintegra/pages/atuadores_page.dart';
import 'package:appintegra/pages/chat_page.dart';
import 'package:appintegra/pages/home_page.dart';
import 'package:appintegra/pages/monitoring_page.dart';
import 'package:appintegra/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroTech',
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
      if (!mounted) return;
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

/// Uma aba da barra inferior: título, ícone e a tela que ela abre.
class _Aba {
  final String titulo;
  final IconData icone;
  final Widget pagina;

  const _Aba(this.titulo, this.icone, this.pagina);
}

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  static const List<_Aba> _abas = [
    _Aba('Atuadores', Icons.tune, AtuadoresPage()),
    _Aba('Sensores', Icons.insights, MonitoringPage()),
    _Aba('Home', Icons.home, HomePage()),
    _Aba('Chat', Icons.chat_bubble, ChatPage()),
    _Aba('Ajustes', Icons.settings, SettingsPage()),
  ];

  int _selectedIndex = 2; // começa na Home

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _item(_Aba aba) {
    Widget icone(double tamanho) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Icon(aba.icone, size: tamanho),
        );
    return BottomNavigationBarItem(
      icon: icone(24),
      activeIcon: icone(26),
      label: aba.titulo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _abas[_selectedIndex].pagina,
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
        items: _abas.map(_item).toList(),
      ),
    );
  }
}
