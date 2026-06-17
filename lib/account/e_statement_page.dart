import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/transaction_provider.dart';

class EStatementPage extends StatefulWidget {
  final String userName;
  final String accountNumber;
  final String balance;

  const EStatementPage({
    super.key,
    required this.userName,
    required this.accountNumber,
    required this.balance,
  });

  @override
  State<EStatementPage> createState() => _EStatementPageState();
}

class _EStatementPageState extends State<EStatementPage> {
  String _formatMonthDisplay(String rawMonth) {
    return rawMonth.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatDateForPdf(String dateOrStatus) {
    final List<String> parts = dateOrStatus.split('\n');
    if (parts.length >= 2) {
      final String day = parts[0].padLeft(2, '0');
      final String monthStr = parts[1].toLowerCase();

      final Map<String, String> monthsMap = {
        'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04', 'may': '05', 'mei': '05',
        'jun': '06', 'jul': '07', 'aug': '08', 'agu': '08', 'sep': '09', 'oct': '10',
        'okt': '10', 'nov': '11', 'dec': '12', 'des': '12'
      };

      String monthNum = '01';
      for (var key in monthsMap.keys) {
        if (monthStr.startsWith(key)) {
          monthNum = monthsMap[key]!;
          break;
        }
      }
      return '$day/$monthNum';
    }
    return dateOrStatus;
  }

  // Fungsi menggambar kotak melengkung (Rounded Rectangle)
  void _drawRoundedRect(PdfGraphics graphics, PdfPen pen, Rect bounds, double radius) {
    final PdfPath path = PdfPath();
    double d = radius * 2;
    
    path.addArc(Rect.fromLTWH(bounds.left, bounds.top, d, d), 180, 90);
    path.addLine(Offset(bounds.left + radius, bounds.top), Offset(bounds.right - radius, bounds.top));
    path.addArc(Rect.fromLTWH(bounds.right - d, bounds.top, d, d), 270, 90);
    path.addLine(Offset(bounds.right, bounds.top + radius), Offset(bounds.right, bounds.bottom - radius));
    path.addArc(Rect.fromLTWH(bounds.right - d, bounds.bottom - d, d, d), 0, 90);
    path.addLine(Offset(bounds.right - radius, bounds.bottom), Offset(bounds.left + radius, bounds.bottom));
    path.addArc(Rect.fromLTWH(bounds.left, bounds.bottom - d, d, d), 90, 90);
    path.addLine(Offset(bounds.left, bounds.bottom - radius), Offset(bounds.left, bounds.top + radius));
    
    graphics.drawPath(path, pen: pen);
  }

  void _drawPageDecorations(PdfPage page, int pageNum, int totalPages, String periodStr, PdfBitmap? logo) {
    final PdfGraphics graphics = page.graphics;

    final PdfFont fontTitle = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final PdfFont fontRegular = PdfStandardFont(PdfFontFamily.helvetica, 7);
    final PdfFont fontBold = PdfStandardFont(PdfFontFamily.helvetica, 7, style: PdfFontStyle.bold);
    
    // Font khusus catatan (judul 7, isi 6 + italic)
    final PdfFont fontCatatanTitle = PdfStandardFont(PdfFontFamily.helvetica, 7, style: PdfFontStyle.bold);
    final PdfFont fontSmallItalic = PdfStandardFont(PdfFontFamily.helvetica, 6, style: PdfFontStyle.italic);
    
    final PdfPen linePen = PdfPen(PdfColor(0, 0, 0), width: 0.5);

    // 1. Logo BCA
    if (logo != null) {
      graphics.drawImage(logo, const Rect.fromLTWH(25.0, 20.0, 75.0, 25.0));
    } else {
      final PdfFont fontBCA = PdfStandardFont(PdfFontFamily.helvetica, 16, multiStyle: [PdfFontStyle.bold, PdfFontStyle.italic]);
      graphics.drawString('BCA', fontBCA, bounds: const Rect.fromLTWH(25.0, 25.0, 100.0, 20.0));
    }

    // 2. Judul Rekening (Tengah)
    graphics.drawString(
      'REKENING TAHAPAN XPRESI',
      fontTitle,
      bounds: const Rect.fromLTWH(0.0, 25.0, 595.0, 20.0),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // 3. Nama Cabang (X disamakan dengan teks nama nasabah, yaitu 35.0)
    graphics.drawString('KCP PERAK', fontBold, bounds: const Rect.fromLTWH(35.0, 55.0, 200.0, 10.0));

    // ==========================================
    // 4. KOTAK KIRI (Nama & Alamat Nasabah)
    // ==========================================
    double boxY = 72.0; 
    double boxWidth = 260.0;
    double boxHeight = 80.0;
    double borderRadius = 5.0; 

    _drawRoundedRect(graphics, linePen, Rect.fromLTWH(25.0, boxY, boxWidth, boxHeight), borderRadius);

    double textLeftX = 35.0;
    double textLeftY = boxY + 10.0;

    graphics.drawString(widget.userName.toUpperCase(), fontBold, bounds: Rect.fromLTWH(textLeftX, textLeftY, 240.0, 10.0));
    graphics.drawString('TANDES', fontBold, bounds: Rect.fromLTWH(textLeftX, textLeftY + 11.0, 240.0, 10.0));
    graphics.drawString('RT005 RW006 JAWA TIMUR', fontBold, bounds: Rect.fromLTWH(textLeftX, textLeftY + 22.0, 240.0, 10.0));
    graphics.drawString('GADEL TENGAH II NO 05', fontBold, bounds: Rect.fromLTWH(textLeftX, textLeftY + 33.0, 240.0, 10.0));
    graphics.drawString('SURABAYA 60186', fontBold, bounds: Rect.fromLTWH(textLeftX, textLeftY + 44.0, 240.0, 10.0));
    graphics.drawString('INDONESIA', fontBold, bounds: Rect.fromLTWH(textLeftX, textLeftY + 55.0, 240.0, 10.0));

    // ==========================================
    // 5. KOTAK KANAN (Info Rekening)
    // ==========================================
    double rightBoxX = 310.0; 

    _drawRoundedRect(graphics, linePen, Rect.fromLTWH(rightBoxX, boxY, boxWidth, boxHeight), borderRadius);

    double textRightX = rightBoxX + 15.0;
    double textRightY = boxY + 15.0; 
    double colonX = rightBoxX + 85.0;
    double valueX = rightBoxX + 95.0;

    graphics.drawString('NO. REKENING', fontBold, bounds: Rect.fromLTWH(textRightX, textRightY, 80.0, 10.0));
    graphics.drawString(':', fontBold, bounds: Rect.fromLTWH(colonX, textRightY, 10.0, 10.0));
    graphics.drawString(widget.accountNumber, fontBold, bounds: Rect.fromLTWH(valueX, textRightY, 120.0, 10.0));

    graphics.drawString('HALAMAN', fontBold, bounds: Rect.fromLTWH(textRightX, textRightY + 14.0, 80.0, 10.0));
    graphics.drawString(':', fontBold, bounds: Rect.fromLTWH(colonX, textRightY + 14.0, 10.0, 10.0));
    graphics.drawString('$pageNum / $totalPages', fontBold, bounds: Rect.fromLTWH(valueX, textRightY + 14.0, 120.0, 10.0));

    graphics.drawString('PERIODE', fontBold, bounds: Rect.fromLTWH(textRightX, textRightY + 28.0, 80.0, 10.0));
    graphics.drawString(':', fontBold, bounds: Rect.fromLTWH(colonX, textRightY + 28.0, 10.0, 10.0));
    graphics.drawString(periodStr, fontBold, bounds: Rect.fromLTWH(valueX, textRightY + 28.0, 120.0, 10.0));

    graphics.drawString('MATA UANG', fontBold, bounds: Rect.fromLTWH(textRightX, textRightY + 42.0, 80.0, 10.0));
    graphics.drawString(':', fontBold, bounds: Rect.fromLTWH(colonX, textRightY + 42.0, 10.0, 10.0));
    graphics.drawString('IDR', fontBold, bounds: Rect.fromLTWH(valueX, textRightY + 42.0, 120.0, 10.0));

    // ==========================================
    // 6. KOTAK CATATAN (2 Kolom rata kiri-kanan / justify)
    // ==========================================
    double catBoxY = 162.0;
    double catBoxHeight = 42.0;
    
    _drawRoundedRect(graphics, linePen, Rect.fromLTWH(25.0, catBoxY, 545.0, catBoxHeight), borderRadius);
    
    // Judul Catatan ditarik ke kiri atas kotak (X=32, Y=catBoxY+4)
    graphics.drawString('CATATAN:', fontCatatanTitle, bounds: Rect.fromLTWH(32.0, catBoxY + 4.0, 100.0, 10.0));

    final PdfStringFormat justifyFormat = PdfStringFormat(alignment: PdfTextAlignment.justify);

    // Poin & Kolom Kiri
    graphics.drawString('•', fontSmallItalic, bounds: Rect.fromLTWH(32.0, catBoxY + 14.0, 10.0, 10.0));
    graphics.drawString(
      'Apabila nasabah tidak melakukan sanggahan atas Laporan Mutasi Rekening ini sampai dengan akhir bulan berikutnya, nasabah dianggap telah menyetujui segala data yang tercantum pada Laporan Mutasi Rekening ini.', 
      fontSmallItalic, 
      bounds: Rect.fromLTWH(39.0, catBoxY + 14.0, 245.0, 25.0), 
      format: justifyFormat
    );

    // Poin & Kolom Kanan
    graphics.drawString('•', fontSmallItalic, bounds: Rect.fromLTWH(310.0, catBoxY + 14.0, 10.0, 10.0));
    graphics.drawString(
      'BCA berhak setiap saat melakukan koreksi apabila ada kesalahan pada Laporan Mutasi Rekening.', 
      fontSmallItalic, 
      bounds: Rect.fromLTWH(317.0, catBoxY + 14.0, 240.0, 25.0), 
      format: justifyFormat
    );

    // ==========================================
    // 7. HEADER TABEL (Rounded Rectangle)
    // ==========================================
    double tableHeaderY = 215.0;
    double headerH = 16.0;

    // Menggambar tepi luar header sebagai kotak melengkung (rounded rect)
    _drawRoundedRect(graphics, linePen, Rect.fromLTWH(25.0, tableHeaderY, 545.0, headerH), borderRadius);

    // Garis Vertikal Pembatas Kolom (siku luar sudah di-cover rounded rect)
    graphics.drawLine(linePen, Offset(80.0, tableHeaderY), Offset(80.0, tableHeaderY + headerH)); // Pembatas Tanggal | Ket
    graphics.drawLine(linePen, Offset(280.0, tableHeaderY), Offset(280.0, tableHeaderY + headerH)); // Pembatas Ket | Cbg
    graphics.drawLine(linePen, Offset(315.0, tableHeaderY), Offset(315.0, tableHeaderY + headerH)); // Pembatas Cbg | Mutasi
    graphics.drawLine(linePen, Offset(460.0, tableHeaderY), Offset(460.0, tableHeaderY + headerH)); // Pembatas Mutasi | Saldo

    final PdfStringFormat centerFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center, 
      lineAlignment: PdfVerticalAlignment.middle
    );

    // Teks Header tepat berada di tengah masing-masing kotak
    graphics.drawString('TANGGAL', fontBold, bounds: Rect.fromLTWH(25.0, tableHeaderY, 55.0, headerH), format: centerFormat);
    graphics.drawString('KETERANGAN', fontBold, bounds: Rect.fromLTWH(80.0, tableHeaderY, 200.0, headerH), format: centerFormat);
    graphics.drawString('CBG', fontBold, bounds: Rect.fromLTWH(280.0, tableHeaderY, 35.0, headerH), format: centerFormat);
    graphics.drawString('MUTASI', fontBold, bounds: Rect.fromLTWH(315.0, tableHeaderY, 145.0, headerH), format: centerFormat);
    graphics.drawString('SALDO', fontBold, bounds: Rect.fromLTWH(460.0, tableHeaderY, 110.0, headerH), format: centerFormat);
  }

  Future<void> _exportPdf(String selectedPeriod) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.transactions;

    try {
      final PdfDocument document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins.all = 0; 

      final PdfFont fontRegular = PdfStandardFont(PdfFontFamily.helvetica, 7);

      PdfBitmap? logoBitmap;
      try {
        final ByteData imageBytes = await rootBundle.load('assets/images/Logo BCA_Biru.png');
        logoBitmap = PdfBitmap(imageBytes.buffer.asUint8List());
      } catch (e) {
        debugPrint('Logo BCA tidak ditemukan di path: $e');
      }

      double startingBalance = provider.startingBalance;
      double currentBalance = startingBalance;
      double mutasiCr = 0.0;
      double mutasiDb = 0.0;
      int countCr = 0;
      int countDb = 0;

      PdfPage currentPage = document.pages.add();
      double currentY = 240.0; 

      String saldoAwalDate = "01/10";
      if (transactions.isNotEmpty) {
        saldoAwalDate = _formatDateForPdf(transactions.first.dateOrStatus);
        if (saldoAwalDate.contains('/')) {
          saldoAwalDate = "01/${saldoAwalDate.split('/')[1]}";
        }
      }

      String formatCurrency(double val) => val.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

      currentPage.graphics.drawString(saldoAwalDate, fontRegular, bounds: Rect.fromLTWH(30.0, currentY, 45.0, 10.0));
      currentPage.graphics.drawString('SALDO AWAL', fontRegular, bounds: Rect.fromLTWH(88.0, currentY, 150.0, 10.0));
      currentPage.graphics.drawString(formatCurrency(startingBalance), fontRegular, bounds: Rect.fromLTWH(465.0, currentY, 100.0, 10.0), format: PdfStringFormat(alignment: PdfTextAlignment.right));
      
      currentY += 15.0;

      for (var t in transactions) {
        String rawAmount = t.amount.replaceAll('IDR', '').replaceAll(',', '').trim();
        double amount = double.tryParse(rawAmount) ?? 0.0;

        if (t.isDebit) {
          currentBalance -= amount;
          mutasiDb += amount;
          countDb++;
        } else {
          currentBalance += amount;
          mutasiCr += amount;
          countCr++;
        }

        List<String> titleLines = t.title.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
        double rowHeight = 10.0 * titleLines.length + 5.0;

        if (currentY + rowHeight > 780.0) {
          currentPage.graphics.drawString('Bersambung ke halaman berikut', fontRegular, bounds: const Rect.fromLTWH(30.0, 800.0, 200.0, 10.0));
          currentPage = document.pages.add();
          currentY = 240.0;
        }

        currentPage.graphics.drawString(_formatDateForPdf(t.dateOrStatus), fontRegular, bounds: Rect.fromLTWH(30.0, currentY, 45.0, 10.0));

        for (int i = 0; i < titleLines.length; i++) {
          currentPage.graphics.drawString(titleLines[i], fontRegular, bounds: Rect.fromLTWH(88.0, currentY + (i * 10.0), 190.0, 10.0));
        }

        currentPage.graphics.drawString(formatCurrency(amount), fontRegular, bounds: Rect.fromLTWH(320.0, currentY, 115.0, 10.0), format: PdfStringFormat(alignment: PdfTextAlignment.right));
        
        if (t.isDebit) {
          currentPage.graphics.drawString('DB', fontRegular, bounds: Rect.fromLTWH(440.0, currentY, 15.0, 10.0));
        }

        currentPage.graphics.drawString(formatCurrency(currentBalance), fontRegular, bounds: Rect.fromLTWH(465.0, currentY, 100.0, 10.0), format: PdfStringFormat(alignment: PdfTextAlignment.right));

        currentY += rowHeight + 8.0; 
      }

      double summaryHeight = 80.0;
      if (currentY + summaryHeight > 800.0) {
        currentPage.graphics.drawString('Bersambung ke halaman berikut', fontRegular, bounds: const Rect.fromLTWH(30.0, 800.0, 200.0, 10.0));
        currentPage = document.pages.add();
        currentY = 240.0;
      } else {
        currentY += 15.0; 
      }

      double sumLabelX = 30.0;
      double sumColonX = 100.0;
      double sumValX = 110.0;
      double sumCountX = 250.0;

      currentPage.graphics.drawString('SALDO AWAL', fontRegular, bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10));
      currentPage.graphics.drawString(':', fontRegular, bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10));
      currentPage.graphics.drawString(formatCurrency(startingBalance), fontRegular, bounds: Rect.fromLTWH(sumValX, currentY, 100, 10), format: PdfStringFormat(alignment: PdfTextAlignment.right));

      currentY += 12.0;
      currentPage.graphics.drawString('MUTASI CR', fontRegular, bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10));
      currentPage.graphics.drawString(':', fontRegular, bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10));
      currentPage.graphics.drawString(formatCurrency(mutasiCr), fontRegular, bounds: Rect.fromLTWH(sumValX, currentY, 100, 10), format: PdfStringFormat(alignment: PdfTextAlignment.right));
      currentPage.graphics.drawString(countCr.toString(), fontRegular, bounds: Rect.fromLTWH(sumCountX, currentY, 30, 10)); 

      currentY += 12.0;
      currentPage.graphics.drawString('MUTASI DB', fontRegular, bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10));
      currentPage.graphics.drawString(':', fontRegular, bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10));
      currentPage.graphics.drawString(formatCurrency(mutasiDb), fontRegular, bounds: Rect.fromLTWH(sumValX, currentY, 100, 10), format: PdfStringFormat(alignment: PdfTextAlignment.right));
      currentPage.graphics.drawString(countDb.toString(), fontRegular, bounds: Rect.fromLTWH(sumCountX, currentY, 30, 10)); 

      currentY += 12.0;
      currentPage.graphics.drawString('SALDO AKHIR', fontRegular, bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10));
      currentPage.graphics.drawString(':', fontRegular, bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10));
      currentPage.graphics.drawString(formatCurrency(currentBalance), fontRegular, bounds: Rect.fromLTWH(sumValX, currentY, 100, 10), format: PdfStringFormat(alignment: PdfTextAlignment.right));

      final int totalPages = document.pages.count;
      final String periodStr = selectedPeriod.toUpperCase();
      for (int i = 0; i < totalPages; i++) {
        _drawPageDecorations(document.pages[i], i + 1, totalPages, periodStr, logoBitmap);
      }

      final List<int> savedBytes = await document.save();
      document.dispose();

      final Directory dir = await getTemporaryDirectory();
      final String filePath = '${dir.path}/Mutasi_${widget.accountNumber}.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(savedBytes);

      if (!mounted) return;
      await Share.shareXFiles([XFile(filePath)], text: 'Laporan Mutasi Rekening ${widget.accountNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final months = provider.uploadedMonths;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D8E), 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'e-Statement',
          style: GoogleFonts.openSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Info',
              style: GoogleFonts.openSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: Text(
                'Pilih Bulan dan Tahun',
                style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF003366)),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              'Bulan yang diunduh',
              style: GoogleFonts.openSans(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Material(
            color: Colors.white,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: months.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1, thickness: 1, indent: 20, color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final monthStr = months[index];
                final displayMonth = _formatMonthDisplay(monthStr);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    displayMonth,
                    style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF003366)),
                  ),
                  trailing: const Icon(Icons.file_download, color: Colors.blue),
                  onTap: () {
                    _exportPdf(monthStr);
                  },
                );
              },
            ),
          ),
          Container(height: 1, color: const Color(0xFFEEEEEE)),
        ],
      ),
    );
  }
}