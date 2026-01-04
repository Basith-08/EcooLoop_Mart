// admin_warehouse_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../state/product_state.dart';
import '../../data/models/product_model.dart';
import '../widgets/admin_header.dart';
import '../widgets/eco_components.dart';
import '../widgets/logout_action.dart';

class AdminWarehousePage extends StatefulWidget {
  const AdminWarehousePage({super.key});

  @override
  State<AdminWarehousePage> createState() => _AdminWarehousePageState();
}

class _AdminWarehousePageState extends State<AdminWarehousePage> {
  static const _pageBg = Color(0xFFF6F8FB);
  static const _accent = Color(0xFF4169E1);
  static const _mutedFill = Color(0xFFF5F5F5);
  static const _pillBlue = Color(0xFFE8F1FF);
  static const _pillOrange = Color(0xFFFFF0E5);

  final List<String> _iconOptions = const [
    'Ikon Beras',
    'Ikon Minyak',
    'Ikon Gula',
    'Ikon Telur',
    'Ikon Mie',
    'Ikon Paket Sembako',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      context.read<ProductViewModel>().loadProducts();
    });
  }

  /// Success dialog that matches the visual you provided (icon top, rounded, green "Tutup" btn).
  Future<bool?> _showSuccessDialog({
    required BuildContext parentContext,
    required String title,
    required String message,
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: parentContext,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // top icon box
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1AA260),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.recycling, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true), // use builder ctx — safe to pop THIS dialog
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1AA260),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Confirmation dialog for deletions (Batal / Hapus)
  Future<bool?> _showConfirmDeleteDialog({
    required BuildContext parentContext,
    required String title,
    required String message,
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: parentContext,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE1444B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddProductDialog() async {
    final result = await showDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => _ProductDialog(
        title: 'Tambah Stok Barang',
        iconOptions: _iconOptions,
        primaryColor: _accent,
        mutedFill: _mutedFill,
        onSubmit: (name, stock, point, category) async {
          await context.read<ProductViewModel>().createProduct(
                name: name,
                stock: stock,
                price: point.toDouble(),
                category: category,
              );
        },
      ),
    );

    if (result == true && mounted) {
      // show success dialog styled like the image
      await _showSuccessDialog(parentContext: context, title: 'Berhasil', message: 'Produk tersimpan.', barrierDismissible: false);
    }
  }

  Future<void> _showEditProductDialog(ProductModel product) async {
    final result = await showDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => _ProductDialog(
        title: 'Edit Barang',
        iconOptions: _iconOptions,
        initialName: product.name,
        initialStock: product.stock,
        initialPoint: product.price.toInt(),
        initialCategory: product.category,
        primaryColor: _accent,
        mutedFill: _mutedFill,
        onSubmit: (name, stock, point, category) async {
          final updated = product.copyWith(
            name: name,
            stock: stock,
            price: point.toDouble(),
            category: category,
          );
          await context.read<ProductViewModel>().updateProduct(updated);
        },
      ),
    );

    if (result == true && mounted) {
      await _showSuccessDialog(parentContext: context, title: 'Berhasil', message: 'Produk diperbarui.', barrierDismissible: false);
    }
  }

  void _deleteProduct(ProductModel product) async {
    final confirmed = await _showConfirmDeleteDialog(
      parentContext: context,
      title: 'Hapus produk?',
      message: 'Produk "${product.name}" akan dihapus dari daftar stok.',
      barrierDismissible: false,
    );

    if (confirmed == true && product.id != null) {
      await context.read<ProductViewModel>().deleteProduct(product.id!);
      if (!mounted) return;
      await _showSuccessDialog(parentContext: context, title: 'Produk dihapus', message: 'Produk berhasil dihapus dari stok.', barrierDismissible: false);
    }
  }

  void _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final adminName = authViewModel.currentUser?.name ?? 'Admin';

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AdminHeader(
        adminName: adminName,
        onLogout: _handleLogout,
      ),
      body: Column(
        children: [
          // Top action panel (button centered)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: AdminTheme.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Tambah Stok Barang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9F1FF),
                      foregroundColor: _accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(170, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.state is ProductError) {
                  return Center(child: Text((viewModel.state as ProductError).message));
                }

                if (viewModel.state is ProductEmpty) {
                  return const Center(child: Text('Belum ada produk'));
                }

                if (viewModel.state is ProductLoaded) {
                  final products = (viewModel.state as ProductLoaded).products;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = products[index];

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showEditProductDialog(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFE9F1FF),
                                  child: Icon(_iconForCategory(p.category), color: _accent, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2430)),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          EcoPill(
                                            label: 'Stok: ${p.stock}',
                                            color: const Color(0xFF2E86FF),
                                            background: _pillBlue,
                                          ),
                                          const SizedBox(width: 8),
                                          EcoPill(
                                            label: '${p.price.toInt()} Poin',
                                            color: const Color(0xFFFF8C42),
                                            background: _pillOrange,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                      color: const Color(0xFF2E86FF),
                                      onPressed: () => _showEditProductDialog(p),
                                      tooltip: 'Edit',
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      color: const Color(0xFFE1444B),
                                      onPressed: () => _deleteProduct(p),
                                      tooltip: 'Hapus',
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Ikon Minyak':
        return Icons.local_drink;
      case 'Ikon Gula':
        return Icons.cake_outlined;
      case 'Ikon Telur':
        return Icons.egg_alt_outlined;
      case 'Ikon Mie':
        return Icons.ramen_dining;
      case 'Ikon Paket Sembako':
        return Icons.inventory_2;
      case 'Ikon Beras':
      default:
        return Icons.rice_bowl;
    }
  }
}

/// Dialog widget used for both Add and Edit.
/// Uses an internal Form and returns via `Navigator.pop(true)` on success.
class _ProductDialog extends StatefulWidget {
  final String title;
  final List<String> iconOptions;
  final String? initialName;
  final int? initialStock;
  final int? initialPoint;
  final String? initialCategory;
  final Color primaryColor;
  final Color mutedFill;
  final Future<void> Function(String name, int stock, int point, String category) onSubmit;

  const _ProductDialog({
    required this.title,
    required this.iconOptions,
    this.initialName,
    this.initialStock,
    this.initialPoint,
    this.initialCategory,
    required this.primaryColor,
    required this.mutedFill,
    required this.onSubmit,
  });

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _pointCtrl;
  late String _selectedIcon;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _stockCtrl = TextEditingController(text: widget.initialStock?.toString() ?? '');
    _pointCtrl = TextEditingController(text: widget.initialPoint?.toString() ?? '');
    _selectedIcon = widget.initialCategory ?? widget.iconOptions.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _pointCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? -1;
    final point = int.tryParse(_pointCtrl.text.trim()) ?? -1;

    if (stock < 0 || point < 0) {
      // Use a simple dialog to show validation error
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Format angka salah'),
          content: const Text('Pastikan Stok dan Poin diisi dengan angka yang benar.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup'))
          ],
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(name, stock, point, _selectedIcon);

      if (!mounted) return;
      Navigator.of(context).pop(true); // return success to caller
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Terjadi kesalahan'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup'))
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate insets and safe padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomSystemPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight = MediaQuery.of(context).size.height;
    final maxDialogHeight = availableHeight * 0.9; // keep some margin from screen edges

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              // ensure dialog never goes beyond max height so Flutter will allow scrolling
              maxHeight: maxDialogHeight,
            ),
            child: Padding(
              // include bottom inset (keyboard) and system bottom padding (navigation bar)
              padding: EdgeInsets.fromLTRB(18, 16, 18, 14 + bottomInset + bottomSystemPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + close
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Nama Barang',
                            filled: true,
                            fillColor: widget.mutedFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama barang wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Stock & Point
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _stockCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Stok',
                                  filled: true,
                                  fillColor: widget.mutedFill,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Stok wajib diisi';
                                  if (int.tryParse(v.trim()) == null) return 'Masukkan angka valid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _pointCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Poin',
                                  filled: true,
                                  fillColor: widget.mutedFill,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Poin wajib diisi';
                                  if (int.tryParse(v.trim()) == null) return 'Masukkan angka valid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: widget.mutedFill, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedIcon,
                              items: widget.iconOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _selectedIcon = v;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: _submitting
                                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
