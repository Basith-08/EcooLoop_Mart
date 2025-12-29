import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_account_page.dart';
import 'admin_warehouse_page.dart';
import '../widgets/eco_bottom_nav.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    AdminAccountPage(),
    AdminWarehousePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: _currentIndex,
        activeColor: const Color(0xFFFF8C42),
        items: const [
          EcoNavItem(
            index: 0,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          EcoNavItem(
            index: 1,
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Akun',
          ),
          EcoNavItem(
            index: 2,
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Gudang',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
