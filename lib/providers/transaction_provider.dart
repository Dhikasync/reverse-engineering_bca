import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/pdf_parser_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  String _activeMonth = "";
  String _activeYear = "";

  double _startingBalance = 734147.95;

  String _branch = "KCP PERAK";
  List<String> _address = [
    "TANDES",
    "RT005 RW006 JAWA TIMUR",
    "GADEL TENGAH II NO 05",
    "SURABAYA 60186",
    "INDONESIA",
  ];

  // Always returns transactions sorted newest-first, regardless of internal order
  List<TransactionModel> get transactions {
    final sorted = List<TransactionModel>.from(_transactions);
    sorted.sort((a, b) {
      return _parseTransactionDate(b).compareTo(_parseTransactionDate(a));
    });
    return sorted;
  }
  String get activeMonth => _activeMonth;
  String get activeYear => _activeYear;
  double get startingBalance => _startingBalance;
  String get branch => _branch;
  List<String> get address => _address;

  // Helper: Indonesian month name to number (for sorting)
  static const Map<String, int> _monthOrder = {
    'Januari': 1,
    'Februari': 2,
    'Maret': 3,
    'April': 4,
    'Mei': 5,
    'Juni': 6,
    'Juli': 7,
    'Agustus': 8,
    'September': 9,
    'Oktober': 10,
    'November': 11,
    'Desember': 12,
  };

  // Helper: English month abbreviation to number (for sorting transactions)
  static const Map<String, int> _engMonthOrder = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'mei': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'agu': 8,
    'sep': 9,
    'oct': 10,
    'okt': 10,
    'nov': 11,
    'dec': 12,
    'des': 12,
  };

  /// Parse transaction date into a comparable DateTime.
  /// Format: "15\nAUG\n2023"
  DateTime _parseTransactionDate(TransactionModel tx) {
    final parts = tx.dateOrStatus.split('\n');
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final month = _engMonthOrder[parts[1].toLowerCase()] ?? 1;
      final year = int.tryParse(parts[2]) ?? 2000;
      return DateTime(year, month, day);
    }
    return DateTime(2000);
  }

  /// Sort transactions newest first (descending by date).
  void _sortTransactions() {
    _transactions.sort((a, b) {
      return _parseTransactionDate(b).compareTo(_parseTransactionDate(a));
    });
  }

  // Computed getter: always derived from actual transactions, deduplicated & sorted newest first
  List<String> get uploadedMonths {
    if (_transactions.isEmpty) {
      return ["Agustus 2023", "Juli 2023", "Juni 2023"];
    }

    // Collect unique periods directly from current transactions
    final Set<String> periodsSet = {};
    for (var tx in _transactions) {
      final parts = tx.dateOrStatus.split('\n');
      if (parts.length >= 3) {
        String monthShort = parts[1];
        String year = parts[2];
        String indoMonth = _mapMonthToIndonesian(monthShort);
        periodsSet.add("$indoMonth $year");
      }
    }

    // Sort by year desc, then month desc (newest first)
    final List<String> periods = periodsSet.toList();
    periods.sort((a, b) {
      final partsA = a.split(' ');
      final partsB = b.split(' ');
      if (partsA.length < 2 || partsB.length < 2) return 0;

      final yearA = int.tryParse(partsA.last) ?? 0;
      final yearB = int.tryParse(partsB.last) ?? 0;
      if (yearA != yearB) return yearB.compareTo(yearA);

      final monthA = _monthOrder[partsA.first] ?? 0;
      final monthB = _monthOrder[partsB.first] ?? 0;
      return monthB.compareTo(monthA);
    });

    return periods;
  }

  // Fungsi Helper menerjemahkan bulan ke Bahasa Indonesia
  String _mapMonthToIndonesian(String monthShort) {
    switch (monthShort.toLowerCase()) {
      case 'jan':
        return 'Januari';
      case 'feb':
        return 'Februari';
      case 'mar':
        return 'Maret';
      case 'apr':
        return 'April';
      case 'may':
        return 'Mei';
      case 'jun':
        return 'Juni';
      case 'jul':
        return 'Juli';
      case 'aug':
        return 'Agustus';
      case 'sep':
        return 'September';
      case 'oct':
        return 'Oktober';
      case 'nov':
        return 'November';
      case 'dec':
        return 'Desember';
      default:
        return monthShort;
    }
  }

  void processNewPdfTransactions(
    List<TransactionModel> newTransactions,
    String pdfMonth,
    String pdfYear,
  ) {
    _activeMonth = pdfMonth;
    _activeYear = pdfYear;
    _transactions.addAll(newTransactions);

    // Jangan overwrite starting balance jika menggabungkan data,
    // kecuali ini upload pertama kali
    if (_transactions.length == newTransactions.length) {
      _startingBalance = PdfParserService.detectedStartingBalance;
    }

    if (PdfParserService.detectedBranch.isNotEmpty) {
      _branch = PdfParserService.detectedBranch;
    }
    if (PdfParserService.detectedAddress.isNotEmpty) {
      _address = List.from(PdfParserService.detectedAddress);
    }

    _sortTransactions(); // Urutkan setelah setiap upload
    notifyListeners();
  }

  void setTransactions(List<TransactionModel> newTransactions) {
    _transactions = newTransactions;
    _startingBalance = PdfParserService.detectedStartingBalance;

    if (PdfParserService.detectedBranch.isNotEmpty) {
      _branch = PdfParserService.detectedBranch;
    }
    if (PdfParserService.detectedAddress.isNotEmpty) {
      _address = List.from(PdfParserService.detectedAddress);
    }

    _sortTransactions(); // Urutkan setelah set
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    _sortTransactions(); // Urutkan setelah tambah
    notifyListeners();
  }

  void updateTransaction(int index, TransactionModel updatedTransaction) {
    if (index >= 0 && index < _transactions.length) {
      _transactions[index] = updatedTransaction;
      _sortTransactions(); // Urutkan ulang setelah edit (mencegah duplikat header & urutan salah)
      notifyListeners();
    }
  }

  void deleteTransaction(int index) {
    if (index >= 0 && index < _transactions.length) {
      _transactions.removeAt(index);
      notifyListeners();
    }
  }

  void clearTransactions() {
    _transactions.clear();
    _activeMonth = "";
    _activeYear = "";
    PdfParserService.detectedMonth = "";
    PdfParserService.detectedYear = "";

    _branch = "KCP PERAK";
    _address = [
      "ASEMROWO",
      "RT005 RW006 JAWA TIMUR",
      "MANGGA 2",
      "SURABAYA 60187",
      "INDONESIA",
    ];
    notifyListeners();
  }
}
