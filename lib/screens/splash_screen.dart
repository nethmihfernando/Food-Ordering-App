import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'root_shell.dart';

/// Animated splash screen shown briefly on app launch, then navigates
/// automatically to the Home screen (via the bottom-nav root shell).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn));
    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      await authProvider.restoreSession();
      if (!mounted) return;

      final Widget nextScreen;
      if (authProvider.isLoggedIn) {
        final userId = authProvider.currentUser!.userId;
        context.read<CartProvider>().setUser(userId);
        context.read<OrderProvider>().setUser(userId);
        nextScreen = const RootShell();
      } else {
        nextScreen = const LoginScreen();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: nextScreen,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.delivery_dining, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fade,
                child: const Column(
                  children: [
                    Text(
                      'FastBite',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Delicious food, delivered fast.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
