import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'household_account.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type INTEGER NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            memo TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(model.Transaction t) async {
    final db = await database;
    return db.insert('transactions', t.toMap());
  }

  Future<List<model.Transaction>> getTransactions({DateTime? month}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (month != null) {
      final start = DateTime(month.year, month.month, 1).toIso8601String();
      final end = DateTime(month.year, month.month + 1, 1).toIso8601String();
      maps = await db.query(
        'transactions',
        where: 'date >= ? AND date < ?',
        whereArgs: [start, end],
        orderBy: 'date DESC',
      );
    } else {
      maps = await db.query('transactions', orderBy: 'date DESC');
    }
    return maps.map(model.Transaction.fromMap).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(model.Transaction t) async {
    final db = await database;
    return db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }
}
