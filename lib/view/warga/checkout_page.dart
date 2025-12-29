import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/cart_viewmodel.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/eco_flow_repository.dart';
import '../widgets/eco_dialog.dart';
import '../widgets/eco_components.dart';
import '../widgets/logout_action.dart';
import '../widgets/product_category_icon.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CheckoutContent(
        onBack: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class CheckoutContent extends StatefulWidget {
  const CheckoutContent({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CheckoutContent> createState() => _CheckoutContentState();
}

class _CheckoutContentState extends State<CheckoutContent> {
  bool _isProcessing = false;

  Future<void> _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  Future<void> _confirmCheckout() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final cartViewModel = context.read<CartViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final ecoFlowRepository = context.read<EcoFlowRepository>();

    final checkoutData = await cartViewModel.checkout();
    if (checkoutData.isEmpty) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    final items = checkoutData['items'] as List<CartItemModel>;
    final userId = authViewModel.currentUser?.id;

    if (userId == null) {
      await showEcoDialog(
        context,
        title: 'User tidak ditemukan',
        message: 'Silakan login ulang.',
        type: EcoDialogType.error,
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      final inputs = items
          .where((i) => i.product.id != null)
          .map((i) => PurchaseItemInput(
                productId: i.product.id!,
                quantity: i.quantity,
              ))
          .toList();

      if (inputs.length != items.length) {
        throw Exception('Produk tidak valid');
      }

      final result = await ecoFlowRepository.processPurchase(
        userId: userId,
        items: inputs,
      );

      await cartViewModel.clearCart();

      if (!mounted) return;
      await showEcoDialog(
        context,
        title: 'Checkout berhasil',
        message:
            'Transaksi ${result.itemLines} item berhasil.\nPoin -${result.totalPointsSpent.toStringAsFixed(0)}',
        type: EcoDialogType.success,
      );
      if (!mounted) return;
      widget.onBack();
    } catch (e) {
      if (!mounted) return;
      await showEcoDialog(
        context,
        title: 'Checkout gagal',
        message: '$e',
        type: EcoDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userName = authViewModel.currentUser?.name ?? 'User';
    final cartViewModel = context.watch<CartViewModel>();
    final items = cartViewModel.cartItems;
    final totalPrice = cartViewModel.totalPrice;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'EcoLoop-',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D9F5D),
                            ),
                          ),
                          TextSpan(
                            text: 'Mart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF8C42),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Halo, $userName',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA2AF),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _handleLogout,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Konfirmasi Penukaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Keranjang masih kosong'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CheckoutItem(
                        item: item,
                        icon: resolveProductCategoryIcon(item.product.category),
                        onDecrease: () {
                          cartViewModel.updateQuantity(
                            item.product.id!,
                            item.quantity - 1,
                          );
                        },
                        onIncrease: () {
                          cartViewModel.updateQuantity(
                            item.product.id!,
                            item.quantity + 1,
                          );
                        },
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
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
                      'TOTAL BAYAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                    Text(
                      '${totalPrice.toInt()} pts',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                EcoPrimaryButton(
                  label: 'KONFIRMASI SEKARANG',
                  onPressed: _confirmCheckout,
                  color: const Color(0xFF16A34A),
                  height: 50,
                  busy: _isProcessing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItem extends StatelessWidget {
  const _CheckoutItem({
    required this.item,
    required this.icon,
    required this.onDecrease,
    required this.onIncrease,
  });

  final CartItemModel item;
  final IconData icon;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2D9F5D)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.product.price.toInt()} pts x ${item.quantity}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF8C42),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtyButton(icon: Icons.remove, onTap: onDecrease),
              const SizedBox(width: 8),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              _QtyButton(icon: Icons.add, onTap: onIncrease),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF6B7280)),
      ),
    );
  }
}
