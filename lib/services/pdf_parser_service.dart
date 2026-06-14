import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/transaction.dart';

class PdfParserService {
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
      final yearRegex = RegExp(r'PERIODE\s*:\s*[A-Za-z]+\s*(\d{4})', caseSensitive: false);
      final yearMatch = yearRegex.firstMatch(text);
      if (yearMatch != null) {
        currentYear = yearMatch.group(1)!;
      }
      
      final lines = text.split('\n');
      final RegExp dateRegex = RegExp(r'^(\d{2}/\d{2})');
      final RegExp amountRegex = RegExp(r'\b\d{1,3}(?:,\d{3})*\.\d{2}\b');
      
      List<String> currentBlock = [];
      
      void processBlock() {
        if (currentBlock.isEmpty) return;
        
        String fullText = currentBlock.join('\n');
        
        // Abaikan jika ini saldo awal
        if (fullText.contains('SALDO AWAL')) return;
        
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
            title = title.replaceAll(RegExp(r'\bCR\b'), ''); // CR is sometimes explicit
            
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
          // Berhenti jika ketemu footer atau halaman baru
          if (line.startsWith('Bersambung ke halaman berikut') || 
              line.startsWith('REKENING TAHAPAN XPRESI') ||
              line.startsWith('MUTASI CR') ||
              line.startsWith('SALDO AKHIR')) {
            processBlock();
            currentBlock = [];
          } else {
            // Abaikan header halaman baru
            if (!line.startsWith('KCP ') && 
                !line.startsWith('NO. REKENING') &&
                !line.startsWith('HALAMAN') &&
                !line.startsWith('PERIODE') &&
                !line.startsWith('MATA UANG') &&
                !line.startsWith('TANGGAL KETERANGAN') &&
                !line.startsWith('CATATAN:') &&
                !line.startsWith('Apabila nasabah tidak') &&
                !line.startsWith('Rekening ini sampai') &&
                !line.startsWith('telah menyetujui') &&
                !line.startsWith('Rekening ini.') &&
                !line.startsWith('•') &&
                !line.startsWith('BCA berhak') &&
                !line.startsWith('Laporan Mutasi') &&
                !line.contains('TANDES') &&
                !line.contains('JAWA TIMUR') &&
                !line.contains('INDONESIA')) {
              // Jika ini bukan teks dari header halaman, tambahkan ke block
              // Tapi untuk aman, biarkan saja masuk ke title, nanti tidak apa-apa karena kita potong saat 'REKENING TAHAPAN'
              currentBlock.add(line);
            }
          }
        }
      }
      // Proses block terakhir
      processBlock();
      
      document.dispose();
    } catch (e) {
      print('Error parsing PDF: $e');
      throw Exception('Gagal membaca PDF. Pastikan file valid atau password benar.');
    }

    return transactions;
  }
}
