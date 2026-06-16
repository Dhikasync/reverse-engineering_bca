import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class EStatementPage extends StatefulWidget {
  const EStatementPage({Key? key}) : super(key: key);

  @override
  State<EStatementPage> createState() => _EStatementPageState();
}

class _EStatementPageState extends State<EStatementPage> {
  // Fungsi untuk memformat teks (misal: "JUNI 2023" jadi "Juni 2023")
  String _formatMonthDisplay(String rawMonth) {
    return rawMonth
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data bulan dari CRUD provider
    final provider = Provider.of<TransactionProvider>(context);
    final months = provider.uploadedMonths;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F4F6,
      ), // Warna abu-abu terang background
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D8E), // Biru BCA
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'e-Statement',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Aksi untuk tombol Info
            },
            child: Text(
              'Info',
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // 1. Opsi: Pilih Bulan dan Tahun
          Container(
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              title: Text(
                'Pilih Bulan dan Tahun',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Fungsionalitas pajangan / bisa dikembangkan nanti
              },
            ),
          ),

          const SizedBox(height: 24),

          // 2. Header: Bulan yang diunduh
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              'Bulan yang diunduh',
              style: GoogleFonts.openSans(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 3. List: Daftar bulan dari CRUD
          Container(
            color: Colors.white,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: months.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                indent: 20, // Garis tidak full sampai pinggir kiri
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final monthStr = months[index];
                final displayMonth = _formatMonthDisplay(monthStr);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 2,
                  ),
                  title: Text(
                    displayMonth,
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF003366),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Opsional: Jika dipilih, kembali ke halaman info akun
                    Navigator.pop(context, monthStr);
                  },
                );
              },
            ),
          ),

          // Garis penutup bawah untuk list terakhir
          Container(height: 1, color: const Color(0xFFEEEEEE)),
        ],
      ),
    );
  }
}
