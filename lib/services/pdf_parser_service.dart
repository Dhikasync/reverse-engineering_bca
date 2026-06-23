import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/transaction.dart';

class PdfParserService {
  static String detectedMonth = "";
  static String detectedYear = "";
  static double detectedStartingBalance = 734147.95;
  static Map<String, double> detectedMonthlyBalances = {};

  static String getIndonesianMonthStr(int month) {
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

  static String detectedBranch = '';
  static String detectedName = '';
  static String detectedAccountNumber = '';
  static String detectedAccountType =
      'REKENING TAHAPAN'; // e.g. REKENING TAHAPAN
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
    detectedMonthlyBalances.clear();
    double? tempStartingBalance;

    try {
      final bytes = await File(filePath).readAsBytes();
      final PdfDocument document = PdfDocument(
        inputBytes: bytes,
        password: password,
      );

      // Extract full text WITH layout for transaction parsing
      String text = PdfTextExtractor(document).extractText(layoutText: true);

      String currentYear = DateTime.now().year.toString();

      detectedBranch = '';
      detectedName = '';
      detectedAccountNumber = '';
      detectedAddress = [];

      // Save first 60 lines of HEADER text for debugging
      final linesForAddress = text.split('\n');
      lastRawTextPreview = linesForAddress.take(60).join('\n');

      // Extract account type from header lines
      detectedAccountType = 'REKENING TAHAPAN'; // Default
      for (int i = 0; i < 20 && i < linesForAddress.length; i++) {
        final trimmed = linesForAddress[i].trim().toUpperCase();
        if ((trimmed.contains('REKENING') && !trimmed.contains('NO.')) ||
            trimmed.contains('TAHAPAN') ||
            trimmed.contains('TAPRES') ||
            trimmed.contains('GIRO') ||
            trimmed.contains('XPRESI') ||
            trimmed.contains('BCA DOLLAR') ||
            trimmed.contains('BCA PRIORITAS')) {
          detectedAccountType = trimmed;
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

        if (upperLeft == detectedAccountType ||
            upperLine == detectedAccountType) {
          continue;
        }

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
              branch = branch
                  .substring(0, branch.toUpperCase().indexOf('PERIODE'))
                  .trim();
            }
            if (branch.toUpperCase().contains('HALAMAN')) {
              branch = branch
                  .substring(0, branch.toUpperCase().indexOf('HALAMAN'))
                  .trim();
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
            branch = branch
                .substring(0, branch.toUpperCase().indexOf('PERIODE'))
                .trim();
          }
          if (branch.toUpperCase().contains('HALAMAN')) {
            branch = branch
                .substring(0, branch.toUpperCase().indexOf('HALAMAN'))
                .trim();
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
      final periodMatch = periodRegex.firstMatch(text);
      if (periodMatch != null) {
        detectedMonth = periodMatch.group(1)!.toUpperCase();
        detectedYear = periodMatch.group(2)!;
        currentYear = detectedYear;
      }

      final accountRegex = RegExp(r'NO\.?\s*REKENING\s*:?\s*(\d+)');
      final accountMatch = accountRegex.firstMatch(text);
      if (accountMatch != null) {
        detectedAccountNumber = accountMatch.group(1)!;
      }

      // Fix OCR/Extraction issues where layoutText: true fails to add spaces between distant columns
      // 1. Missing space between two amounts: 4,500,000.0032,445,580.65 -> 4,500,000.00 32,445,580.65
      text = text.replaceAllMapped(
        RegExp(r'(\.\d{2})(\d)'),
        (m) => '${m.group(1)} ${m.group(2)}',
      );
      // 2. Missing space after date at start of line: 03/04TRSF -> 03/04 TRSF
      text = text.replaceAllMapped(
        RegExp(r'^(\d{2}/\d{2})([A-Z])', multiLine: true),
        (m) => '${m.group(1)} ${m.group(2)}',
      );

      final lines = text.split('\n');
      final RegExp dateRegex = RegExp(r'^(\d{2}/\d{2})');
      final RegExp amountRegex = RegExp(
        r'(?<![\d.,])\d{1,3}(?:,\d{3})*\.\d{2}(?![\d.,])',
      );

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
            tempStartingBalance = detectedStartingBalance;
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

        if (tempStartingBalance != null) {
          String monthYearKey =
              "${getIndonesianMonthStr(monthIndex)} $currentYear";
          if (!detectedMonthlyBalances.containsKey(monthYearKey)) {
            detectedMonthlyBalances[monthYearKey] = tempStartingBalance!;
          }
          tempStartingBalance = null;
        }

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

            RegExp mutasiDbRegex = RegExp(
              RegExp.escape(mutasiAmount) + r'\s*DB\b',
            );
            bool isDebit = mutasiDbRegex.hasMatch(title);

            if (isDebit) {
              title = title.replaceFirst(mutasiDbRegex, '');
            } else {
              title = title.replaceFirst(mutasiAmount, '');
            }

            if (saldoAmount != null) {
              title = title.replaceFirst(saldoAmount, '');
            }

            if (!isDebit) {
              String upperTitle = title.toUpperCase();

              // PRIORITAS PALING TINGGI: label transaksi itu sendiri sudah menyatakan jenisnya
              if (upperTitle.contains('TRANSAKSI DEBIT')) {
                isDebit = true;
              } else if (upperTitle.contains('TRANSAKSI KREDIT')) {
                isDebit = false;
              }
              // Cek DB/CR di akhir baris (spasi atau newline sebelum DB)
              else if (RegExp(r'(?:\n|\s{2,})DB\b\s*$').hasMatch(upperTitle)) {
                isDebit = true;
              } else if (RegExp(
                    r'(?:\n|\s{2,})CR\b\s*$',
                  ).hasMatch(upperTitle) ||
                  upperTitle.contains('TRSF E-BANKING CR') ||
                  upperTitle.contains('BI-FAST CR') ||
                  upperTitle.contains('SETORAN VIA CDM') ||
                  upperTitle.contains('SETORAN TUNAI') ||
                  upperTitle.contains('KR OTOMATIS') ||
                  upperTitle.contains('SWITCHING CR')) {
                isDebit = false;
              } else if (upperTitle.contains('TARIKAN ATM') ||
                  upperTitle.contains('BIAYA ADM') ||
                  upperTitle.contains('PAJAK BUNGA') ||
                  upperTitle.contains('BIAYA KARTU') ||
                  upperTitle.contains('PEND KARTU') ||
                  upperTitle.contains('TRSF E-BANKING DB') ||
                  upperTitle.contains('BI-FAST DB') ||
                  upperTitle.contains('SWITCHING DB') ||
                  upperTitle.contains('KOR. DEBET') ||
                  upperTitle.contains('KOREKSI DEBET')) {
                isDebit = true;
              }
            }

            // Hapus standalone DB/CR di akhir blok (sisa dari kolom Mutasi)
            title = title.replaceFirst(
              RegExp(r'(?:\n|\s{2,})(?:DB|CR)\b\s*$', caseSensitive: false),
              '',
            );

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
                r'^(?:'
                r'TRSF E-BANKING\s+(?:CR|DB)|'
                r'BI-FAST\s+(?:CR|DB)|'
                r'SETORAN\s+VIA\s+CDM|'
                r'SETORAN\s+TUNAI|'
                r'TARIKAN\s+ATM|'
                r'TARIKAN\s+TUNAI|'
                r'SWITCHING\s+(?:DB|CR)\s+TRANSFER[^\d/]*\d*|'
                r'SWITCHING|'
                r'BIAYA\s+ADM|'
                r'PAJAK\s+BUNGA|'
                r'BUNGA|'
                r'PEND\s+KARTU|'
                r'BIAYA\s+KARTU|'
                r'SALDO\s+AWAL|'
                r'KOR\.?\s+(?:KREDIT|DEBET)|'
                r'KOREKSI|'
                r'KR\s+OTOMATIS'
                r')',
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
                RegExp tglRegex = RegExp(
                  r'\bTGL\s*:\s*\d{2}/\d{2}\b',
                  caseSensitive: false,
                );
                final tglMatch = tglRegex.firstMatch(firstLine);
                if (tglMatch != null && tglMatch.start > 0) {
                  keteranganKiri = firstLine
                      .substring(0, tglMatch.start)
                      .trim();
                  String tglText = tglMatch.group(0)!;
                  String rest = firstLine.substring(tglMatch.end).trim();
                  keteranganKanan = tglText;
                  if (rest.isNotEmpty) keteranganKanan += ' ' + rest;
                  keteranganKanan += '\n';
                } else {
                  keteranganKiri = firstLine;
                }
              }
              for (int i = 1; i < titleLines.length; i++) {
                String line = titleLines[i];
                if (line.toUpperCase().startsWith('TANGGAL :') ||
                    line.toUpperCase().startsWith('TANGGAL:')) {
                  keteranganKiri += '\n' + line;
                } else {
                  keteranganKanan += line + '\n';
                }
              }
              keteranganKiri = keteranganKiri.trim();
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

      bool isParsingHeader = false;

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        String upperLine = line.toUpperCase();

        // Handle page breaks to skip repetitive headers
        if (upperLine.contains('BERSAMBUNG')) {
          isParsingHeader = true;
          continue;
        }

        if (isParsingHeader) {
          if (upperLine.startsWith('TANGGAL') &&
              upperLine.contains('KETERANGAN')) {
            isParsingHeader = false;
          }
          continue; // Skip all lines inside the page header
        }

        if (dateRegex.hasMatch(line)) {
          bool hasAmount = currentBlock.any((l) => amountRegex.hasMatch(l));

          bool isKnownPrefix = RegExp(
            r'^(\d{2}/\d{2})\s+('
            r'TRSF E-BANKING|BI-FAST|SETORAN|TARIKAN|SWITCHING|BIAYA|PAJAK|BUNGA|PEND KARTU|SALDO|KOR\.|KOREKSI|KR OTOMATIS|PEMBELIAN|PEMBAYARAN|TRANSAKSI'
            r')',
            caseSensitive: false,
          ).hasMatch(line);

          bool isExactlyDate = RegExp(r'^\d{2}/\d{2}$').hasMatch(line.trim());

          if (currentBlock.isEmpty ||
              hasAmount ||
              isKnownPrefix ||
              isExactlyDate) {
            if (currentBlock.isNotEmpty) {
              processBlock();
            }
            currentBlock = [line];
          } else {
            currentBlock.add(line);
          }
        } else if (currentBlock.isNotEmpty) {
          if (upperLine.startsWith('MUTASI CR') ||
              upperLine.startsWith('MUTASI DB') ||
              upperLine.startsWith('SALDO AKHIR')) {
            processBlock();
            currentBlock = [];
          } else if (upperLine.startsWith('SALDO AWAL')) {
            processBlock();
            currentBlock = [line];
          } else {
            // Fallback safety checks for standard BCA footers or unskipped headers
            if (!upperLine.contains('REKENING TAHAPAN') &&
                !upperLine.contains('TAPRES') &&
                !upperLine.contains('REKENING GIRO') &&
                !upperLine.startsWith('NO. REKENING') &&
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
