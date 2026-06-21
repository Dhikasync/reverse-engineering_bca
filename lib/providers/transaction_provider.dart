import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../services/pdf_parser_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  String _activeMonth = "";
  String _activeYear = "";

  double _startingBalance = 734147.95;

  String _branch = '';
  String _accountType = 'REKENING TAHAPAN';
  List<String> _address = [];

  String _userName = 'Default';
  String _accountNumber = '0240219280';
  String _balance = '154830048';

  Map<String, double> _monthlyStartingBalances = {};

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
  String get accountType => _accountType;
  List<String> get address => _address;

  String get userName => _userName;
  String get accountNumber => _accountNumber;
  String get balance => _balance;

  void setUserProfile(String name, String accountNum, String bal) {
    _userName = name;
    _accountNumber = accountNum;
    _balance = bal;
    notifyListeners();
    saveData();
  }
  
  double getStartingBalanceForMonth(String month, String year) {
    String indoMonth = _mapMonthToIndonesian(month);
    return _monthlyStartingBalances["$indoMonth $year"] ?? _startingBalance;
  }

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
      return [];
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
    [Map<String, double>? newMonthlyBalances]
  ) {
    _activeMonth = pdfMonth;
    _activeYear = pdfYear;
    _transactions.addAll(newTransactions);

    // Jangan overwrite starting balance utama jika menggabungkan data
    if (_transactions.length == newTransactions.length) {
      if (newMonthlyBalances != null && newMonthlyBalances.isNotEmpty) {
        _startingBalance = newMonthlyBalances.values.first;
      } else {
        _startingBalance = PdfParserService.detectedStartingBalance;
      }
    }
    
    if (newMonthlyBalances != null) {
      _monthlyStartingBalances.addAll(newMonthlyBalances);
    }

    if (PdfParserService.detectedBranch.isNotEmpty) {
      _branch = PdfParserService.detectedBranch;
    }
    if (PdfParserService.detectedAddress.isNotEmpty) {
      _address = List.from(PdfParserService.detectedAddress);
    }
    if (PdfParserService.detectedAccountType.isNotEmpty) {
      _accountType = PdfParserService.detectedAccountType;
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
    if (PdfParserService.detectedAccountType.isNotEmpty) {
      _accountType = PdfParserService.detectedAccountType;
    }

    _sortTransactions(); // Urutkan setelah set
    notifyListeners();
    saveData();
  }

  void setBranchAndAddress(String branch, List<String> address) {
    _branch = branch.toUpperCase();
    _address = address.map((l) => l.toUpperCase()).toList();
    notifyListeners();
    saveData();
  }

  void setAccountType(String accountType) {
    _accountType = accountType.toUpperCase();
    notifyListeners();
    saveData();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    _sortTransactions(); // Urutkan setelah tambah
    notifyListeners();
    saveData();
  }

  void updateTransaction(int index, TransactionModel updatedTransaction) {
    if (index >= 0 && index < _transactions.length) {
      _transactions[index] = updatedTransaction;
      _sortTransactions(); // Urutkan ulang setelah edit (mencegah duplikat header & urutan salah)
      notifyListeners();
      saveData();
    }
  }

  void deleteTransaction(int index) {
    if (index >= 0 && index < _transactions.length) {
      _transactions.removeAt(index);
      notifyListeners();
      saveData();
    }
  }

  void clearTransactions() {
    _transactions.clear();
    _activeMonth = '';
    _activeYear = '';
    PdfParserService.detectedMonth = '';
    PdfParserService.detectedYear = '';
    _monthlyStartingBalances.clear();
    // Do NOT reset branch/address — user set those manually
    notifyListeners();
    saveData();
  }

  // --- PERSISTENCE LOGIC (shared_preferences) ---
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save settings
    prefs.setString('branch', _branch);
    prefs.setStringList('address', _address);
    prefs.setString('accountType', _accountType);
    prefs.setDouble('startingBalance', _startingBalance);
    prefs.setString('userName', _userName);
    prefs.setString('accountNumber', _accountNumber);
    prefs.setString('balance', _balance);
    
    // Save monthly starting balances map (serialize as JSON)
    prefs.setString('monthlyStartingBalances', jsonEncode(_monthlyStartingBalances));

    // Save transactions (serialize list to JSON string)
    final String transactionsJson = jsonEncode(_transactions.map((tx) => tx.toJson()).toList());
    prefs.setString('transactions', transactionsJson);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load settings
    _branch = prefs.getString('branch') ?? '';
    _address = prefs.getStringList('address') ?? [];
    _accountType = prefs.getString('accountType') ?? 'REKENING TAHAPAN';
    _startingBalance = prefs.getDouble('startingBalance') ?? 734147.95;
    _userName = prefs.getString('userName') ?? 'Default';
    _accountNumber = prefs.getString('accountNumber') ?? '0240219280';
    _balance = prefs.getString('balance') ?? '154830048';
    
    // Load monthly starting balances map
    final String? monthlyBalancesJson = prefs.getString('monthlyStartingBalances');
    if (monthlyBalancesJson != null) {
      try {
        final decoded = jsonDecode(monthlyBalancesJson) as Map<String, dynamic>;
        _monthlyStartingBalances = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } catch (e) {
        debugPrint("Error parsing monthly balances: $e");
      }
    }

    // Load transactions
    final String? transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        _transactions = decoded.map((item) => TransactionModel.fromJson(item)).toList();
        _sortTransactions();
      } catch (e) {
        debugPrint("Error parsing transactions: $e");
      }
    }
    
    notifyListeners();
  }
}
