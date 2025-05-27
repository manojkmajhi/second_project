import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:second_project/pages/cart.dart';
import 'package:second_project/pages/home.dart';
import 'package:second_project/pages/order.dart';
import 'package:second_project/pages/profile.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;
  const BottomNav({super.key, this.initialIndex = 0}); // ✅ Accept initial tab index

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;
  late Home homePage;
  late Order orderPage;
  late CartPage cart;
  late Profile profile;
  late int currentTabIndex;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialIndex; 
    homePage = Home();
    orderPage = Order();
    cart = CartPage();
    profile = Profile();
    pages = [
      homePage,
      orderPage,
      cart,
      profile,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentTabIndex, children: pages),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: currentTabIndex,
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.shopping_bag, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
      ),
    );
  }
}
