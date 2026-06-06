import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<Transaction> _transactions = [];
  DateTime _selectedMonth = DateTime.now();

  List<Transaction> get transactions => _transactions;
  DateTime get selectedMonth => _selectedMonth;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Future<void> loadTransactions() async {
    _transactions = await _db.getTransactions(month: _selectedMonth);
    notifyListeners();
  }

  Future<void> addTransaction(Transaction t) async {
    await _db.insertTransaction(t);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction t) async {
    await _db.updateTransaction(t);
    await loadTransactions();
  }

  void changeMonth(int delta) {
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + delta,
    );
    loadTransactions();
  }
}
