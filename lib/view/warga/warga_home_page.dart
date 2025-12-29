import 'package:flutter/material.dart';
import 'wallet_page.dart';
import 'mart_page.dart';
import 'transaction_history_page.dart';
import 'profile_page.dart';
import '../widgets/qr_code_dialog.dart';
import 'checkout_page.dart';
import '../widgets/eco_bottom_nav.dart';

class WargaHomePage extends StatefulWidget {
  const WargaHomePage({super.key});

  static _WargaHomePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<_WargaHomePageState>();
  }

  @override
  State<WargaHomePage> createState() => _WargaHomePageState();
}

class _WargaHomePageState extends State<WargaHomePage> {
  int _currentIndex = 1; // Start with Mart page
  bool _showCheckout = false;

  final List<Widget> _pages = const [
    WalletPage(),
    MartPage(),
    SizedBox(), // Placeholder for QR scan (center FAB)
    TransactionHistoryPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_showCheckout && index != 2) {
      setState(() {
        _showCheckout = false;
        _currentIndex = index;
      });
      return;
    }
    switchTab(index);
  }

  void switchTab(int index) {
    if (index == 2) {
      // QR scan button pressed
      _showQRCode();
      return;
    }
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void openCheckout() {
    if (_showCheckout) return;
    setState(() {
      _showCheckout = true;
    });
  }

  void closeCheckout() {
    if (!_showCheckout) return;
    setState(() {
      _showCheckout = false;
    });
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => const QRCodeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showCheckout
          ? CheckoutContent(onBack: closeCheckout)
          : IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: _currentIndex,
        centerGapAt: 2,
        notched: true,
        items: const [
          EcoNavItem(
            index: 0,
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Dompet',
          ),
          EcoNavItem(
            index: 1,
            icon: Icons.store_outlined,
            activeIcon: Icons.store,
            label: 'Mart',
          ),
          EcoNavItem(
            index: 3,
            icon: Icons.history,
            activeIcon: Icons.history,
            label: 'Riwayat',
          ),
          EcoNavItem(
            index: 4,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
          ),
        ],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQRCode,
        backgroundColor: const Color(0xFF2D9F5D),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
