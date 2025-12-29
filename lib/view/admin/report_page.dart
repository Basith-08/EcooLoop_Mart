import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/report_repository.dart';
import '../widgets/eco_components.dart';
import 'pengrajin_sampah_page.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  late Future<AdminReportData> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ReportRepository>().getAdminReportData();
  }

  void _reload() {
    setState(() {
      _future = context.read<ReportRepository>().getAdminReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFF),
        elevation: 0,
        toolbarHeight: 52,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2430)),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        centerTitle: true,
        titleSpacing: 0,
        title: const Text(
          'Laporan Analitik',
          style: TextStyle(
            color: Color(0xFF1F2430),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<AdminReportData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Gagal memuat laporan: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data!;
          final stockHealthColor =
              data.stockHealthPercent >= 70 ? Colors.green : const Color(0xFFFCB045);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _MetricCard(
                          title: 'TOTAL SAMPAH',
                          value: '${data.totalWasteKg.toStringAsFixed(1)} Kg',
                          subtitle: 'Akumulasi seumur hidup',
                          color: const Color(0xFF14A44D),
                        ),
                        const SizedBox(width: 10),
                        _MetricCard(
                          title: 'TRANSAKSI',
                          value: '${data.totalTransactions}',
                          subtitle: 'Setoran & Penukaran',
                          color: const Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    EcoCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ANALISIS SAMPAH',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2430),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AnalysisRow(
                            icon: Icons.inventory_2_outlined,
                            title: 'Jenis Terbanyak',
                            value: data.topWasteType ?? '-',
                            badge: data.topWasteType == null ? null : 'Dominan',
                            iconBg: const Color(0xFFFFF3E6),
                            iconColor: const Color(0xFFF08A24),
                          ),
                          const SizedBox(height: 8),
                          _AnalysisRow(
                            icon: Icons.calendar_today_outlined,
                            title: 'Setoran Bulan Ini',
                            value: '${data.depositCountThisMonth} Transaksi',
                            trailing: '${data.activeWargaPercentThisMonth}% aktif',
                            iconBg: const Color(0xFFE8F5E9),
                            iconColor: const Color(0xFF2D9F5D),
                          ),
                          const SizedBox(height: 8),
                          _AnalysisRow(
                            icon: Icons.verified_user_outlined,
                            title: 'Konsistensi Warga',
                            value: '${data.activeWargaPercentThisMonth}% Aktif',
                            trailing: 'Min. 1x transaksi/bulan',
                            iconBg: const Color(0xFFE7F0FF),
                            iconColor: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    EcoCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EKOSISTEM POIN & STOK',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2430),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _SimpleBox(
                                  title: 'Poin Beredar',
                                  value: data.pointsCirculating.toStringAsFixed(0),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SimpleBox(
                                  title: 'Poin Ditukar',
                                  value: data.pointsSpent.toStringAsFixed(0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _LabelValue(
                            'Stok Menipis',
                            '${data.lowStockCount} item',
                            valueColor: const Color(0xFFFCB045),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: data.stockHealthPercent / 100,
                            backgroundColor: const Color(0xFFECEFF5),
                            color: stockHealthColor,
                          ),
                          const SizedBox(height: 8),
                          _LabelValue(
                            'Kesehatan Stok',
                            '${data.stockHealthPercent}% Ready',
                            valueColor: stockHealthColor,
                          ),
                          const SizedBox(height: 6),
                          _LabelValue(
                            'Stok Habis',
                            '${data.outOfStockCount} item',
                            valueColor: const Color(0xFFE1444B),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    EcoCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MITRA & EKOSISTEM',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2430),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _GrowthBox(
                            totalWarga: data.totalWarga,
                            newWargaThisMonth: data.newWargaThisMonth,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 1,
                                child: _PartnerTile(
                                  title: 'PENGRAJIN SAMPAH',
                                  subtitle: '${data.pengrajinCount} Mitra Aktif',
                                  desc: 'Produk Bernilai Tambah',
                                  icon: Icons.handyman_outlined,
                                  iconBg: const Color(0xFFE6DAFF),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PengrajinSampahPage(),
                                      ),
                                    ).then((_) => _reload());
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: _PartnerTile(
                                  title: 'AGEN GROSIR PASAR',
                                  subtitle: '${data.grosirCount} Toko Mitra',
                                  desc: 'Support UMKM Lokal',
                                  icon: Icons.storefront_outlined,
                                  iconBg: const Color(0xFFE3F2FF),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AgenGrosirPage(),
                                      ),
                                    ).then((_) => _reload());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Report Generate by EcoLoop-Mart Ver2.1',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF98A2B3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({
    required this.icon,
    required this.title,
    required this.value,
    this.badge,
    this.trailing,
    this.iconBg = const Color(0xFFF0F4FF),
    this.iconColor = const Color(0xFF3B82F6),
  });

  final IconData icon;
  final String title;
  final String value;
  final String? badge;
  final String? trailing;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5F6B7A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Color(0xFF5E6E82),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A93A5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SimpleBox extends StatelessWidget {
  const _SimpleBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5F6B7A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2430),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value,
      {this.valueColor = const Color(0xFF1F2430)});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF5F6B7A)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _GrowthBox extends StatelessWidget {
  const _GrowthBox({
    required this.totalWarga,
    required this.newWargaThisMonth,
  });

  final int totalWarga;
  final int newWargaThisMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE6DAFF),
            child: Icon(Icons.person, color: Color(0xFF7F56D9)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pertumbuhan User',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5F6B7A),
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: '$totalWarga Warga ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2430),
                    ),
                    children: [
                      TextSpan(
                        text: newWargaThisMonth > 0
                            ? '(+$newWargaThisMonth Baru)'
                            : '(0 Baru)',
                        style: TextStyle(
                          fontSize: 12,
                          color: newWargaThisMonth > 0
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF8A93A5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  const _PartnerTile({
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.icon,
    required this.iconBg,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String desc;
  final IconData icon;
  final Color iconBg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF6F6F7B), size: 6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2430),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2430),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF5F6B7A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Klik untuk kelola',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFF8A93A5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
