import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class ManageTransactionsPage extends StatefulWidget {
  const ManageTransactionsPage({super.key});

  @override
  State<ManageTransactionsPage> createState() => _ManageTransactionsPageState();
}

class _ManageTransactionsPageState extends State<ManageTransactionsPage> {
  // Combined dialog function for "Add Transaction" and "Edit Transaction"
  void _showTransactionDialog(
    BuildContext context,
    TransactionProvider provider, {
    int? index,
    TransactionModel? tx,
  }) {
    final isEdit = tx != null;

    // If edit mode, fill with old data. If adding new, leave blank.
    final TextEditingController dateController = TextEditingController(
      text: isEdit ? tx.dateOrStatus : '',
    );
    final TextEditingController titleController = TextEditingController(
      text: isEdit ? tx.title : '',
    );
    final TextEditingController subtitleController = TextEditingController(
      text: isEdit
          ? tx.subtitle
          : 'DEBIT TRANSACTION', // Default value if empty
    );
    final TextEditingController amountController = TextEditingController(
      text: isEdit ? tx.amount : 'IDR ',
    );

    // Default debit (red) for new transaction
    bool isDebit = isEdit ? tx.isDebit : true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Transaction' : 'Add New Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date / Status',
                        hintText: 'Example: 15\\nMAY\\n2023 or PEND',
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title / Transaction Name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle / Description',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (example: 50,000.00)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transaction Type:'),
                        DropdownButton<bool>(
                          value: isDebit,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Debit (Red)'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Credit (Green)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setStateDialog(() {
                                isDebit = val;
                                // Auto change subtitle based on type if adding new
                                if (!isEdit ||
                                    subtitleController.text.startsWith(
                                      'TRANSAKSI',
                                    ) ||
                                    subtitleController.text.endsWith(
                                      'TRANSACTION',
                                    )) {
                                  subtitleController.text = isDebit
                                      ? 'DEBIT TRANSACTION'
                                      : 'CREDIT TRANSACTION';
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isEdit && index != null && tx != null) {
                      // UPDATE existing transaction
                      final updatedTx = tx.copyWith(
                        dateOrStatus: dateController.text,
                        title: titleController.text,
                        subtitle: subtitleController.text,
                        amount: amountController.text,
                        isDebit: isDebit,
                      );
                      provider.updateTransaction(index, updatedTx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction successfully updated!'),
                        ),
                      );
                    } else {
                      // ADD new transaction
                      final newTx = TransactionModel(
                        dateOrStatus: dateController.text,
                        title: titleController.text,
                        subtitle: subtitleController.text,
                        amount: amountController.text,
                        isDebit: isDebit,
                      );
                      provider.addTransaction(newTx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New transaction added!'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BAC),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Transactions'),
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'No transactions yet. Please add manually or upload PDF.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Give padding so it's not covered by the FAB
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.isDebit
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    child: Icon(
                      tx.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                      color: tx.isDebit ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${tx.dateOrStatus.replaceAll('\n', ' ')}\n${tx.amount}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTransactionDialog(
                          context,
                          provider,
                          index: index,
                          tx: tx,
                        ),
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteTransaction(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction deleted!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // --- ADD TRANSACTION BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final provider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          _showTransactionDialog(context, provider);
        },
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
