import 'package:flutter/material.dart';
import '../models/transaction.dart';
// --- TAMBAHAN BARU: Import file service agar bisa mengambil variabel statisnya ---
import '../services/pdf_parser_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  // Variabel untuk menyimpan bulan dan tahun yang sedang aktif
  String _activeMonth = "";
  String _activeYear = "";

  List<TransactionModel> get transactions => _transactions;
  String get activeMonth => _activeMonth;
  String get activeYear => _activeYear;

  // Fungsi pintar untuk mencegah data bertumpuk beda bulan
  void processNewPdfTransactions(
    List<TransactionModel> newTransactions,
    String pdfMonth,
    String pdfYear,
  ) {
    if (_activeMonth.isNotEmpty &&
        (_activeMonth != pdfMonth || _activeYear != pdfYear)) {
      _transactions.clear();
    }
    _activeMonth = pdfMonth;
    _activeYear = pdfYear;
    _transactions.addAll(newTransactions);
    notifyListeners();
  }

  void setTransactions(List<TransactionModel> newTransactions) {
    _transactions = newTransactions;
    if (PdfParserService.detectedMonth.isNotEmpty) {
      _activeMonth = "${PdfParserService.detectedMonth}".trim();
    }
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  // --- FITUR BARU UNTUK EDIT / UPDATE TRANSAKSI ---
  void updateTransaction(int index, TransactionModel updatedTransaction) {
    if (index >= 0 && index < _transactions.length) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  // --- FITUR BARU UNTUK HAPUS TRANSAKSI ---
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
    notifyListeners();
  }
}
