import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/pdf_parser_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  // Variabel untuk menyimpan bulan dan tahun yang sedang aktif
  String _activeMonth = "";
  String _activeYear = "";

  // Menyimpan daftar bulan dari PDF yang pernah di-upload
  final List<String> _uploadedMonths = [];
  double _startingBalance = 734147.95;

  List<TransactionModel> get transactions => _transactions;
  String get activeMonth => _activeMonth;
  String get activeYear => _activeYear;
  double get startingBalance => _startingBalance;

  // Getter untuk daftar bulan. Jika belum ada PDF yang di-upload,
  // kita tampilkan dummy 3 bulan sebagai default (pajangan).
  List<String> get uploadedMonths {
    if (_uploadedMonths.isEmpty) {
      return ["Agustus 2023", "Juli 2023", "Juni 2023"];
    }
    return _uploadedMonths;
  }

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
    _startingBalance = PdfParserService.detectedStartingBalance;

    // Tambahkan bulan ke daftar riwayat jika belum ada
    String formattedMonth = "$pdfMonth $pdfYear".trim();
    if (!_uploadedMonths.contains(formattedMonth)) {
      _uploadedMonths.insert(
        0,
        formattedMonth,
      ); // Insert di awal agar yang terbaru paling atas
    }

    notifyListeners();
  }

  void setTransactions(List<TransactionModel> newTransactions) {
    _transactions = newTransactions;
    _startingBalance = PdfParserService.detectedStartingBalance;
    if (PdfParserService.detectedMonth.isNotEmpty) {
      _activeMonth = PdfParserService.detectedMonth.trim();

      String formattedMonth = "$_activeMonth ${PdfParserService.detectedYear}"
          .trim();
      if (!_uploadedMonths.contains(formattedMonth)) {
        _uploadedMonths.insert(0, formattedMonth);
      }
    }
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
    notifyListeners();
  }
}
