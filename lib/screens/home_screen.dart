import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import 'list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final name = await AuthService.currentUsername();
    await FavoriteService.instance.load(name); // muat favourite milik user ini
    if (mounted) setState(() => username = name);
  }

  void _logout() async {
    await AuthService.logout();
    FavoriteService.instance.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _menuCard(
      IconData icon, String title, String desc, String type, String label) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 36, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListScreen(title: label, type: type)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hai, $username!')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(Icons.newspaper, 'News',
              'Get an overview of the latest SpaceFlight news, from various sources!',
              'articles', 'News'),
          _menuCard(Icons.article_outlined, 'Blog',
              'Blogs often provide a more detailed overview of launches and missions.',
              'blogs', 'Blog'),
          _menuCard(Icons.bar_chart, 'Reports',
              'Space stations and other missions often publish their data.',
              'reports', 'Reports'),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _logout,
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}
