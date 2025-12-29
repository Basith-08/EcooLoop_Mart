import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/settings_repository.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/wallet_viewmodel.dart';
import '../../state/wallet_state.dart';
import '../widgets/qr_code_dialog.dart';
import '../widgets/eco_user_app_bar.dart';
import '../widgets/logout_action.dart';
import 'mart_page.dart';
import 'warga_home_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double _pointToRupiahRate = 150.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) {
      Future.microtask(() {
        context.read<WalletViewModel>().loadWallet(userId);
        context.read<SettingsRepository>().getPointToRupiahRate().then((rate) {
          if (!mounted) return;
          setState(() {
            _pointToRupiahRate = rate;
          });
        });
      });
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => const QRCodeDialog(),
    );
  }

  void _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final walletViewModel = context.watch<WalletViewModel>();
    final userName = authViewModel.currentUser?.name ?? 'User';

    double ecoPoints = 0.0;
    double rupiahValue = 0.0;

    if (walletViewModel.state is WalletLoaded) {
      final wallet = (walletViewModel.state as WalletLoaded).wallet;
      ecoPoints = wallet.ecoPoints;
      rupiahValue = wallet.rupiahValue;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: EcoUserAppBar(
        subtitle: 'Halo, $userName',
        onLogout: _handleLogout,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D9F5D), Color(0xFF1E7A44)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D9F5D).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.recycling,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SALDO ECOPOIN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (walletViewModel.state is WalletLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${ecoPoints.toInt()}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'pts',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '≈ Rp ${rupiahValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.qr_code,
                      label: 'ID Member',
                      onTap: _showQRCode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.store,
                      label: 'Tukar Poin',
                      onTap: () {
                        final homeState = WargaHomePage.of(context);
                        if (homeState != null) {
                          homeState.switchTab(1);
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MartPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Info Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tentang EcoPoin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.recycling,
                      title: 'Kumpulkan Poin',
                      description: 'Setor sampah untuk mendapatkan poin',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.shopping_bag,
                      title: 'Tukar Sembako',
                      description: 'Gunakan poin untuk belanja di mart',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.monetization_on,
                      title: 'Nilai Konversi',
                      description:
                          '1 Poin = Rp ${_pointToRupiahRate.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D9F5D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Hemat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D9F5D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kumpulkan sampah secara rutin untuk mendapatkan lebih banyak poin!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF2D9F5D),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF2D9F5D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
