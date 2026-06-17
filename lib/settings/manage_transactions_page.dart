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
  // Fungsi untuk menampilkan Dialog Edit Transaksi
  void _showEditDialog(
    BuildContext context,
    int index,
    TransactionModel tx,
    TransactionProvider provider,
  ) {
    final TextEditingController dateController = TextEditingController(
      text: tx.dateOrStatus,
    );
    final TextEditingController titleController = TextEditingController(
      text: tx.title,
    );
    final TextEditingController subtitleController = TextEditingController(
      text: tx.subtitle,
    );
    final TextEditingController amountController = TextEditingController(
      text: tx.amount,
    );
    bool isDebit = tx.isDebit;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Transaksi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal / Status',
                        hintText: 'Contoh: 15\\nMEI\\n2023 atau PEND',
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul / Nama Transaksi',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Sub-judul / Keterangan',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Nominal (contoh: 50.000,00)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jenis Transaksi:'),
                        DropdownButton<bool>(
                          value: isDebit,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Debit (Merah)'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Kredit (Hijau)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setStateDialog(() => isDebit = val);
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
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update transaksi
                    final updatedTx = tx.copyWith(
                      dateOrStatus: dateController.text,
                      title: titleController.text,
                      subtitle: subtitleController.text,
                      amount: amountController.text,
                      isDebit: isDebit,
                    );
                    provider.updateTransaction(index, updatedTx);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaksi berhasil diubah!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BAC),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
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
        title: const Text('Kelola Transaksi'),
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada transaksi. Silakan upload PDF terlebih dahulu.',
              ),
            );
          }

          return ListView.builder(
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditDialog(context, index, tx, provider),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteTransaction(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaksi dihapus!')),
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
    );
  }
}
