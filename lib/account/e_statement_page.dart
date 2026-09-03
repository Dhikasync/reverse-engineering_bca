import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:reverse_engineering_bca/account/e_statement_viewer_page.dart';
import '../providers/transaction_provider.dart';
import 'package:reverse_engineering_bca/periode/pilih_periode_page.dart';
import '../widgets/animated_bca_logo.dart';

class EStatementPage extends StatefulWidget {
  final String userName;
  final String accountNumber;
  final String balance;
  final String accountTypeDetail;

  const EStatementPage({
    super.key,
    required this.userName,
    required this.accountNumber,
    required this.balance,
    required this.accountTypeDetail,
  });

  @override
  State<EStatementPage> createState() => _EStatementPageState();
}

class _EStatementPageState extends State<EStatementPage> {
  String _formatMonthDisplay(String rawMonth) {
    return rawMonth.toUpperCase();
  }

  String _formatAccountNumber(String rawNumber) {
    if (rawNumber.length < 10) return rawNumber;
    return '${rawNumber.substring(0, 3)} - ${rawNumber.substring(3, 6)} - ${rawNumber.substring(6)}';
  }

  DateTime _parsePeriodToDate(String period) {
    final parts = period.split(' ');
    if (parts.isEmpty) return DateTime.now();

    String monthStr = parts[0].toLowerCase();
    int year = parts.length > 1
        ? (int.tryParse(parts[1]) ?? DateTime.now().year)
        : DateTime.now().year;

    int month = 1;
    if (monthStr.contains('jan')) {
      month = 1;
    } else if (monthStr.contains('feb')) {
      month = 2;
    } else if (monthStr.contains('mar')) {
      month = 3;
    } else if (monthStr.contains('apr')) {
      month = 4;
    } else if (monthStr.contains('mei') || monthStr.contains('may')) {
      month = 5;
    } else if (monthStr.contains('jun')) {
      month = 6;
    } else if (monthStr.contains('jul')) {
      month = 7;
    } else if (monthStr.contains('agu') || monthStr.contains('aug')) {
      month = 8;
    } else if (monthStr.contains('sep')) {
      month = 9;
    } else if (monthStr.contains('okt') || monthStr.contains('oct')) {
      month = 10;
    } else if (monthStr.contains('nov')) {
      month = 11;
    } else if (monthStr.contains('des') || monthStr.contains('dec')) {
      month = 12;
    }

    return DateTime(year, month);
  }

  Future<void> _exportPdf(String selectedPeriod) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(child: AnimatedBCALogo()),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final pdfPath = provider.pdfPaths[selectedPeriod];

      if (pdfPath == null || !File(pdfPath).existsSync()) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File PDF asli tidak ditemukan. Silakan unggah ulang di Pengaturan.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.pop(context);

      DateTime statementDate = _parsePeriodToDate(selectedPeriod);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EStatementViewerPage(
            pdfPath: pdfPath,
            accountNumber: widget.accountNumber,
            statementDate: statementDate,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka penampil PDF: $e')),
        );
      }
    }
  }

  Widget _buildPeriodIcon({required bool isSpecial}) {
    final color = isSpecial ? const Color(0xFFBDBDBD) : const Color(0xFF03A9F4);
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Icon(Icons.description, color: color, size: 28),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Text(
                'Rp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final months = provider.uploadedMonths;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tabungan dan Giro',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No. Rekening',
                          style: GoogleFonts.openSans(
                            color: const Color(0xFF003366),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF03A9F4), Color(0xFF005DAA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatAccountNumber(widget.accountNumber),
                                  style: GoogleFonts.openSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF003366),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TAHAPAN - IDR',
                                  style: GoogleFonts.openSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(
                                      0xFF003366,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Pilih Periode',
                          style: GoogleFonts.openSans(
                            color: const Color(0xFF003366),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount:
                              (months.length > 3 ? 3 : months.length) + 1,
                          itemBuilder: (context, index) {
                            final limit = months.length > 3 ? 3 : months.length;

                            if (index < limit) {
                              final monthStr = months[index];
                              final displayMonth = _formatMonthDisplay(
                                monthStr,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    leading: _buildPeriodIcon(isSpecial: false),
                                    title: Text(
                                      displayMonth,
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF003366),
                                      ),
                                    ),
                                    trailing: Text(
                                      'TAMPILKAN',
                                      style: GoogleFonts.openSans(
                                        color: const Color(0xFF003366),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () => _exportPdf(monthStr),
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    leading: _buildPeriodIcon(isSpecial: true),
                                    title: Text(
                                      'Pilih Periode Lain',
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF003366),
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFF003366),
                                      size: 24,
                                    ),
                                    onTap: () async {
                                      // Menggunakan callback agar saat back dari PDF viewer kembali ke PilihPeriodePage
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PilihPeriodePage(
                                                onTampilkan: (selectedPeriod) {
                                                  _exportPdf(selectedPeriod);
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
