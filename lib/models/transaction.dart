enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? memo;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.memo,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.index,
        'category': category,
        'date': date.toIso8601String(),
        'memo': memo,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as int?,
        title: map['title'] as String,
        amount: map['amount'] as double,
        type: TransactionType.values[map['type'] as int],
        category: map['category'] as String,
        date: DateTime.parse(map['date'] as String),
        memo: map['memo'] as String?,
      );
}
