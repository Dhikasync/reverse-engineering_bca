import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  // --- TAMBAHAN BARU: Variabel untuk menyimpan bulan dan tahun yang sedang aktif ---
  String _activeMonth = "";
  String _activeYear = "";

  List<TransactionModel> get transactions => _transactions;
  String get activeMonth => _activeMonth;
  String get activeYear => _activeYear;

  // --- TAMBAHAN BARU: Fungsi pintar untuk mencegah data bertumpuk beda bulan ---
  void processNewPdfTransactions(
    List<TransactionModel> newTransactions,
    String pdfMonth,
    String pdfYear,
  ) {
    // Jika provider sudah punya data sebelumnya, tapi bulan/tahun PDF yang baru berbeda...
    if (_activeMonth.isNotEmpty &&
        (_activeMonth != pdfMonth || _activeYear != pdfYear)) {
      // ...maka bersihkan semua transaksi lama!
      _transactions.clear();
    }

    // Set bulan dan tahun aktif dengan data PDF yang baru saja masuk
    _activeMonth = pdfMonth;
    _activeYear = pdfYear;

    // Tambahkan semua transaksi dari PDF ke dalam provider
    _transactions.addAll(newTransactions);

    // Beritahu UI (seperti accountinformation.dart) untuk merender ulang
    notifyListeners();
  }
  // -------------------------------------------------------------------------------

  // -------------------------------------------------------------------------------
  // Fungsi bawaan lamamu tetap dibiarkan agar tidak merusak struktur kode yang sudah ada
  // -------------------------------------------------------------------------------
  void setTransactions(List<TransactionModel> newTransactions) {
    _transactions = newTransactions;
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void clearTransactions() {
    _transactions.clear();
    _activeMonth =
        ""; // Pastikan saat clear manual, state bulan & tahun juga keriset
    _activeYear = "";
    notifyListeners();
  }
}
