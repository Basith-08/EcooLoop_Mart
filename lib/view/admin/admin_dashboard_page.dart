import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../viewmodel/waste_rate_viewmodel.dart';
import '../../state/user_state.dart';
import '../../state/product_state.dart';
import '../../state/waste_rate_state.dart';
import '../../data/models/user_model.dart';
import '../../data/models/waste_rate_model.dart';
import '../../data/repositories/eco_flow_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../widgets/admin_header.dart';
import '../widgets/eco_components.dart';
import '../widgets/eco_dialog.dart';
import '../widgets/logout_action.dart';
import 'report_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int? _selectedUserId;
  WasteRateModel? _selectedWasteRate;
  final _weightController = TextEditingController();
  double _estimatedPoints = 0.0;
  double _pointToRupiahRate = 150.0;
  Future<DashboardSummary>? _dashboardSummaryFuture;

  final Color _green = const Color(0xFF2D9F5D);
  final Color _orange = const Color(0xFFFF8C42);
  final Color _darkCard = const Color(0xFF0F1A28);

  @override
  void initState() {
    super.initState();
    _loadData();
    _weightController.addListener(_calculateEstimatedPoints);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _loadData() {
    Future.microtask(() {
      context.read<UserViewModel>().loadUsers();
      context.read<ProductViewModel>().loadProducts();
      context.read<WasteRateViewModel>().loadActiveWasteRates();
      _dashboardSummaryFuture = context.read<ReportRepository>().getDashboardSummary();
      context
          .read<SettingsRepository>()
          .getPointToRupiahRate()
          .then((rate) {
        if (!mounted) return;
        setState(() {
          _pointToRupiahRate = rate;
        });
        _calculateEstimatedPoints();
      });
    });
  }

  void _calculateEstimatedPoints() {
    if (_selectedWasteRate != null && _weightController.text.isNotEmpty) {
      try {
        final weight = double.parse(_weightController.text);
        final rate = _selectedWasteRate!.rupiahPerKg;
        setState(() {
          _estimatedPoints = (weight * rate) / _pointToRupiahRate;
        });
      } catch (e) {
        setState(() {
          _estimatedPoints = 0.0;
        });
      }
    } else {
      setState(() {
        _estimatedPoints = 0.0;
      });
    }
  }

  Future<void> _processDeposit() async {
    if (_selectedUserId == null) {
      await showEcoDialog(
        context,
        title: 'Data belum lengkap',
        message: 'Pilih warga terlebih dahulu sebelum memproses setoran.',
        type: EcoDialogType.warning,
      );
      return;
    }

    if (_selectedWasteRate?.id == null) {
      await showEcoDialog(
        context,
        title: 'Data belum lengkap',
        message: 'Pilih jenis sampah terlebih dahulu.',
        type: EcoDialogType.warning,
      );
      return;
    }

    if (_weightController.text.isEmpty) {
      await showEcoDialog(
        context,
        title: 'Data belum lengkap',
        message: 'Masukkan berat/jumlah setoran.',
        type: EcoDialogType.warning,
      );
      return;
    }

    try {
      final weight = double.parse(_weightController.text);
      if (weight <= 0) {
        await showEcoDialog(
          context,
          title: 'Berat tidak valid',
          message: 'Berat harus lebih dari 0.',
          type: EcoDialogType.warning,
        );
        return;
      }

      final result = await context.read<EcoFlowRepository>().processDeposit(
            userId: _selectedUserId!,
            wasteRateId: _selectedWasteRate!.id!,
            weightKg: weight,
          );

      await context.read<UserViewModel>().loadUsers();

      if (!mounted) return;

      await showEcoDialog(
        context,
        title: 'Setoran diproses',
        message:
            'Setoran ${result.wasteType} (${result.weightKg.toStringAsFixed(2)} kg) berhasil diproses.\nPoin +${result.pointsEarned.toStringAsFixed(0)}',
        type: EcoDialogType.success,
      );

      // Reset form
      setState(() {
        _selectedUserId = null;
        _selectedWasteRate = null;
        _weightController.clear();
        _estimatedPoints = 0.0;
      });
    } catch (e) {
      await showEcoDialog(
        context,
        title: 'Gagal memproses',
        message: 'Gagal memproses setoran: $e',
        type: EcoDialogType.error,
      );
    }
  }

  void _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    final productViewModel = context.watch<ProductViewModel>();
    final wasteRateViewModel = context.watch<WasteRateViewModel>();
    final adminName = authViewModel.currentUser?.name ?? 'Admin';

    // Count total warga and products
    int totalWarga = 0;
    int totalProducts = 0;

    if (userViewModel.state is UserLoaded) {
      final users = (userViewModel.state as UserLoaded).users;
      totalWarga = users.where((u) => u.role == 'warga').length;
    }

    if (productViewModel.state is ProductLoaded) {
      final products = (productViewModel.state as ProductLoaded).products;
      totalProducts = products.length;
    }

    // Get list of warga for dropdown
    List<UserModel> wargaList = [];
    if (userViewModel.state is UserLoaded) {
      wargaList = (userViewModel.state as UserLoaded)
          .users
          .where((u) => u.role == 'warga')
          .toList();
    }

    final wasteRates = wasteRateViewModel.state is WasteRateLoaded
        ? (wasteRateViewModel.state as WasteRateLoaded).rates
        : <WasteRateModel>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AdminHeader(
        adminName: adminName,
        onLogout: _handleLogout,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminTheme.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceCard(),
            const SizedBox(height: 14),
            _buildDepositCard(wargaList, wasteRates),
            const SizedBox(height: 14),
            _buildInfoCard(totalWarga, totalProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.pagePadding),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: AdminTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Performa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminReportPage(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<DashboardSummary>(
            future: _dashboardSummaryFuture,
            builder: (context, snapshot) {
              final data = snapshot.data;
              final earned = data?.pointsEarnedThisMonth ?? 0.0;
              final spent = data?.pointsSpentThisMonth ?? 0.0;
              final count = data?.transactionCountThisMonth ?? 0;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _miniStat(
                          'Poin Dihasilkan',
                          '+${earned.toStringAsFixed(0)}',
                          _green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniStat(
                          'Poin Ditukar',
                          '-${spent.toStringAsFixed(0)}',
                          _orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.bolt,
                          size: 16, color: Colors.lightBlueAccent),
                      const SizedBox(width: 6),
                      Text(
                        '$count transaksi tercatat bulan ini',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositCard(List<UserModel> wargaList, List<WasteRateModel> rates) {
    return EcoCard(
      padding: const EdgeInsets.all(AdminTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.recycling, color: Color(0xFF2D9F5D)),
              SizedBox(width: 8),
              Text(
                'Input Setoran (Manual)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'PILIH WARGA',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9AA2AF),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedUserId,
                hint: const Text('-- Pilih Akun --'),
                items: wargaList
                    .map((user) => DropdownMenuItem<int>(
                          value: user.id,
                          child: Text(user.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'JENIS SAMPAH',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9AA2AF),
            ),
          ),
          const SizedBox(height: 8),
          if (rates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada master jenis sampah.',
                style: TextStyle(color: Color(0xFF9AA2AF), fontSize: 12),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: rates.map((rate) {
                  final isSelected = _selectedWasteRate?.id == rate.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWasteRate = rate;
                      });
                      _calculateEstimatedPoints();
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: width,
                        maxWidth: width,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _green.withOpacity(0.08)
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? _green : const Color(0xFFE5E7EB),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rate.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? _green
                                    : const Color(0xFF1F2430),
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${rate.rupiahPerKg.toInt()}/kg',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isSelected
                                    ? _green
                                    : const Color(0xFF9AA2AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'BERAT / JUMLAH (KG)',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9AA2AF),
            ),
          ),
          const SizedBox(height: 8),
          EcoInputField(
            controller: _weightController,
            hint: '0.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            fillColor: const Color(0xFFF9FAFB),
            borderColor: const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimasi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_estimatedPoints.toInt()} Poin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          EcoPrimaryButton(
            label: 'Proses Setoran',
            onPressed: _processDeposit,
            color: _green,
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(int totalWarga, int totalProducts) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.pagePadding),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: AdminTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'EcoLoop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '-Mart',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Ver 2.1',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Platform manajemen limbah terintegrasi dengan sistem poin belanja sembako. Kini lebih canggih dengan fitur analitik real-time.',
            style: TextStyle(color: Colors.white70, height: 1.3, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _InfoPill(label: 'Smart Analytics', icon: Icons.auto_graph),
              _InfoPill(label: 'Top Leaderboard', icon: Icons.leaderboard),
              _InfoPill(label: 'Mitra Connect', icon: Icons.handshake_outlined),
              _InfoPill(label: 'Fast Transaction', icon: Icons.flash_on),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _smallStat('Warga', '$totalWarga'),
              const SizedBox(width: 12),
              _smallStat('Barang', '$totalProducts'),
            ],
          )
        ],
      ),
    );
  }

  Widget _smallStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
