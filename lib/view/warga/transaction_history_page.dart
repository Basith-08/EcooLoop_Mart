import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/transaction_viewmodel.dart';
import '../../state/transaction_state.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/eco_user_app_bar.dart';
import '../widgets/logout_action.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) {
      Future.microtask(() {
        context.read<TransactionViewModel>().loadUserTransactions(userId);
      });
    }
  }

  void _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userName = authViewModel.currentUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: EcoUserAppBar(
        title: 'Riwayat Transaksi',
        subtitle: 'Halo, $userName',
        onLogout: _handleLogout,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: Consumer<TransactionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text((viewModel.state as TransactionError).message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.state is TransactionEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai setor sampah atau belanja di mart!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.state is TransactionLoaded) {
              final transactions = (viewModel.state as TransactionLoaded).transactions;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final isDeposit = transaction.type == 'deposit';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDeposit
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFE8DC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDeposit ? Icons.arrow_upward : Icons.shopping_bag,
                            color: isDeposit
                                ? const Color(0xFF2D9F5D)
                                : const Color(0xFFFF8C42),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Transaction Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTransactionTitle(transaction),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(transaction.transactionDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Points
                        Text(
                          '${isDeposit ? '+' : '-'}${transaction.totalPrice.toInt()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDeposit
                                ? const Color(0xFF2D9F5D)
                                : const Color(0xFFFF6B6B),
                          ),
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
    );
  }

  String _getTransactionTitle(TransactionModel transaction) {
    if (transaction.type == 'deposit') {
      return transaction.wasteType != null
          ? 'Setor ${transaction.wasteType}'
          : 'Setor Sampah';
    } else {
      return transaction.productName != null
          ? 'Tukar ${transaction.productName}'
          : 'Tukar Barang';
    }
  }
}
