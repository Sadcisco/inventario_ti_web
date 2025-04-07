import 'package:flutter/material.dart';
import 'screens/dashboard_page.dart';
import 'theme/app_theme.dart';
import 'views/login_page.dart';
import 'services/auth_service.dart';
import 'dart:async';

void main() {
  runApp(const InventarioTIApp());
}

class InventarioTIApp extends StatefulWidget {
  const InventarioTIApp({super.key});

  @override
  _InventarioTIAppState createState() => _InventarioTIAppState();
}

class _InventarioTIAppState extends State<InventarioTIApp> {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuthenticated = await _authService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario TI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isAuthenticated
              ? const DashboardPage()
              : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
