import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../viewmodel/cart_viewmodel.dart';
import '../../state/product_state.dart';
import '../../state/cart_state.dart';
import 'checkout_page.dart';
import 'warga_home_page.dart';
import '../widgets/eco_dialog.dart';
import '../widgets/eco_user_app_bar.dart';
import '../widgets/logout_action.dart';
import '../widgets/product_category_icon.dart';

class MartPage extends StatefulWidget {
  const MartPage({super.key});

  @override
  State<MartPage> createState() => _MartPageState();
}

class _MartPageState extends State<MartPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    return 2;
  }

  double _gridAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.82;
    if (width < 420) return 0.86;
    if (width < 600) return 0.9;
    if (width < 800) return 0.94;
    return 0.98;
  }

  void _loadData() {
    Future.microtask(() {
      context.read<ProductViewModel>().loadAvailableProducts();
    });
  }

  void _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  void _openCheckout() {
    final homeState = WargaHomePage.of(context);
    if (homeState != null) {
      homeState.openCheckout();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CheckoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final cartViewModel = context.watch<CartViewModel>();
    final userName = authViewModel.currentUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: EcoUserAppBar(
        subtitle: 'Halo, $userName',
        onLogout: _handleLogout,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Mart Warga',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((viewModel.state as ProductError).message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (viewModel.state is ProductEmpty) {
                      return const Center(
                        child: Text('Belum ada produk tersedia'),
                      );
                    }

                    if (viewModel.state is ProductLoaded) {
                      final products = (viewModel.state as ProductLoaded).products;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridColumns(context),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: _gridAspectRatio(context),
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isPackage = product.name.toLowerCase().contains('paket');

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final isTight = constraints.maxHeight < 200;
                              final padding = isTight ? 12.0 : 14.0;
                              final iconBoxSize = isTight ? 60.0 : 68.0;
                              final iconSize = isTight ? 32.0 : 36.0;
                              final spacingLarge = isTight ? 10.0 : 12.0;
                              final spacing = isTight ? 4.0 : 6.0;
                              final buttonSize = isTight ? 26.0 : 28.0;
                              final buttonIconSize = isTight ? 15.0 : 17.0;
                              final buttonInset = isTight ? 12.0 : 14.0;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE8EAEF)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        padding,
                                        padding,
                                        padding,
                                        padding + buttonSize,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Product Icon
                                          Container(
                                            width: iconBoxSize,
                                            height: iconBoxSize,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF6F7F9),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              resolveProductCategoryIcon(product.category),
                                              size: iconSize,
                                              color: const Color(0xFF2D9F5D),
                                            ),
                                          ),
                                          SizedBox(height: spacingLarge),

                                          // Product Name
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1F2430),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: spacing),

                                          // Price
                                          Text(
                                            '${product.price.toInt()} pts',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFFF8C42),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Positioned(
                                      right: buttonInset,
                                      bottom: buttonInset,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(buttonSize),
                                          onTap: () async {
                                            await context
                                                .read<CartViewModel>()
                                                .addToCart(product);
                                            if (!context.mounted) return;
                                            await showEcoPopup(
                                              context,
                                              message:
                                                  '${product.name} ditambahkan ke keranjang',
                                              type: EcoDialogType.success,
                                            );
                                          },
                                          child: Container(
                                            width: buttonSize,
                                            height: buttonSize,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2D9F5D),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: buttonIconSize,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Package Badge
                                    if (isPackage)
                                      Positioned(
                                        top: padding,
                                        right: padding,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF8C42),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'PAKET LITE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),

              // Space for floating cart button
              const SizedBox(height: 80),
            ],
          ),

          // Floating Cart Button
          if (cartViewModel.state is CartLoaded)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D9F5D),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cartViewModel.totalItems} ITEM DIPILIH',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _openCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2D9F5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
