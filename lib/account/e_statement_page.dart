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
import '../models/transaction.dart';

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

  String _formatDateForPdf(String dateOrStatus) {
    final List<String> parts = dateOrStatus.split('\n');
    if (parts.length >= 2) {
      final String day = parts[0].padLeft(2, '0');
      final String monthStr = parts[1].toLowerCase();

      final Map<String, String> monthsMap = {
        'jan': '01',
        'feb': '02',
        'mar': '03',
        'apr': '04',
        'may': '05',
        'mei': '05',
        'jun': '06',
        'jul': '07',
        'aug': '08',
        'agu': '08',
        'sep': '09',
        'oct': '10',
        'okt': '10',
        'nov': '11',
        'dec': '12',
        'des': '12',
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

  void _drawRoundedRect(
    PdfGraphics graphics,
    PdfPen pen,
    Rect bounds,
    double radius,
  ) {
    final PdfPath path = PdfPath();
    double d = radius * 2;

    path.addArc(Rect.fromLTWH(bounds.left, bounds.top, d, d), 180, 90);
    path.addLine(
      Offset(bounds.left + radius, bounds.top),
      Offset(bounds.right - radius, bounds.top),
    );
    path.addArc(Rect.fromLTWH(bounds.right - d, bounds.top, d, d), 270, 90);
    path.addLine(
      Offset(bounds.right, bounds.top + radius),
      Offset(bounds.right, bounds.bottom - radius),
    );
    path.addArc(
      Rect.fromLTWH(bounds.right - d, bounds.bottom - d, d, d),
      0,
      90,
    );
    path.addLine(
      Offset(bounds.right - radius, bounds.bottom),
      Offset(bounds.left + radius, bounds.bottom),
    );
    path.addArc(Rect.fromLTWH(bounds.left, bounds.bottom - d, d, d), 90, 90);
    path.addLine(
      Offset(bounds.left, bounds.bottom - radius),
      Offset(bounds.left, bounds.top + radius),
    );

    graphics.drawPath(path, pen: pen);
  }

  void _drawPageDecorations(
    PdfPage page,
    int pageNum,
    int totalPages,
    String periodStr,
    PdfBitmap? logo,
    TransactionProvider provider,
  ) {
    final PdfGraphics graphics = page.graphics;

    final PdfFont fontTitle = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    );
    final PdfFont fontRegular = PdfStandardFont(PdfFontFamily.helvetica, 7);
    final PdfFont fontBold = PdfStandardFont(
      PdfFontFamily.helvetica,
      7,
      style: PdfFontStyle.bold,
    );

    final PdfFont fontCatatanTitle = PdfStandardFont(
      PdfFontFamily.helvetica,
      7,
      style: PdfFontStyle.bold,
    );
    final PdfFont fontSmallItalic = PdfStandardFont(
      PdfFontFamily.helvetica,
      7,
      style: PdfFontStyle.italic,
    );

    final PdfPen linePen = PdfPen(PdfColor(0, 0, 0), width: 0.5);

    if (logo != null) {
      graphics.drawImage(logo, const Rect.fromLTWH(25.0, 20.0, 75.0, 25.0));
    } else {
      final PdfFont fontBCA = PdfStandardFont(
        PdfFontFamily.helvetica,
        16,
        multiStyle: [PdfFontStyle.bold, PdfFontStyle.italic],
      );
      graphics.drawString(
        'BCA',
        fontBCA,
        bounds: const Rect.fromLTWH(25.0, 25.0, 100.0, 20.0),
      );
    }

    graphics.drawString(
      widget.accountTypeDetail.toUpperCase(),
      fontTitle,
      bounds: const Rect.fromLTWH(0.0, 25.0, 595.0, 20.0),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    graphics.drawString(
      provider.branch,
      fontBold,
      bounds: const Rect.fromLTWH(35.0, 55.0, 200.0, 10.0),
    );

    double boxY = 72.0;
    double boxWidth = 260.0;
    double boxHeight = 94.0;
    double borderRadius = 5.0;

    _drawRoundedRect(
      graphics,
      linePen,
      Rect.fromLTWH(25.0, boxY, boxWidth, boxHeight),
      borderRadius,
    );

    double textLeftX = 35.0;
    double textLeftY = boxY + 10.0;

    graphics.drawString(
      widget.userName.toUpperCase(),
      fontBold,
      bounds: Rect.fromLTWH(textLeftX, textLeftY, 240.0, 10.0),
    );

    for (int i = 0; i < provider.address.length; i++) {
      textLeftY += 14.0;
      graphics.drawString(
        provider.address[i],
        fontBold,
        bounds: Rect.fromLTWH(textLeftX, textLeftY, 240.0, 10.0),
      );
    }

    double rightBoxX = 310.0;

    _drawRoundedRect(
      graphics,
      linePen,
      Rect.fromLTWH(rightBoxX, boxY, boxWidth, boxHeight),
      borderRadius,
    );

    double textRightX = rightBoxX + 15.0;
    double textRightY = boxY + 15.0;
    double colonX = rightBoxX + 85.0;
    double valueX = rightBoxX + 95.0;

    graphics.drawString(
      'NO. REKENING',
      fontBold,
      bounds: Rect.fromLTWH(textRightX, textRightY, 80.0, 10.0),
    );
    graphics.drawString(
      ':',
      fontBold,
      bounds: Rect.fromLTWH(colonX, textRightY, 10.0, 10.0),
    );
    graphics.drawString(
      widget.accountNumber,
      fontBold,
      bounds: Rect.fromLTWH(valueX, textRightY, 120.0, 10.0),
    );

    graphics.drawString(
      'HALAMAN',
      fontBold,
      bounds: Rect.fromLTWH(textRightX, textRightY + 16.0, 80.0, 10.0),
    );
    graphics.drawString(
      ':',
      fontBold,
      bounds: Rect.fromLTWH(colonX, textRightY + 16.0, 10.0, 10.0),
    );
    graphics.drawString(
      '$pageNum / $totalPages',
      fontBold,
      bounds: Rect.fromLTWH(valueX, textRightY + 16.0, 120.0, 10.0),
    );

    graphics.drawString(
      'PERIODE',
      fontBold,
      bounds: Rect.fromLTWH(textRightX, textRightY + 32.0, 80.0, 10.0),
    );
    graphics.drawString(
      ':',
      fontBold,
      bounds: Rect.fromLTWH(colonX, textRightY + 32.0, 10.0, 10.0),
    );
    graphics.drawString(
      periodStr,
      fontBold,
      bounds: Rect.fromLTWH(valueX, textRightY + 32.0, 120.0, 10.0),
    );

    graphics.drawString(
      'MATA UANG',
      fontBold,
      bounds: Rect.fromLTWH(textRightX, textRightY + 48.0, 80.0, 10.0),
    );
    graphics.drawString(
      ':',
      fontBold,
      bounds: Rect.fromLTWH(colonX, textRightY + 48.0, 10.0, 10.0),
    );
    graphics.drawString(
      'IDR',
      fontBold,
      bounds: Rect.fromLTWH(valueX, textRightY + 48.0, 120.0, 10.0),
    );

    double catBoxY = 176.0;
    double catBoxHeight = 65.0;

    _drawRoundedRect(
      graphics,
      linePen,
      Rect.fromLTWH(25.0, catBoxY, 545.0, catBoxHeight),
      borderRadius,
    );

    graphics.drawString(
      'CATATAN:',
      fontCatatanTitle,
      bounds: Rect.fromLTWH(32.0, catBoxY + 5.0, 100.0, 10.0),
    );

    final PdfStringFormat justifyFormat = PdfStringFormat(
      alignment: PdfTextAlignment.justify,
      lineSpacing: 5.0,
    );

    graphics.drawString(
      '•',
      fontSmallItalic,
      bounds: Rect.fromLTWH(32.0, catBoxY + 18.0, 10.0, 10.0),
    );
    graphics.drawString(
      'Apabila nasabah tidak melakukan sanggahan atas Laporan Mutasi Rekening ini sampai dengan akhir bulan berikutnya, nasabah dianggap telah menyetujui segala data yang tercantum pada Laporan Mutasi Rekening ini.',
      fontSmallItalic,
      bounds: Rect.fromLTWH(40.0, catBoxY + 18.0, 240.0, 45.0),
      format: justifyFormat,
    );

    graphics.drawString(
      '•',
      fontSmallItalic,
      bounds: Rect.fromLTWH(310.0, catBoxY + 18.0, 10.0, 10.0),
    );
    graphics.drawString(
      'BCA berhak setiap saat melakukan koreksi apabila ada kesalahan pada Laporan Mutasi Rekening.',
      fontSmallItalic,
      bounds: Rect.fromLTWH(318.0, catBoxY + 18.0, 240.0, 45.0),
      format: justifyFormat,
    );

    double tableHeaderY = 252.0;
    double headerH = 20.0;

    _drawRoundedRect(
      graphics,
      linePen,
      Rect.fromLTWH(25.0, tableHeaderY, 545.0, headerH),
      borderRadius,
    );

    graphics.drawLine(
      linePen,
      Offset(80.0, tableHeaderY),
      Offset(80.0, tableHeaderY + headerH),
    );
    graphics.drawLine(
      linePen,
      Offset(280.0, tableHeaderY),
      Offset(280.0, tableHeaderY + headerH),
    );
    graphics.drawLine(
      linePen,
      Offset(315.0, tableHeaderY),
      Offset(315.0, tableHeaderY + headerH),
    );
    graphics.drawLine(
      linePen,
      Offset(460.0, tableHeaderY),
      Offset(460.0, tableHeaderY + headerH),
    );

    final PdfStringFormat centerFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    graphics.drawString(
      'TANGGAL',
      fontBold,
      bounds: Rect.fromLTWH(25.0, tableHeaderY, 55.0, headerH),
      format: centerFormat,
    );
    graphics.drawString(
      'KETERANGAN',
      fontBold,
      bounds: Rect.fromLTWH(80.0, tableHeaderY, 200.0, headerH),
      format: centerFormat,
    );
    graphics.drawString(
      'CBG',
      fontBold,
      bounds: Rect.fromLTWH(280.0, tableHeaderY, 35.0, headerH),
      format: centerFormat,
    );
    graphics.drawString(
      'MUTASI',
      fontBold,
      bounds: Rect.fromLTWH(315.0, tableHeaderY, 145.0, headerH),
      format: centerFormat,
    );
    graphics.drawString(
      'SALDO',
      fontBold,
      bounds: Rect.fromLTWH(460.0, tableHeaderY, 110.0, headerH),
      format: centerFormat,
    );
  }

  Future<void> _exportPdf(String selectedPeriod) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final allTransactions = provider.transactions;

    String getShortMonth(String indonesianMonth) {
      final m = indonesianMonth.toLowerCase();
      if (m.contains('jan')) return 'Jan';
      if (m.contains('feb')) return 'Feb';
      if (m.contains('mar')) return 'Mar';
      if (m.contains('apr')) return 'Apr';
      if (m.contains('mei')) return 'May';
      if (m.contains('jun')) return 'Jun';
      if (m.contains('jul')) return 'Jul';
      if (m.contains('agu')) return 'Aug';
      if (m.contains('sep')) return 'Sep';
      if (m.contains('okt')) return 'Oct';
      if (m.contains('nov')) return 'Nov';
      if (m.contains('des')) return 'Dec';
      return '';
    }

    final periodParts = selectedPeriod.split(' ');
    String targetMonthIndo = periodParts.isNotEmpty ? periodParts[0] : '';
    String targetYear = periodParts.length > 1 ? periodParts[1] : '';
    String targetShortMonth = getShortMonth(targetMonthIndo);

    double runningBalance = provider.startingBalance;
    List<TransactionModel> targetTransactions = [];
    double startingBalanceForMonth = runningBalance;
    bool foundTargetMonth = false;

    for (var tx in allTransactions) {
      final parts = tx.dateOrStatus.split('\n');
      if (parts.length >= 3) {
        String txMonth = parts[1];
        String txYear = parts[2];

        bool isTargetMonth =
            txMonth.toLowerCase() == targetShortMonth.toLowerCase() &&
            txYear == targetYear;

        if (isTargetMonth && !foundTargetMonth) {
          foundTargetMonth = true;
          startingBalanceForMonth = runningBalance;
        }

        if (isTargetMonth) {
          targetTransactions.add(tx);
        }
      }

      String rawAmount = tx.amount
          .replaceAll('IDR', '')
          .replaceAll(',', '')
          .trim();
      double amount = double.tryParse(rawAmount) ?? 0.0;
      if (tx.isDebit) {
        runningBalance -= amount;
      } else {
        runningBalance += amount;
      }
    }

    try {
      final PdfDocument document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins.all = 0;

      final PdfFont fontRegular = PdfStandardFont(PdfFontFamily.helvetica, 7);

      PdfBitmap? logoBitmap;
      try {
        final ByteData imageBytes = await rootBundle.load(
          'assets/images/Logo BCA_Biru.png',
        );
        logoBitmap = PdfBitmap(imageBytes.buffer.asUint8List());
      } catch (e) {
        debugPrint('Logo BCA tidak ditemukan di path: $e');
      }

      double currentBalance = startingBalanceForMonth;
      double mutasiCr = 0.0;
      double mutasiDb = 0.0;
      int countCr = 0;
      int countDb = 0;

      PdfPage currentPage = document.pages.add();
      double currentY = 282.0;

      String getMonthNumberFromPeriod(String p) {
        final m = p.toLowerCase();
        if (m.contains('jan')) return '01';
        if (m.contains('feb')) return '02';
        if (m.contains('mar')) return '03';
        if (m.contains('apr')) return '04';
        if (m.contains('may') || m.contains('mei')) return '05';
        if (m.contains('jun')) return '06';
        if (m.contains('jul')) return '07';
        if (m.contains('aug') || m.contains('agu')) return '08';
        if (m.contains('sep')) return '09';
        if (m.contains('oct') || m.contains('okt')) return '10';
        if (m.contains('nov')) return '11';
        if (m.contains('dec') || m.contains('des')) return '12';
        return '01';
      }

      String saldoAwalDate = "01/${getMonthNumberFromPeriod(selectedPeriod)}";
      if (targetTransactions.isNotEmpty) {
        String firstTxDate = _formatDateForPdf(
          targetTransactions.first.dateOrStatus,
        );
        if (firstTxDate.contains('/')) {
          saldoAwalDate = "01/${firstTxDate.split('/')[1]}";
        }
      }

      String formatCurrency(double val) => val
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );

      currentPage.graphics.drawString(
        saldoAwalDate,
        fontRegular,
        bounds: Rect.fromLTWH(30.0, currentY, 45.0, 10.0),
      );
      currentPage.graphics.drawString(
        'SALDO AWAL',
        fontRegular,
        bounds: Rect.fromLTWH(88.0, currentY, 150.0, 10.0),
      );
      currentPage.graphics.drawString(
        formatCurrency(startingBalanceForMonth),
        fontRegular,
        bounds: Rect.fromLTWH(465.0, currentY, 100.0, 10.0),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );

      currentY += 16.0;

      for (var t in targetTransactions) {
        String rawAmount = t.amount
            .replaceAll('IDR', '')
            .replaceAll(',', '')
            .trim();
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

        List<String> titleLines = t.title
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        double rowHeight = 12.0 * titleLines.length + 5.0;

        if (currentY + rowHeight > 760.0) {
          currentPage.graphics.drawString(
            'Bersambung ke halaman berikut',
            fontRegular,
            bounds: const Rect.fromLTWH(25.0, 780.0, 545.0, 10.0),
            format: PdfStringFormat(alignment: PdfTextAlignment.right),
          );
          currentPage = document.pages.add();
          currentY = 285.0;
        }

        currentPage.graphics.drawString(
          _formatDateForPdf(t.dateOrStatus),
          fontRegular,
          bounds: Rect.fromLTWH(30.0, currentY, 45.0, 10.0),
        );

        for (int i = 0; i < titleLines.length; i++) {
          currentPage.graphics.drawString(
            titleLines[i],
            fontRegular,
            bounds: Rect.fromLTWH(88.0, currentY + (i * 12.0), 190.0, 10.0),
          );
        }

        currentPage.graphics.drawString(
          formatCurrency(amount),
          fontRegular,
          bounds: Rect.fromLTWH(320.0, currentY, 115.0, 10.0),
          format: PdfStringFormat(alignment: PdfTextAlignment.right),
        );

        if (t.isDebit) {
          currentPage.graphics.drawString(
            'DB',
            fontRegular,
            bounds: Rect.fromLTWH(440.0, currentY, 15.0, 10.0),
          );
        }

        currentPage.graphics.drawString(
          formatCurrency(currentBalance),
          fontRegular,
          bounds: Rect.fromLTWH(465.0, currentY, 100.0, 10.0),
          format: PdfStringFormat(alignment: PdfTextAlignment.right),
        );

        currentY += rowHeight + 12.0;
      }

      double summaryHeight = 80.0;
      if (currentY + summaryHeight > 760.0) {
        currentPage.graphics.drawString(
          'Bersambung ke halaman berikut',
          fontRegular,
          bounds: const Rect.fromLTWH(30.0, 780.0, 200.0, 10.0),
        );
        currentPage = document.pages.add();
        currentY = 282.0;
      } else {
        currentY += 20.0;
      }

      double sumLabelX = 30.0;
      double sumColonX = 100.0;
      double sumValX = 110.0;
      double sumCountX = 250.0;

      currentPage.graphics.drawString(
        'SALDO AWAL',
        fontRegular,
        bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10),
      );
      currentPage.graphics.drawString(
        ':',
        fontRegular,
        bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10),
      );
      currentPage.graphics.drawString(
        formatCurrency(startingBalanceForMonth),
        fontRegular,
        bounds: Rect.fromLTWH(sumValX, currentY, 100, 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );

      currentY += 16.0;
      currentPage.graphics.drawString(
        'MUTASI CR',
        fontRegular,
        bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10),
      );
      currentPage.graphics.drawString(
        ':',
        fontRegular,
        bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10),
      );
      currentPage.graphics.drawString(
        formatCurrency(mutasiCr),
        fontRegular,
        bounds: Rect.fromLTWH(sumValX, currentY, 100, 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      currentPage.graphics.drawString(
        countCr.toString(),
        fontRegular,
        bounds: Rect.fromLTWH(sumCountX, currentY, 30, 10),
      );

      currentY += 16.0;
      currentPage.graphics.drawString(
        'MUTASI DB',
        fontRegular,
        bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10),
      );
      currentPage.graphics.drawString(
        ':',
        fontRegular,
        bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10),
      );
      currentPage.graphics.drawString(
        formatCurrency(mutasiDb),
        fontRegular,
        bounds: Rect.fromLTWH(sumValX, currentY, 100, 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      currentPage.graphics.drawString(
        countDb.toString(),
        fontRegular,
        bounds: Rect.fromLTWH(sumCountX, currentY, 30, 10),
      );

      currentY += 16.0;
      currentPage.graphics.drawString(
        'SALDO AKHIR',
        fontRegular,
        bounds: Rect.fromLTWH(sumLabelX, currentY, 70, 10),
      );
      currentPage.graphics.drawString(
        ':',
        fontRegular,
        bounds: Rect.fromLTWH(sumColonX, currentY, 10, 10),
      );
      currentPage.graphics.drawString(
        formatCurrency(currentBalance),
        fontRegular,
        bounds: Rect.fromLTWH(sumValX, currentY, 100, 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );

      final int totalPages = document.pages.count;
      final String periodStr = selectedPeriod.toUpperCase();
      for (int i = 0; i < totalPages; i++) {
        _drawPageDecorations(
          document.pages[i],
          i + 1,
          totalPages,
          periodStr,
          logoBitmap,
          provider,
        );
      }

      final List<int> savedBytes = await document.save();
      document.dispose();

      final Directory dir = await getTemporaryDirectory();
      final String filePath = '${dir.path}/Mutasi_${widget.accountNumber}.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(savedBytes);

      if (!mounted) return;
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Laporan Mutasi Rekening ${widget.accountNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengekspor PDF: $e')));
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
          'Savings & Current Accounts',
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
                          'Account No.',
                          style: GoogleFonts.openSans(
                            color: const Color(0xFF003366),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            1.0,
                          ), // Border dibuat sangat tipis (sebelumnya 1.5)
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
                              vertical: 14, // Padding diratakan
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize
                                  .min, // Kunci utama agar fit konten
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
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                      0xFF003366,
                                    ).withOpacity(0.4),
                                  ),
                                ),
                                // Text widget.accountTypeDetail dihapus karena posisinya
                                // sudah direpresentasikan oleh TAHAPAN - IDR secara visual
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Select Period',
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
                          itemCount: months.length + 1,
                          itemBuilder: (context, index) {
                            if (index < months.length) {
                              final monthStr = months[index];
                              final displayMonth = _formatMonthDisplay(
                                monthStr,
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                ),
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
                                    'SHOW',
                                    style: GoogleFonts.openSans(
                                      color: const Color(0xFF003366),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () => _exportPdf(monthStr),
                                ),
                              );
                            } else {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  leading: _buildPeriodIcon(isSpecial: true),
                                  title: Text(
                                    'Select Another Period',
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
                                  onTap: () {
                                    // Aksi tambahan untuk ambil file lain
                                  },
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
