import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fullstack_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:fullstack_app/features/auth/presentation/screens/login_screen.dart';
import 'package:fullstack_app/app/home_shell.dart';

/// Decides which screen to show first based on whether a session is
/// already persisted locally (JWT still present in Hive).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const HomeShell();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
