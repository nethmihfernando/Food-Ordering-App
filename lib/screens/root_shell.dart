import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';

/// Bottom navigation bar and switches between the three
/// primary tabs: Home, Cart, and Orders.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  /// Lets other screens (e.g. after checkout) switch RootShell's tab
  /// without pushing a whole new screen and losing the bottom nav.
  static final ValueNotifier<int> selectedTab = ValueNotifier(0);

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    RootShell.selectedTab.value = 0;
    RootShell.selectedTab.addListener(_onExternalTabChange);
  }

  @override
  void dispose() {
    RootShell.selectedTab.removeListener(_onExternalTabChange);
    super.dispose();
  }

  void _onExternalTabChange() {
    _selectTab(RootShell.selectedTab.value);
  }

  void _selectTab(int i) {
    setState(() => _index = i);
    if (i == 1) {
      context.read<CartProvider>().loadCart();
    } else if (i == 2) {
      context.read<OrderProvider>().loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) {
              RootShell.selectedTab.value = i;
              _selectTab(i);
            },
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Badge(
                  label: Text('${cart.itemCount}'),
                  isLabelVisible: cart.itemCount > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('${cart.itemCount}'),
                  isLabelVisible: cart.itemCount > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Cart',
              ),
              const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
            ],
          );
        },
      ),
    );
  }
}
