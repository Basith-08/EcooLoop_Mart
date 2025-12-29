import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../state/product_state.dart';
import '../../data/models/product_model.dart';
import '../widgets/admin_header.dart';
import '../widgets/eco_components.dart';
import '../widgets/eco_dialog.dart';
import '../widgets/logout_action.dart';

class AdminWarehousePage extends StatefulWidget {
  const AdminWarehousePage({super.key});

  @override
  State<AdminWarehousePage> createState() => _AdminWarehousePageState();
}

class _AdminWarehousePageState extends State<AdminWarehousePage> {
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

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final priceController = TextEditingController();
    String selectedIcon = _iconOptions.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          actionsPadding: EdgeInsets.zero,
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Tambah Stok Barang',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EcoInputField(
                  controller: nameController,
                  hint: 'Nama Barang',
                  fillColor: const Color(0xFFF5F5F5),
                  borderColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: EcoInputField(
                        controller: stockController,
                        hint: 'Stok',
                        keyboardType: TextInputType.number,
                        fillColor: const Color(0xFFF5F5F5),
                        borderColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: EcoInputField(
                        controller: priceController,
                        hint: 'Poin',
                        keyboardType: TextInputType.number,
                        fillColor: const Color(0xFFF5F5F5),
                        borderColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedIcon,
                      items: _iconOptions
                          .map((icon) => DropdownMenuItem(
                                value: icon,
                                child: Text(icon),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedIcon = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            EcoPrimaryButton(
              label: 'Simpan',
              height: 50,
              color: const Color(0xFF4169E1),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    stockController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  await showEcoDialog(
                    context,
                    title: 'Data belum lengkap',
                    message: 'Semua field harus diisi sebelum menyimpan.',
                    type: EcoDialogType.warning,
                  );
                  return;
                }

                await context.read<ProductViewModel>().createProduct(
                      name: nameController.text,
                      stock: int.parse(stockController.text),
                      price: double.parse(priceController.text),
                      category: selectedIcon,
                    );

                if (!mounted) return;
                Navigator.pop(context);
                await showEcoDialog(
                  context,
                  title: 'Produk tersimpan',
                  message: 'Produk baru berhasil ditambahkan ke gudang.',
                  type: EcoDialogType.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final stockController =
        TextEditingController(text: product.stock.toString());
    final priceController =
        TextEditingController(text: product.price.toInt().toString());
    String selectedIcon = product.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          actionsPadding: EdgeInsets.zero,
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Edit Barang',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EcoInputField(
                  controller: nameController,
                  hint: 'Nama Barang',
                  fillColor: const Color(0xFFF5F5F5),
                  borderColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: EcoInputField(
                        controller: stockController,
                        hint: 'Stok',
                        keyboardType: TextInputType.number,
                        fillColor: const Color(0xFFF5F5F5),
                        borderColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: EcoInputField(
                        controller: priceController,
                        hint: 'Poin',
                        keyboardType: TextInputType.number,
                        fillColor: const Color(0xFFF5F5F5),
                        borderColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedIcon,
                      items: _iconOptions
                          .map((icon) => DropdownMenuItem(
                                value: icon,
                                child: Text(icon),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedIcon = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            EcoPrimaryButton(
              label: 'Simpan',
              height: 50,
              color: const Color(0xFF4169E1),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    stockController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  await showEcoDialog(
                    context,
                    title: 'Data belum lengkap',
                    message: 'Semua field harus diisi sebelum menyimpan.',
                    type: EcoDialogType.warning,
                  );
                  return;
                }

                final updatedProduct = product.copyWith(
                  name: nameController.text,
                  stock: int.parse(stockController.text),
                  price: double.parse(priceController.text),
                  category: selectedIcon,
                );

                await context
                    .read<ProductViewModel>()
                    .updateProduct(updatedProduct);

                if (!mounted) return;
                Navigator.pop(context);
                await showEcoDialog(
                  context,
                  title: 'Produk diperbarui',
                  message: 'Data produk berhasil diupdate.',
                  type: EcoDialogType.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(ProductModel product) async {
    final confirmed = await showEcoDialog<bool>(
      context,
      title: 'Hapus produk?',
      message: 'Produk ${product.name} akan dihapus dari daftar stok.',
      type: EcoDialogType.warning,
      actions: [
        EcoDialogAction(
          label: 'Batal',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        EcoDialogAction(
          label: 'Hapus',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed == true && product.id != null) {
      await context.read<ProductViewModel>().deleteProduct(product.id!);
      if (!mounted) return;
      await showEcoDialog(
        context,
        title: 'Produk dihapus',
        message: 'Produk berhasil dihapus dari stok.',
        type: EcoDialogType.success,
      );
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
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AdminHeader(
        adminName: adminName,
        onLogout: _handleLogout,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AdminTheme.pagePadding),
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: ElevatedButton.icon(
                  onPressed: _showAddProductDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Stok Barang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9F1FF),
                    foregroundColor: const Color(0xFF4169E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.state is ProductError) {
                  return Center(
                    child: Text((viewModel.state as ProductError).message),
                  );
                }

                if (viewModel.state is ProductEmpty) {
                  return const Center(
                    child: Text('Belum ada produk'),
                  );
                }

                if (viewModel.state is ProductLoaded) {
                  final products = (viewModel.state as ProductLoaded).products;

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFE9F1FF),
                              child: Icon(
                                _iconForCategory(product.category),
                                color: const Color(0xFF4169E1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2430),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      EcoPill(
                                        label: 'Stok: ${product.stock}',
                                        color: const Color(0xFF2E86FF),
                                        background: const Color(0xFFE8F1FF),
                                      ),
                                      const SizedBox(width: 8),
                                      EcoPill(
                                        label: '${product.price.toInt()} Poin',
                                        color: const Color(0xFFFF8C42),
                                        background: const Color(0xFFFFF0E5),
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
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  color: const Color(0xFF2E86FF),
                                  onPressed: () =>
                                      _showEditProductDialog(product),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  color: const Color(0xFFE1444B),
                                  onPressed: () => _deleteProduct(product),
                                ),
                              ],
                            ),
                          ],
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
