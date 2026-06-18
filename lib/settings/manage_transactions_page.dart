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
  // Fungsi dialog gabungan untuk "Tambah Transaksi" dan "Edit Transaksi"
  void _showTransactionDialog(
    BuildContext context,
    TransactionProvider provider, {
    int? index,
    TransactionModel? tx,
  }) {
    final isEdit = tx != null;

    // Jika mode edit, isi dengan data lama. Jika tambah baru, kosongkan.
    final TextEditingController dateController = TextEditingController(
      text: isEdit ? tx.dateOrStatus : '',
    );
    final TextEditingController titleController = TextEditingController(
      text: isEdit ? tx.title : '',
    );
    final TextEditingController subtitleController = TextEditingController(
      text: isEdit
          ? tx.subtitle
          : 'TRANSAKSI DEBIT', // Nilai default jika kosong
    );
    final TextEditingController amountController = TextEditingController(
      text: isEdit ? tx.amount : 'IDR ',
    );

    // Default debit (merah) untuk transaksi baru
    bool isDebit = isEdit ? tx.isDebit : true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Transaksi' : 'Tambah Transaksi Baru'),
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
                              setStateDialog(() {
                                isDebit = val;
                                // Ubah subtitle otomatis menyesuaikan jenis, jika ini mode tambah baru
                                if (!isEdit ||
                                    subtitleController.text.startsWith(
                                      'TRANSAKSI',
                                    )) {
                                  subtitleController.text = isDebit
                                      ? 'TRANSAKSI DEBIT'
                                      : 'TRANSAKSI KREDIT';
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
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isEdit && index != null && tx != null) {
                      // UPDATE transaksi yang sudah ada
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
                          content: Text('Transaksi berhasil diubah!'),
                        ),
                      );
                    } else {
                      // TAMBAH transaksi baru
                      final newTx = TransactionModel(
                        dateOrStatus: dateController.text,
                        title: titleController.text,
                        subtitle: subtitleController.text,
                        amount: amountController.text,
                        isDebit: isDebit,
                      );
                      // addTransaction sudah ada di provider Anda, tinggal pakai
                      provider.addTransaction(newTx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaksi baru ditambahkan!'),
                        ),
                      );
                    }
                    Navigator.pop(context);
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
                'Belum ada transaksi. Silakan tambah manual atau upload PDF.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Memberi jarak agar tidak tertutup tombol melayang
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
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTransactionDialog(
                          context,
                          provider,
                          index: index,
                          tx: tx,
                        ),
                      ),
                      // Tombol Hapus
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
      // --- TOMBOL TAMBAH TRANSAKSI ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final provider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          // Panggil dialog tanpa melempar data (Berarti mode Tambah Baru)
          _showTransactionDialog(context, provider);
        },
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
    );
  }
}
