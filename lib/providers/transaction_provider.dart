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
  // PERBAIKAN: setTransactions sekarang otomatis menarik Bulan & Tahun dari Service
  // -------------------------------------------------------------------------------
  void setTransactions(List<TransactionModel> newTransactions) {
    _transactions = newTransactions;

    // Tarik data statis dari PdfParserService dan gabungkan.
    // Contoh output: "MEI 2023" yang nantinya akan dirapikan UI menjadi "Mei 2023"
    if (PdfParserService.detectedMonth.isNotEmpty) {
      _activeMonth = "${PdfParserService.detectedMonth}".trim();
    }

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

    // Bersihkan juga data statis di memori service agar benar-benar ter-reset
    PdfParserService.detectedMonth = "";
    PdfParserService.detectedYear = "";

    notifyListeners();
  }
}
