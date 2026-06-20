class TransactionModel {
  final String dateOrStatus;
  final String keteranganKiri;
  final String keteranganKanan;
  final String subtitle;
  final String amount;
  final bool isDebit;

  TransactionModel({
    required this.dateOrStatus,
    required this.keteranganKiri,
    required this.keteranganKanan,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
  });

  // Tambahkan copyWith untuk mempermudah proses Edit (Update)
  TransactionModel copyWith({
    String? dateOrStatus,
    String? keteranganKiri,
    String? keteranganKanan,
    String? subtitle,
    String? amount,
    bool? isDebit,
  }) {
    return TransactionModel(
      dateOrStatus: dateOrStatus ?? this.dateOrStatus,
      keteranganKiri: keteranganKiri ?? this.keteranganKiri,
      keteranganKanan: keteranganKanan ?? this.keteranganKanan,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
    );
  }
}
