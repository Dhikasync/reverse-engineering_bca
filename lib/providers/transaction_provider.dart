import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

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
    notifyListeners();
  }
}
