class TransactionModel {
  final int? id;
  final String title;
  final int amount;
  final String type;
  final int timestamp;
  final int categoryId;
  final DateTime date;
  final String monthYear;
  final int userId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.categoryId,
    required this.date,
    required this.monthYear,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'timestamp': timestamp,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'monthYear': monthYear,
      'userId': userId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int,
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      timestamp: map['timestamp'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      monthYear: map['monthYear'],
      userId: map['userId'],
    );
  }
}
