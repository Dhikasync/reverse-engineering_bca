import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/pdf_parser_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  String _activeMonth = "";
  String _activeYear = "";

  final List<String> _uploadedMonths = [];
  double _startingBalance = 734147.95;

  String _branch = "KCP PERAK";
  List<String> _address = [
    "TANDES",
    "RT005 RW006 JAWA TIMUR",
    "GADEL TENGAH II NO 05",
    "SURABAYA 60186",
    "INDONESIA",
  ];

  List<TransactionModel> get transactions => _transactions;
  String get activeMonth => _activeMonth;
  String get activeYear => _activeYear;
  double get startingBalance => _startingBalance;
  String get branch => _branch;
  List<String> get address => _address;

  List<String> get uploadedMonths {
    if (_uploadedMonths.isEmpty) {
      return ["Agustus 2023", "Juli 2023", "Juni 2023"];
    }
    return _uploadedMonths;
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

  // Mengekstrak bulan-bulan unik dari List transaksi
  void _updateUploadedMonthsFromTransactions() {
    Set<String> detectedPeriods = {};
    for (var tx in _transactions) {
      final parts = tx.dateOrStatus.split('\n');
      if (parts.length >= 3) {
        String monthShort = parts[1];
        String year = parts[2];
        String indoMonth = _mapMonthToIndonesian(monthShort);
        detectedPeriods.add("$indoMonth $year");
      }
    }

    // Menambahkannya ke daftar periode bulan
    for (var period in detectedPeriods) {
      if (!_uploadedMonths.contains(period)) {
        _uploadedMonths.insert(0, period);
      }
    }
  }

  void processNewPdfTransactions(
    List<TransactionModel> newTransactions,
    String pdfMonth,
    String pdfYear,
  ) {
    // Digabung jika upload PDF ke-2, agar tidak mereset data.
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

    _updateUploadedMonthsFromTransactions();
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

    _updateUploadedMonthsFromTransactions();
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(int index, TransactionModel updatedTransaction) {
    if (index >= 0 && index < _transactions.length) {
      _transactions[index] = updatedTransaction;
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

    //bila tidak upload pdf ini secara default
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
