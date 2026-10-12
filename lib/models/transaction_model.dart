class TransactionModel {
  final int? id;
  final int goalId;
  final double amount;
  final String transactionDate;
  final String? note;
  final String createdAt;
  final String updatedAt;

  TransactionModel({
    this.id,
    required this.goalId,
    required this.amount,
    required this.transactionDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'transaction_date': transactionDate,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      goalId: map['goal_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      transactionDate: map['transaction_date'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
