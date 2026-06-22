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
  String _selectedFilter = 'All';

  void _showTransactionBottomSheet(
    BuildContext context,
    TransactionProvider provider, {
    int? index,
    TransactionModel? tx,
  }) {
    final isEdit = tx != null;

    List<String> dateParts = tx != null ? tx.dateOrStatus.split('\n') : [];
    final TextEditingController dayController = TextEditingController(
      text: dateParts.isNotEmpty ? dateParts[0] : '',
    );
    final TextEditingController monthController = TextEditingController(
      text: dateParts.length > 1 ? dateParts[1] : '',
    );
    final TextEditingController yearController = TextEditingController(
      text: dateParts.length > 2 ? dateParts[2] : '',
    );
    final TextEditingController keteranganKiriController =
        TextEditingController(text: isEdit ? tx.keteranganKiri : '');
    final TextEditingController keteranganKananController =
        TextEditingController(text: isEdit ? tx.keteranganKanan : '');
    final TextEditingController subtitleController = TextEditingController(
      text: isEdit ? tx.subtitle : 'DEBIT TRANSACTION',
    );
    final TextEditingController amountController = TextEditingController(
      text: isEdit ? tx.amount : 'IDR ',
    );

    bool isDebit = isEdit ? tx.isDebit : true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Transaction' : 'New Transaction',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005BAC),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Transaction Type Switch
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setStateSheet(() {
                                isDebit = true;
                                if (!isEdit ||
                                    subtitleController.text.endsWith(
                                      'TRANSACTION',
                                    )) {
                                  subtitleController.text = 'DEBIT TRANSACTION';
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isDebit
                                    ? Colors.red.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDebit
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'DEBIT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDebit
                                      ? Colors.red.shade800
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setStateSheet(() {
                                isDebit = false;
                                if (!isEdit ||
                                    subtitleController.text.endsWith(
                                      'TRANSACTION',
                                    )) {
                                  subtitleController.text =
                                      'CREDIT TRANSACTION';
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isDebit
                                    ? Colors.green.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isDebit
                                      ? Colors.green
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'CREDIT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isDebit
                                      ? Colors.green.shade800
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Forms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: dayController,
                            label: 'Day/Status',
                            hint: '15',
                            icon: Icons.calendar_today,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: monthController,
                            label: 'Month',
                            hint: 'MAY',
                            icon: Icons.date_range,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: yearController,
                            label: 'Year',
                            hint: '2023',
                            icon: Icons.calendar_month,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: keteranganKiriController,
                      label: 'Title (Keterangan Kiri)',
                      icon: Icons.title,
                      dropdownOptions: const [
                        'TRSF E-BANKING CR',
                        'TRSF E-BANKING DB',
                        'SWITCHING',
                        'SWITCHING DB TRANSFER',
                        'SWITCHING CR TRANSFER',
                        'BIAYA ADM',
                        'PAJAK BUNGA',
                        'TARIKAN ATM',
                        'SETORAN TUNAI',
                        'SETORAN VIA CDM',
                        'KOR. DEBET',
                        'KR OTOMATIS',
                        'BI-FAST DB',
                        'BI-FAST CR',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: keteranganKananController,
                      label: 'Details (Keterangan Kanan)',
                      icon: Icons.notes,
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: subtitleController,
                      label: 'Subtitle / Description',
                      icon: Icons.subtitles,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: amountController,
                      label: 'Amount',
                      hint: 'Example: 50,000.00',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: () {
                        String finalDate = '';
                        if (dayController.text.isNotEmpty && monthController.text.isNotEmpty && yearController.text.isNotEmpty) {
                          finalDate = '${dayController.text}\n${monthController.text}\n${yearController.text}';
                        } else if (dayController.text.isNotEmpty && monthController.text.isNotEmpty) {
                          finalDate = '${dayController.text}\n${monthController.text}';
                        } else {
                          finalDate = dayController.text;
                        }

                        final newTx = TransactionModel(
                          dateOrStatus: finalDate,
                          keteranganKiri: keteranganKiriController.text,
                          keteranganKanan: keteranganKananController.text,
                          subtitle: subtitleController.text,
                          amount: amountController.text,
                          isDebit: isDebit,
                        );

                        if (isEdit && index != null) {
                          provider.updateTransaction(index, newTx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction updated successfully'),
                            ),
                          );
                        } else {
                          provider.addTransaction(newTx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'New transaction added successfully',
                              ),
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005BAC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'SAVE CHANGES' : 'ADD TRANSACTION',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int? maxLines = 1,
    TextInputType? keyboardType,
    List<String>? dropdownOptions,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: dropdownOptions != null
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                onSelected: (String value) {
                  controller.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return dropdownOptions.map((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF005BAC), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Manage Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final allTransactions = provider.transactions;

          if (allTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add manually or upload a PDF statement.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final uploadedMonths = provider.uploadedMonths;
          final List<String> filterOptions = ['All', ...uploadedMonths];
          if (!filterOptions.contains(_selectedFilter)) {
            _selectedFilter = 'All';
          }

          final List<TransactionModel> displayTransactions =
              _selectedFilter == 'All'
              ? allTransactions
              : allTransactions.where((tx) {
                  return provider.getTransactionMonthYear(tx) ==
                      _selectedFilter;
                }).toList();

          return Column(
            children: [
              // Filter Bar
              if (uploadedMonths.isNotEmpty)
                Container(
                  height: 60,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: filterOptions.length,
                    itemBuilder: (context, index) {
                      final option = filterOptions[index];
                      final isSelected = _selectedFilter == option;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = option;
                              });
                            }
                          },
                          selectedColor: const Color(0xFF005BAC),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF005BAC)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Transaction List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 100),
                  itemCount: displayTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = displayTransactions[index];
                    final currentTxMonth = provider.getTransactionMonthYear(tx);
                    final actualIndex = allTransactions.indexOf(
                      tx,
                    ); // Get the real index for CRUD

                    bool showHeader = false;
                    if (_selectedFilter == 'All') {
                      if (index == 0) {
                        showHeader = true;
                      } else {
                        final prevTx = displayTransactions[index - 1];
                        final prevTxMonth = provider.getTransactionMonthYear(
                          prevTx,
                        );
                        if (currentTxMonth != prevTxMonth) {
                          showHeader = true;
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showHeader)
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            color: Colors.grey.shade100,
                            child: Text(
                              currentTxMonth,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (direction) {
                            provider.deleteTransaction(actualIndex);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Transaction deleted'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    provider.addTransaction(tx);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showTransactionBottomSheet(
                                context,
                                provider,
                                index: actualIndex,
                                tx: tx,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Transaction Icon
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: tx.isDebit
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        tx.isDebit
                                            ? Icons.arrow_outward
                                            : Icons.south_west,
                                        color: tx.isDebit
                                            ? Colors.red.shade600
                                            : Colors.green.shade600,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Transaction Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.keteranganKiri.isNotEmpty
                                                ? tx.keteranganKiri
                                                : 'No Title',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tx.dateOrStatus.replaceAll(
                                              '\n',
                                              ' ',
                                            ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Amount & Edit Icon
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          tx.amount,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: tx.isDebit
                                                ? Colors.red.shade700
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Icon(
                                          Icons.edit_note,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final provider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          _showTransactionBottomSheet(context, provider);
        },
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
