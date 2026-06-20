import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/transaction.dart';

class PdfParserService {
  static String detectedMonth = "";
  static String detectedYear = "";
  static double detectedStartingBalance = 734147.95;

  static String detectedBranch = '';
  static String detectedName = '';
  static String detectedAccountNumber = '';
  static String detectedAccountType = 'REKENING TAHAPAN'; // e.g. REKENING TAHAPAN
  static List<String> detectedAddress = [];
  static String lastRawTextPreview = ''; // for debug

  static Future<bool> isPasswordRequired(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      document.dispose();
      return false;
    } catch (e) {
      return true;
    }
  }

  static Future<List<TransactionModel>> parseBcaStatement(
    String filePath, {
    String? password,
  }) async {
    final List<TransactionModel> transactions = [];

    try {
      final bytes = await File(filePath).readAsBytes();
      final PdfDocument document = PdfDocument(
        inputBytes: bytes,
        password: password,
      );

      // Extract full text WITH layout for transaction parsing
      final String text = PdfTextExtractor(
        document,
      ).extractText(layoutText: true);

      // Extract page 1 WITHOUT layout to get header info (branch, address, name)
      // layoutText:false gives plain text without positional spaces
      final String headerText = PdfTextExtractor(
        document,
      ).extractText(startPageIndex: 0, endPageIndex: 0, layoutText: false);

      String currentYear = DateTime.now().year.toString();

      detectedBranch = '';
      detectedName = '';
      detectedAccountNumber = '';
      detectedAddress = [];

      // Save first 60 lines of HEADER text for debugging
      final linesForAddress = headerText.split('\n');
      lastRawTextPreview = linesForAddress.take(60).join('\n');

      // Extract account type from the first non-empty line (e.g. "REKENING TAHAPAN")
      for (final headerLine in linesForAddress) {
        final trimmed = headerLine.trim();
        if (trimmed.isNotEmpty) {
          detectedAccountType = trimmed.toUpperCase();
          break;
        }
      }

      bool passedBCA = false;
      bool foundBranch = false;
      bool foundName = false;
      List<String> tempAddress = [];

      for (int i = 0; i < 40 && i < linesForAddress.length; i++) {
        String line = linesForAddress[i].trim();
        if (line.isEmpty) continue;

        String upperLine = line.toUpperCase();
        String leftPart = line.split(RegExp(r'\s{3,}'))[0].trim();
        String upperLeft = leftPart.toUpperCase();

        if (!passedBCA) {
          if (upperLine.contains('BANK CENTRAL ASIA')) {
            passedBCA = true;
          }
          // Fallback if BANK CENTRAL ASIA was somehow missed
          else if (!foundBranch &&
              (upperLine.startsWith('KCP') || 
               upperLine.startsWith('KCU') ||
               upperLine.startsWith('KPO') ||
               upperLine.startsWith('CABANG') ||
               upperLine.startsWith('KANTOR'))) {
            
            String branch = line;
            if (branch.toUpperCase().contains('PERIODE')) {
              branch = branch.substring(0, branch.toUpperCase().indexOf('PERIODE')).trim();
            }
            if (branch.toUpperCase().contains('HALAMAN')) {
              branch = branch.substring(0, branch.toUpperCase().indexOf('HALAMAN')).trim();
            }
            detectedBranch = branch.toUpperCase();
            foundBranch = true;
            passedBCA = true;
          }
          continue;
        }

        if (passedBCA && !foundBranch) {
          String branch = line;
          if (branch.toUpperCase().contains('PERIODE')) {
            branch = branch.substring(0, branch.toUpperCase().indexOf('PERIODE')).trim();
          }
          if (branch.toUpperCase().contains('HALAMAN')) {
            branch = branch.substring(0, branch.toUpperCase().indexOf('HALAMAN')).trim();
          }
          detectedBranch = branch.toUpperCase();
          foundBranch = true;
          continue;
        }

        if (foundBranch && !foundName) {
          detectedName = upperLeft;
          foundName = true;
          continue;
        }

        if (foundName) {
          if (upperLeft.startsWith('NO. REKENING') ||
              upperLeft.startsWith('HALAMAN') ||
              upperLeft.startsWith('PERIODE') ||
              upperLeft.startsWith('MATA UANG') ||
              upperLeft.startsWith('CATATAN') ||
              upperLeft.startsWith('TANGGAL') ||
              upperLeft.startsWith('SALDO AWAL') ||
              upperLeft.contains('BANK CENTRAL ASIA')) {
            break;
          }

          if (leftPart.isNotEmpty &&
              !upperLeft.contains('HALAMAN') &&
              !upperLeft.contains('PERIODE')) {
            tempAddress.add(upperLeft);
          }

          if (upperLeft == 'INDONESIA') {
            break;
          }
        }
      }

      if (tempAddress.isNotEmpty) {
        detectedAddress = tempAddress;
      }

      final periodRegex = RegExp(
        r'PERIODE\s*:.*?([A-Za-z]+)\s*(\d{4})',
        caseSensitive: false,
      );
      // Try headerText first, fallback to full text
      final periodMatch = periodRegex.firstMatch(headerText) ?? periodRegex.firstMatch(text);
      if (periodMatch != null) {
        detectedMonth = periodMatch.group(1)!.toUpperCase();
        detectedYear = periodMatch.group(2)!;
        currentYear = detectedYear;
      }

      final accountRegex = RegExp(r'NO\.?\s*REKENING\s*:?\s*(\d+)');
      final accountMatch = accountRegex.firstMatch(headerText) ?? accountRegex.firstMatch(text);
      if (accountMatch != null) {
        detectedAccountNumber = accountMatch.group(1)!;
      }

      final lines = text.split('\n');
      final RegExp dateRegex = RegExp(r'^(\d{2}/\d{2})');
      final RegExp amountRegex = RegExp(r'(?<![\d.,])\d{1,3}(?:,\d{3})*\.\d{2}(?![\d.,])');

      List<String> currentBlock = [];
      int lastMonthProcessed =
          -1; // Deteksi pergantian bulan (untuk tahun baru)

      void processBlock() {
        if (currentBlock.isEmpty) return;

        String fullText = currentBlock.join('\n');

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
        List<String> monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        int monthIndex = int.tryParse(monthNum) ?? 1;

        // Jika transaksi sebelumnya Desember (12) dan sekarang Januari (1), naikkan Tahun
        if (lastMonthProcessed == 12 && monthIndex == 1) {
          int y = int.tryParse(currentYear) ?? DateTime.now().year;
          currentYear = (y + 1).toString();
        }
        lastMonthProcessed = monthIndex;

        String monthStr = monthNames[(monthIndex - 1).clamp(0, 11)];
        String formattedDate = '$day\n$monthStr\n$currentYear';

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
            String? saldoAmount = matches.length > 1
                ? matches.last.group(0)
                : null;

            String title = fullText;
            title = title.replaceFirst(date, '');
            title = title.replaceFirst(mutasiAmount, '');
            if (saldoAmount != null) {
              title = title.replaceFirst(saldoAmount, '');
            }

            bool isDebit = title.contains(RegExp(r'\bDB\b'));
            title = title.replaceAll(RegExp(r'\bDB\b'), '');
            title = title.replaceAll(RegExp(r'\bCR\b'), '');

            title = title.replaceAll(RegExp(r' {2,}'), ' ').trim();
            final titleLines = title
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            String keteranganKiri = '';
            String keteranganKanan = '';

            if (titleLines.isNotEmpty) {
              String firstLine = titleLines.first;
              final prefixRegex = RegExp(
                r'^(TRSF E-BANKING CR|TRSF E-BANKING DB|SETORAN VIA CDM \d{2}/\d{2}|TARIKAN ATM \d{2}/\d{2}|SWITCHING (?:DB|CR) TRANSFER[^\d/]*\d*|BIAYA ADM|PAJAK BUNGA|BUNGA|PEND KARTU|BIAYA KARTU|SALDO AWAL|KOR\.? (?:KREDIT|DEBET)|KOREKSI)',
                caseSensitive: false,
              );
              final match = prefixRegex.firstMatch(firstLine);
              if (match != null) {
                keteranganKiri = match.group(0)!.trim();
                String remainder = firstLine.substring(match.end).trim();
                if (remainder.isNotEmpty) {
                  keteranganKanan = remainder + '\n';
                }
              } else {
                keteranganKiri = firstLine;
              }

              for (int i = 1; i < titleLines.length; i++) {
                keteranganKanan += titleLines[i] + '\n';
              }
              keteranganKanan = keteranganKanan.trim();
            }

            transactions.add(
              TransactionModel(
                dateOrStatus: formattedDate,
                keteranganKiri: keteranganKiri,
                keteranganKanan: keteranganKanan,
                subtitle: isDebit ? 'TRANSAKSI DEBIT' : 'TRANSAKSI KREDIT',
                amount: 'IDR $mutasiAmount',
                isDebit: isDebit,
              ),
            );
          }
        }
      }

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        if (dateRegex.hasMatch(line)) {
          processBlock();
          currentBlock = [line];
        } else if (currentBlock.isNotEmpty) {
          String upperLine = line.toUpperCase();

          if (upperLine.startsWith('MUTASI CR') ||
              upperLine.startsWith('SALDO AKHIR')) {
            processBlock();
            currentBlock = [];
          } else if (upperLine.startsWith('SALDO AWAL')) {
            processBlock();
            currentBlock = [line];
          } else {
            if (!upperLine.contains('BERSAMBUNG KE HALAMAN BERIKUT') &&
                !upperLine.contains('REKENING TAHAPAN') &&
                !upperLine.contains('TAPRES') &&
                !upperLine.contains('REKENING GIRO') &&
                !upperLine.startsWith('KCP ') &&
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
              currentBlock.add(line);
            }
          }
        }
      }
      processBlock();

      document.dispose();
    } catch (e) {
      debugPrint('Error parsing PDF: $e');
      throw Exception(
        'Gagal membaca PDF. Pastikan file valid atau password benar.',
      );
    }

    return transactions;
  }
}
