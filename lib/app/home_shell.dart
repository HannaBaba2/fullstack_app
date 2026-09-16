import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fullstack_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:fullstack_app/features/auth/presentation/screens/login_screen.dart';
import 'package:fullstack_app/features/posts/presentation/screens/posts_screen.dart';
import 'package:fullstack_app/features/albums/presentation/screens/albums_screen.dart';
import 'package:fullstack_app/features/todos/presentation/screens/todos_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [PostsScreen(), AlbumsScreen(), TodosScreen()];

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(auth.user?.email ?? 'App'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.photo_album_outlined), label: 'Albums'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Todos'),
        ],
      ),
    );
  }
}
