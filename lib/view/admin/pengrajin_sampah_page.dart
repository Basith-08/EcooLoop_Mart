import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/partner_model.dart';
import '../../data/repositories/partner_repository.dart';
import '../widgets/eco_dialog.dart';
import '../widgets/partner_editor_dialog.dart';

class PengrajinSampahPage extends StatefulWidget {
  const PengrajinSampahPage({super.key});

  @override
  State<PengrajinSampahPage> createState() => _PengrajinSampahPageState();
}

class _PengrajinSampahPageState extends State<PengrajinSampahPage> {
  late PartnerRepository _repository;
  late Future<List<PartnerModel>> _future;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PartnerRepository>();
    _future = _repository.getPartnersByType('pengrajin');
  }

  void _reload() {
    setState(() {
      _future = _repository.getPartnersByType('pengrajin');
    });
  }

  Future<void> _addPartner() async {
    final model = await showPartnerEditorDialog(context, type: 'pengrajin');
    if (model == null) return;
    await _repository.createPartner(model);
    if (!mounted) return;
    _reload();
    await showEcoPopup(
      context,
      message: 'Mitra berhasil ditambahkan',
      type: EcoDialogType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: _AnalyticsAppBar(onClose: () => Navigator.pop(context)),
      body: FutureBuilder<List<PartnerModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat mitra: ${snapshot.error}'));
          }

          final partners = snapshot.data ?? const <PartnerModel>[];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 12),
                    _FilterBar(
                      label: 'Mitra Pengrajin (Upcycling)',
                      icon: Icons.handyman_outlined,
                      color: Color(0xFF16A34A),
                      background: Color(0xFFE6F6ED),
                      onAdd: _addPartner,
                    ),
                    const SizedBox(height: 12),
                    for (final partner in partners) ...[
                      _PengrajinCard(
                        partner: partner,
                        onEdit: () async {
                          final updated = await showPartnerEditorDialog(
                            context,
                            type: 'pengrajin',
                            initial: partner,
                          );
                          if (updated == null || updated.id == null) return;
                          await _repository.updatePartner(updated);
                          if (!mounted) return;
                          _reload();
                          await showEcoPopup(
                            context,
                            message: 'Mitra berhasil diperbarui',
                            type: EcoDialogType.success,
                          );
                        },
                        onDelete: () async {
                          if (partner.id == null) return;
                          final confirmed = await showEcoDialog<bool>(
                            context,
                            title: 'Hapus mitra?',
                            message: 'Mitra "${partner.name}" akan dinonaktifkan.',
                            type: EcoDialogType.warning,
                            actions: [
                              EcoDialogAction(
                                label: 'Batal',
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              EcoDialogAction(
                                label: 'Hapus',
                                isPrimary: true,
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                          if (confirmed != true) return;
                          await _repository.setPartnerActive(partner.id!, false);
                          if (!mounted) return;
                          _reload();
                          await showEcoPopup(
                            context,
                            message: 'Mitra dihapus',
                            type: EcoDialogType.success,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                    const _FooterNote(),
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

class AgenGrosirPage extends StatefulWidget {
  const AgenGrosirPage({super.key});

  @override
  State<AgenGrosirPage> createState() => _AgenGrosirPageState();
}

class _AgenGrosirPageState extends State<AgenGrosirPage> {
  late PartnerRepository _repository;
  late Future<List<PartnerModel>> _future;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PartnerRepository>();
    _future = _repository.getPartnersByType('grosir');
  }

  void _reload() {
    setState(() {
      _future = _repository.getPartnersByType('grosir');
    });
  }

  Future<void> _addPartner() async {
    final model = await showPartnerEditorDialog(context, type: 'grosir');
    if (model == null) return;
    await _repository.createPartner(model);
    if (!mounted) return;
    _reload();
    await showEcoPopup(
      context,
      message: 'Mitra berhasil ditambahkan',
      type: EcoDialogType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: _AnalyticsAppBar(onClose: () => Navigator.pop(context)),
      body: FutureBuilder<List<PartnerModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat mitra: ${snapshot.error}'));
          }

          final partners = snapshot.data ?? const <PartnerModel>[];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 12),
                    _FilterBar(
                      label: 'Agen Grosir Pasar Tradisional',
                      icon: Icons.storefront_outlined,
                      color: Color(0xFF2563EB),
                      background: Color(0xFFE7F0FF),
                      onAdd: _addPartner,
                    ),
                    const SizedBox(height: 12),
                    for (final partner in partners) ...[
                      _GrosirCard(
                        partner: partner,
                        onEdit: () async {
                          final updated = await showPartnerEditorDialog(
                            context,
                            type: 'grosir',
                            initial: partner,
                          );
                          if (updated == null || updated.id == null) return;
                          await _repository.updatePartner(updated);
                          if (!mounted) return;
                          _reload();
                          await showEcoPopup(
                            context,
                            message: 'Mitra berhasil diperbarui',
                            type: EcoDialogType.success,
                          );
                        },
                        onDelete: () async {
                          if (partner.id == null) return;
                          final confirmed = await showEcoDialog<bool>(
                            context,
                            title: 'Hapus mitra?',
                            message: 'Mitra "${partner.name}" akan dinonaktifkan.',
                            type: EcoDialogType.warning,
                            actions: [
                              EcoDialogAction(
                                label: 'Batal',
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              EcoDialogAction(
                                label: 'Hapus',
                                isPrimary: true,
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                          if (confirmed != true) return;
                          await _repository.setPartnerActive(partner.id!, false);
                          if (!mounted) return;
                          _reload();
                          await showEcoPopup(
                            context,
                            message: 'Mitra dihapus',
                            type: EcoDialogType.success,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                    const _FooterNote(),
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

class _AnalyticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AnalyticsAppBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 52,
      titleSpacing: 0,
      title: Row(
        children: const [
          SizedBox(width: 8),
          Icon(
            Icons.auto_graph,
            color: Color(0xFF7F56D9),
            size: 22,
          ),
          SizedBox(width: 6),
          Text(
            'Laporan Analitik',
            style: TextStyle(
              color: Color(0xFF1F2430),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2430)),
          onPressed: onClose,
          tooltip: 'Tutup',
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'MITRA & EKOSISTEM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2430),
            ),
          ),
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: Color(0xFF2563EB)),
            label: const Text(
              'Kembali',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    this.onAdd,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: onAdd,
            tooltip: 'Tambah',
          ),
        ),
      ],
    );
  }
}

class _PengrajinCard extends StatelessWidget {
  const _PengrajinCard({
    required this.partner,
    required this.onEdit,
    required this.onDelete,
  });

  final PartnerModel partner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  partner.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _TagPill(label: partner.tag ?? 'Mitra'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF8A93A5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  partner.location ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5F6B7A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.map_outlined, size: 15, color: Color(0xFF4C6FFF)),
                SizedBox(width: 6),
                Text(
                  'Lihat di Maps',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF4C6FFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionLink(icon: Icons.edit, label: 'Edit', onTap: onEdit),
              const SizedBox(width: 14),
              _ActionLink(
                icon: Icons.delete_outline,
                label: 'Hapus',
                color: Color(0xFFE1444B),
                onTap: onDelete,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _GrosirCard extends StatelessWidget {
  const _GrosirCard({
    required this.partner,
    required this.onEdit,
    required this.onDelete,
  });

  final PartnerModel partner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2430),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      partner.subtitle ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5F6B7A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    partner.area ?? '-',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A93A5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    partner.detail ?? '-',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF8A93A5),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionLink(icon: Icons.edit, label: 'Edit', onTap: onEdit),
              const SizedBox(width: 14),
              _ActionLink(
                icon: Icons.delete_outline,
                label: 'Hapus',
                color: Color(0xFFE1444B),
                onTap: onDelete,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F6ED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF15803D),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF2563EB),
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'Report Generate by EcoLoop-Mart Ver2.1',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF98A2B3),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
