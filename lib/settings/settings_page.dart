import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/pdf_parser_service.dart';
import '../models/transaction.dart';

class SettingsPage extends StatefulWidget {
  final String initialName;
  final String initialBcaId;
  final String initialAccountNumber;
  final String initialBalance;

  const SettingsPage({
    super.key,
    required this.initialName,
    required this.initialBcaId,
    required this.initialAccountNumber,
    required this.initialBalance,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _bcaIdController;
  late TextEditingController _accountNumberController;
  late TextEditingController _balanceController;
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // --- List untuk menampung file sebelum diproses ---
  final List<PlatformFile> _selectedFiles = [];

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bcaIdController = TextEditingController(text: widget.initialBcaId);
    _accountNumberController = TextEditingController(
      text: widget.initialAccountNumber,
    );
    _balanceController = TextEditingController(text: widget.initialBalance);

    // Listen to any change
    for (final c in [
      _nameController,
      _bcaIdController,
      _accountNumberController,
      _balanceController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _bcaIdController,
      _accountNumberController,
      _balanceController,
      _passwordController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _saveAll() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Save User Profile (Name, BCA ID, Account, Balance)
    provider.setUserProfile(
      _nameController.text.trim(),
      _bcaIdController.text.trim(),
      _accountNumberController.text.trim(),
      _balanceController.text.trim(),
    );

    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua pengaturan berhasil disimpan!'),
        backgroundColor: Color(0xFF004D8E),
      ),
    );
  }

  Future<void> _handleBackNavigation() async {
    if (!_hasChanges) {
      if (mounted) {
        Navigator.pop(context, {
          'name': _nameController.text,
          'bcaId': _bcaIdController.text,
          'accountNumber': _accountNumberController.text,
          'balance': _balanceController.text,
        });
      }
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'Simpan Perubahan?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ada perubahan yang belum disimpan. Simpan sebelum keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text('Buang', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D8E),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == 'save') {
      _saveAll();
      setState(() => _hasChanges = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context, {
            'name': _nameController.text,
            'accountNumber': _accountNumberController.text,
            'balance': _balanceController.text,
          });
        }
      });
    } else if (result == 'discard') {
      setState(() => _hasChanges = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
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

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    List<TransactionModel> allTransactions = [];
    int successCount = 0;

    Map<String, double> newMonthlyBalances = {};
    double? oldestStartingBalance;
    DateTime? oldestDate;

    DateTime parseDateSimple(String dateStr) {
      try {
        final parts = dateStr.split('\n');
        if (parts.length < 3) return DateTime.now();
        int day = int.parse(parts[0]);
        int year = int.parse(parts[2]);
        String monthStr = parts[1].toLowerCase();
        int month = 1;
        if (monthStr.startsWith('jan')) {
          month = 1;
        } else if (monthStr.startsWith('feb')) {
          month = 2;
        } else if (monthStr.startsWith('mar')) {
          month = 3;
        } else if (monthStr.startsWith('apr')) {
          month = 4;
        } else if (monthStr.startsWith('may') || monthStr.startsWith('mei')) {
          month = 5;
        } else if (monthStr.startsWith('jun')) {
          month = 6;
        } else if (monthStr.startsWith('jul')) {
          month = 7;
        } else if (monthStr.startsWith('aug') || monthStr.startsWith('agu')) {
          month = 8;
        } else if (monthStr.startsWith('sep')) {
          month = 9;
        } else if (monthStr.startsWith('oct') || monthStr.startsWith('okt')) {
          month = 10;
        } else if (monthStr.startsWith('nov')) {
          month = 11;
        } else if (monthStr.startsWith('dec') || monthStr.startsWith('des')) {
          month = 12;
        }
        return DateTime(year, month, day);
      } catch (e) {
        return DateTime.now();
      }
    }

    try {
      for (var file in _selectedFiles) {
        if (file.path != null) {
          String filePath = file.path!;
          String fileName = file.name;

          try {
            final transactions = await PdfParserService.parseBcaStatement(
              filePath,
              password: null,
            );

            if (transactions.isNotEmpty) {
              allTransactions.addAll(transactions);
              successCount++;

              DateTime fileDate = parseDateSimple(
                transactions.first.dateOrStatus,
              );

              newMonthlyBalances.addAll(
                PdfParserService.detectedMonthlyBalances,
              );

              if (oldestDate == null || fileDate.isBefore(oldestDate)) {
                oldestDate = fileDate;
                oldestStartingBalance =
                    PdfParserService.detectedStartingBalance;
              }

              // Copy original statement PDF to Application Documents directory
              final firstTx = transactions.first;
              final parts = firstTx.dateOrStatus.split('\n');
              if (parts.length >= 3) {
                String monthShort = parts[1];
                String year = parts[2];
                String indoMonth = provider.mapMonthToIndonesian(monthShort);
                String periodKey = "$indoMonth $year";

                final appDir = await getApplicationDocumentsDirectory();
                final savedDir = Directory('${appDir.path}/uploaded_pdfs');
                if (!await savedDir.exists()) {
                  await savedDir.create(recursive: true);
                }
                final savedPdfPath =
                    '${savedDir.path}/${_accountNumberController.text.trim()}_$periodKey.pdf';
                await File(filePath).copy(savedPdfPath);

                provider.setPdfPath(periodKey, savedPdfPath);
              }
            }
          } catch (fileError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gagal memproses $fileName: Format salah atau password salah',
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
                'Tidak ada transaksi yang ditemukan dalam file yang diproses.',
              ),
            ),
          );
        } else {
          provider.processNewPdfTransactions(
            allTransactions,
            "",
            "",
            newMonthlyBalances,
          );

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

            if (PdfParserService.detectedName.isNotEmpty) {
              _nameController.text = PdfParserService.detectedName;
            }
            if (PdfParserService.detectedAccountNumber.isNotEmpty) {
              _accountNumberController.text =
                  PdfParserService.detectedAccountNumber;
            }
            if (oldestStartingBalance != null) {
              _balanceController.text = oldestStartingBalance.toStringAsFixed(
                0,
              );
            } else {
              _balanceController.text = PdfParserService.detectedStartingBalance
                  .toStringAsFixed(0);
            }
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

  String getIndonesianMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
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
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bcaBlue = const Color(0xFF004D8E);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Pengaturan',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: _handleBackNavigation,
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
                      'Nomor Rekening: ${_accountNumberController.text}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Profile Settings Card
                    _buildSectionHeader(
                      'Informasi Profil',
                      Icons.badge_outlined,
                    ),
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
                              label: 'Nama Lengkap',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _bcaIdController,
                              label: 'Sensor BCA ID (ex: HI********O)',
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _accountNumberController,
                              label: 'Nomor Rekening',
                              icon: Icons.credit_card_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _balanceController,
                              label: 'Saldo',
                              icon: Icons.account_balance_wallet_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 3. Document Management Card
                    _buildSectionHeader(
                      'Unggah & Kelola Mutasi',
                      Icons.cloud_upload_outlined,
                    ),
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
                              'Unggah PDF Mutasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003366),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pilih satu atau lebih file PDF mutasi untuk diunggah.',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // File Selector Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _pickFiles,
                                icon: Icon(
                                  Icons.note_add_outlined,
                                  color: bcaBlue,
                                ),
                                label: Text(
                                  'Pilih File PDF',
                                  style: TextStyle(
                                    color: bcaBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: bcaBlue.withValues(alpha: 0.5),
                                  ),
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
                                'File siap diproses (${_selectedFiles.length}):',
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
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _selectedFiles.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  itemBuilder: (context, index) {
                                    final file = _selectedFiles[index];
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
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
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.grey,
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () => _removeSelectedFile(index),
                                        tooltip: 'Batal memproses file ini',
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
                                  onPressed: _isLoading
                                      ? null
                                      : _processSelectedFiles,
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
                                        ? 'Memproses Dokumen...'
                                        : 'Proses ${_selectedFiles.length} File Dokumen',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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

                    // 4. Clear PDF Data Card
                    Card(
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: const Icon(
                            Icons.delete_sweep,
                            color: Colors.red,
                          ),
                        ),
                        title: const Text(
                          'Hapus Data PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: const Text(
                          'Hapus semua transaksi PDF yang diunggah dan mulai dari awal',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                        onTap: () async {
                          final provider = Provider.of<TransactionProvider>(
                            context,
                            listen: false,
                          );
                          final periods = provider.pdfPaths.keys.toList();

                          if (periods.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Data PDF'),
                                content: const Text(
                                  'Tidak ada data PDF mutasi yang diunggah.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  final currentPeriods = provider.pdfPaths.keys
                                      .toList();
                                  currentPeriods.sort(
                                    (a, b) => b.compareTo(a),
                                  ); // Sort descending by default
                                  return AlertDialog(
                                    title: const Text(
                                      'Pilih PDF untuk Dihapus',
                                    ),
                                    content: currentPeriods.isEmpty
                                        ? const Text(
                                            'Semua data PDF telah dihapus.',
                                          )
                                        : Container(
                                            width: double.maxFinite,
                                            constraints: const BoxConstraints(
                                              maxHeight: 250,
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: currentPeriods.length,
                                              itemBuilder: (context, index) {
                                                final period =
                                                    currentPeriods[index];
                                                return ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Text(
                                                    period.toUpperCase(),
                                                  ),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () async {
                                                      final confirmDelete = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text(
                                                            'Hapus Periode?',
                                                          ),
                                                          content: Text(
                                                            'Hapus data transaksi untuk periode $period? Tindakan ini tidak dapat dibatalkan.',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                              child: const Text(
                                                                'Batal',
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              child: const Text(
                                                                'Hapus',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirmDelete ==
                                                          true) {
                                                        provider
                                                            .deleteTransactionsForPeriod(
                                                              period,
                                                            );
                                                        setStateDialog(() {});
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Data transaksi periode $period telah dihapus.',
                                                              ),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Tutup'),
                                      ),
                                      if (currentPeriods.isNotEmpty)
                                        ElevatedButton(
                                          onPressed: () async {
                                            final confirmAll = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Hapus Semua Data?',
                                                ),
                                                content: const Text(
                                                  'Ini akan menghapus semua data transaksi yang saat ini dimuat di aplikasi. Tindakan ini tidak dapat dibatalkan. Apakah Anda yakin?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Batal'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                    child: const Text(
                                                      'Hapus Semua',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmAll == true) {
                                              provider.clearTransactions();
                                              if (context.mounted) {
                                                Navigator.pop(
                                                  context,
                                                ); // Close selection dialog
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Semua data transaksi PDF telah dihapus.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Hapus Semua'),
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
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
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Status: ${provider.transactions.length} transaksi aktif di sistem.',
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
        // ─── Single sticky Save button at the bottom ───
        bottomNavigationBar: _hasChanges
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saveAll,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Simpan Semua Perubahan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D8E),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black38,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ), // end Scaffold
    ); // end PopScope
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
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 13,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF004D8E), size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
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
