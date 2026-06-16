class TransactionModel {
  final String dateOrStatus;
  final String title;
  final String subtitle;
  final String amount;
  final bool isDebit;

  TransactionModel({
    required this.dateOrStatus,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
  });

  // Tambahkan copyWith untuk mempermudah proses Edit (Update)
  TransactionModel copyWith({
    String? dateOrStatus,
    String? title,
    String? subtitle,
    String? amount,
    bool? isDebit,
  }) {
    return TransactionModel(
      dateOrStatus: dateOrStatus ?? this.dateOrStatus,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
    );
  }
}
