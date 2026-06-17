import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/transaction.dart';

class PdfParserService {
  // Menyimpan deteksi Bulan & Tahun dari PDF terakhir
  static String detectedMonth = "";
  static String detectedYear = "";
  static double detectedStartingBalance = 734147.95;

  static Future<bool> isPasswordRequired(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      document.dispose();
      return false; // Berhasil dibuka tanpa password
    } catch (e) {
      // Jika terjadi error (misalnya ArgumentError 'Invalid Password'), berarti butuh password
      return true;
    }
  }

  static Future<List<TransactionModel>> parseBcaStatement(String filePath, {String? password}) async {
    final List<TransactionModel> transactions = [];

    try {
      final bytes = await File(filePath).readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes, password: password);
      final String text = PdfTextExtractor(document).extractText(layoutText: true);
      
      String currentYear = DateTime.now().year.toString();
      
      // Regex untuk menangkap Bulan dan Tahun
      final periodRegex = RegExp(r'PERIODE\s*:.*?([A-Za-z]+)\s*(\d{4})', caseSensitive: false);
      final periodMatch = periodRegex.firstMatch(text);
      if (periodMatch != null) {
        detectedMonth = periodMatch.group(1)!.toUpperCase(); 
        detectedYear = periodMatch.group(2)!;              
        currentYear = detectedYear;
      }
      
      final lines = text.split('\n');
      final RegExp dateRegex = RegExp(r'^(\d{2}/\d{2})');
      final RegExp amountRegex = RegExp(r'\b\d{1,3}(?:,\d{3})*\.\d{2}\b');
      
      List<String> currentBlock = [];
      
      void processBlock() {
        if (currentBlock.isEmpty) return;
        
        String fullText = currentBlock.join('\n');
        
        // Abaikan jika ini saldo awal
        if (fullText.contains('SALDO AWAL')) {
          final match = amountRegex.firstMatch(fullText);
          if (match != null) {
            final valStr = match.group(0)!.replaceAll(',', '');
            detectedStartingBalance = double.tryParse(valStr) ?? 734147.95;
          }
          return;
        }
        
        final dateMatch = dateRegex.firstMatch(currentBlock.first);
        if (dateMatch == null) return;
        
        String date = dateMatch.group(1)!;
        
        List<String> parts = date.split('/');
        String day = parts[0];
        String monthNum = parts[1];
        List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        int monthIndex = int.tryParse(monthNum) ?? 1;
        String monthStr = monthNames[(monthIndex - 1).clamp(0, 11)];
        String formattedDate = '$day\n$monthStr\n$currentYear';
        
        // Cari baris terakhir yang mengandung format amount
        int lastAmountLineIndex = -1;
        for (int i = currentBlock.length - 1; i >= 0; i--) {
          if (amountRegex.hasMatch(currentBlock[i])) {
            lastAmountLineIndex = i;
            break;
          }
        }
        
        if (lastAmountLineIndex != -1) {
          String amountLine = currentBlock[lastAmountLineIndex];
          final matches = amountRegex.allMatches(amountLine);
          
          if (matches.isNotEmpty) {
            String mutasiAmount = matches.first.group(0)!;
            String? saldoAmount = matches.length > 1 ? matches.last.group(0) : null;
            
            bool isDebit = fullText.contains(RegExp(r'\bDB\b'));
            
            // Bersihkan judul dari tanggal, amount mutasi, amount saldo, dan DB/CR
            String title = fullText;
            title = title.replaceFirst(date, '');
            title = title.replaceFirst(mutasiAmount, '');
            if (saldoAmount != null) {
              title = title.replaceFirst(saldoAmount, '');
            }
            title = title.replaceAll(RegExp(r'\bDB\b'), '');
            title = title.replaceAll(RegExp(r'\bCR\b'), ''); 
            
            // Bersihkan spasi ganda dan baris kosong
            title = title.replaceAll(RegExp(r' {2,}'), ' ').trim();
            final titleLines = title.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            title = titleLines.join('\n');
            
            transactions.add(TransactionModel(
              dateOrStatus: formattedDate,
              title: title,
              subtitle: isDebit ? 'TRANSAKSI DEBIT' : 'TRANSAKSI KREDIT',
              amount: 'IDR $mutasiAmount',
              isDebit: isDebit,
            ));
          }
        }
      }
      
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;
        
        if (dateRegex.hasMatch(line)) {
          // Proses block sebelumnya
          processBlock();
          // Mulai block baru
          currentBlock = [line];
        } else if (currentBlock.isNotEmpty) {
          String upperLine = line.toUpperCase();
          
          // Berhenti jika ketemu footer atau halaman baru (Dibuat Dinamis / Universal)
          if (upperLine.contains('BERSAMBUNG KE HALAMAN BERIKUT') || 
              upperLine.contains('REKENING TAHAPAN') || // Mengcover Xpresi, Tahapan BCA, dll
              upperLine.contains('TAPRES') ||
              upperLine.contains('REKENING GIRO') ||
              upperLine.startsWith('MUTASI CR') ||
              upperLine.startsWith('SALDO AKHIR')) {
            processBlock();
            currentBlock = [];
          } else {
            // Abaikan header halaman baru dengan format baku dari BCA
            // Tanpa hardcode nama cabang/wilayah
            if (!upperLine.startsWith('KCP ') && 
                !upperLine.startsWith('CABANG ') &&
                !upperLine.startsWith('NO. REKENING') &&
                !upperLine.startsWith('NAMA') &&
                !upperLine.startsWith('ALAMAT') &&
                !upperLine.startsWith('HALAMAN') &&
                !upperLine.startsWith('PERIODE') &&
                !upperLine.startsWith('MATA UANG') &&
                !upperLine.startsWith('TANGGAL KETERANGAN') &&
                !upperLine.startsWith('CATATAN:') &&
                !upperLine.startsWith('APABILA NASABAH TIDAK') &&
                !upperLine.startsWith('REKENING INI SAMPAI') &&
                !upperLine.startsWith('TELAH MENYETUJUI') &&
                !upperLine.startsWith('REKENING INI.') &&
                !upperLine.startsWith('•') &&
                !upperLine.startsWith('BCA BERHAK') &&
                !upperLine.startsWith('LAPORAN MUTASI') &&
                !upperLine.contains('PT BANK CENTRAL ASIA')) {
              
              // Jika ini murni teks keterangan transaksi, tambahkan ke block
              currentBlock.add(line);
            }
          }
        }
      }
      // Proses block terakhir
      processBlock();
      
      document.dispose();
    } catch (e) {
      debugPrint('Error parsing PDF: $e');
      throw Exception('Gagal membaca PDF. Pastikan file valid atau password benar.');
    }

    return transactions;
  }
}