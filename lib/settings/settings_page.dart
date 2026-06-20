import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/pdf_parser_service.dart';
import 'manage_transactions_page.dart';
import '../models/transaction.dart';

class SettingsPage extends StatefulWidget {
  final String initialName;
  final String initialAccountNumber;
  final String initialBalance;

  const SettingsPage({
    super.key,
    required this.initialName,
    required this.initialAccountNumber,
    required this.initialBalance,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _balanceController;
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // --- TAMBAHAN BARU: List untuk menampung file sebelum diproses ---
  final List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _accountNumberController = TextEditingController(
      text: widget.initialAccountNumber,
    );
    _balanceController = TextEditingController(text: widget.initialBalance);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _balanceController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 1. Fungsi hanya untuk memilih file dan memasukkannya ke daftar tunggu
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        // Menambahkan file yang dipilih ke dalam list (mencegah duplikat bisa ditambahkan jika perlu)
        _selectedFiles.addAll(result.files);
      });
    }
  }

  // 2. Fungsi untuk menghapus file dari daftar tunggu
  void _removeSelectedFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  // 3. Fungsi untuk memproses file-file yang sudah disetujui di daftar tunggu
  Future<void> _processSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    List<TransactionModel> allTransactions = [];
    int successCount = 0;

    try {
      for (var file in _selectedFiles) {
        if (file.path != null) {
          String filePath = file.path!;
          String fileName = file.name;

          try {
            bool requiresPassword = await PdfParserService.isPasswordRequired(
              filePath,
            );
            String? password;
            if (requiresPassword) {
              password = await _showPasswordDialog(fileName);
            }

            final transactions = await PdfParserService.parseBcaStatement(
              filePath,
              password: password,
            );

            if (transactions.isNotEmpty) {
              allTransactions.addAll(transactions);
              successCount++;
            }
          } catch (fileError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to process $fileName: Incorrect format or password',
                  ),
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        if (allTransactions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No transactions found in the processed files.',
              ),
            ),
          );
        } else {
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).processNewPdfTransactions(allTransactions, "", "");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully read ${allTransactions.length} transactions from $successCount document files!',
              ),
            ),
          );

          // --- KOSONGKAN DAFTAR TUNGGU JIKA BERHASIL ---
          setState(() {
            _selectedFiles.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('System error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _showPasswordDialog([String? fileName]) async {
    _passwordController.clear();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            fileName != null ? 'Password PDF\n($fileName)' : 'Password PDF',
          ),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter password (DDMMYY)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Skip File'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _passwordController.text),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bcaBlue = const Color(0xFF004D8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Profile Banner (Using AssetImage background and sharp corners)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.zero,
              ),
              padding: EdgeInsets.only(
                bottom: 24,
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF004D8E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Account Number: ${_accountNumberController.text}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Profile Settings Card
                  _buildSectionHeader('Profile Information', Icons.badge_outlined),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _accountNumberController,
                            label: 'Account Number',
                            icon: Icons.credit_card_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _balanceController,
                            label: 'Balance',
                            icon: Icons.account_balance_wallet_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, {
                                  'name': _nameController.text,
                                  'accountNumber': _accountNumberController.text,
                                  'balance': _balanceController.text,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bcaBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: const Text(
                                'Save Profile Settings',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 3. Document Management Card
                  _buildSectionHeader('Upload & Manage Statement', Icons.cloud_upload_outlined),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Statement PDF',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select one or more statement PDF files to upload.',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(height: 16),

                          // File Selector Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _pickFiles,
                              icon: Icon(Icons.note_add_outlined, color: bcaBlue),
                              label: Text(
                                'Select PDF File',
                                style: TextStyle(color: bcaBlue, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: bcaBlue.withValues(alpha: 0.5)),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                          ),

                          // Staging List
                          if (_selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Files ready to process (${_selectedFiles.length}):',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF003366),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.zero,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _selectedFiles.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: Colors.grey.shade200),
                                itemBuilder: (context, index) {
                                  final file = _selectedFiles[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFFDE8E8),
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.grey),
                                      onPressed: _isLoading
                                          ? null
                                          : () => _removeSelectedFile(index),
                                      tooltip: 'Cancel processing this file',
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Process Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _processSelectedFiles,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(
                                  _isLoading
                                      ? 'Processing Documents...'
                                      : 'Process ${_selectedFiles.length} Document Files',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bcaBlue,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Manage Transactions Shortcut Card
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE5F6FA),
                        child: Icon(Icons.edit_note, color: bcaBlue),
                      ),
                      title: const Text(
                        'Manage Manual Transactions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      subtitle: const Text(
                        'Edit, delete, or add transactions manually',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: bcaBlue),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageTransactionsPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. System Status Indicator
                  Consumer<TransactionProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Status: ${provider.transactions.length} transactions active in system.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF004D8E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004D8E),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: const Color(0xFF004D8E), size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF004D8E), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
    );
  }
}
