import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fullstack_app/core/di/injector.dart';
import 'package:fullstack_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:fullstack_app/features/posts/presentation/providers/posts_provider.dart';
import 'package:fullstack_app/features/albums/presentation/providers/albums_provider.dart';
import 'package:fullstack_app/features/todos/presentation/providers/todos_provider.dart';
import 'package:fullstack_app/app/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: sl<AuthProvider>()),
        ChangeNotifierProvider<PostsProvider>(create: (_) => sl<PostsProvider>()),
        ChangeNotifierProvider<AlbumsProvider>(create: (_) => sl<AlbumsProvider>()),
        ChangeNotifierProvider<TodosProvider>(create: (_) => sl<TodosProvider>()),
      ],
      child: MaterialApp(
        title: 'Certification Flutter - App connectee',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}
