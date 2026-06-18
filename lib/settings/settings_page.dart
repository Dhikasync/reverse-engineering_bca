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
  List<PlatformFile> _selectedFiles = [];

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
                    'Gagal memproses $fileName: Format salah atau password keliru',
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
                'Tidak ada transaksi yang ditemukan dari file yang diproses.',
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
                'Berhasil membaca ${allTransactions.length} transaksi dari $successCount file dokumen!',
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
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan sistem: $e')));
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
              hintText: 'Masukkan password (DDMMYY)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Lewati File'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF005BAC),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': _nameController.text,
                      'accountNumber': _accountNumberController.text,
                      'balance': _balanceController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BAC),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Simpan Pengaturan Profil',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Upload & Kelola Mutasi Rekening',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih satu atau lebih file PDF mutasi untuk di-upload.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // --- TOMBOL PILIH FILE ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickFiles,
                  icon: const Icon(Icons.note_add, color: Color(0xFF005BAC)),
                  label: const Text(
                    'Pilih File PDF',
                    style: TextStyle(color: Color(0xFF005BAC)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF005BAC)),
                  ),
                ),
              ),

              // --- DAFTAR FILE YANG DIPILIH (STAGING AREA) ---
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'File yang siap diproses:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedFiles.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          file.name,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: _isLoading
                              ? null
                              : () => _removeSelectedFile(index),
                          tooltip: 'Batal proses file ini',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // --- TOMBOL PROSES SEMUA FILE ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _processSelectedFiles,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(
                      _isLoading
                          ? 'Memproses Dokumen...'
                          : 'Proses ${_selectedFiles.length} File Dokumen',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005BAC),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // --- TOMBOL EDIT / KELOLA TRANSAKSI ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageTransactionsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note, color: Color(0xFF005BAC)),
                  label: const Text(
                    'Kelola / Tambah Transaksi Manual',
                    style: TextStyle(color: Color(0xFF005BAC)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF005BAC)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  return Text(
                    'Status: ${provider.transactions.length} transaksi masuk ke dalam sistem.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
