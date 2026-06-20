void main() {
  String fullText = "01/04 TRSF E-BANKING DB 0104/FTSCY/WS95031\n1005052.00\nWISNU BAGUS PRAYOG\n1,005,052.00DB563,565.65";
  final RegExp amountRegex = RegExp(r'(?<![\d.,])\d{1,3}(?:,\d{3})*\.\d{2}(?![\d.,])');
  final date = "01/04";
  
  final matches = amountRegex.allMatches(fullText);
  if (matches.isNotEmpty) {
    String mutasiAmount = matches.first.group(0)!;
    String? saldoAmount = matches.length > 1 ? matches.last.group(0) : null;
    
    String title = fullText;
    title = title.replaceFirst(date, '');
    title = title.replaceFirst(mutasiAmount, '');
    if (saldoAmount != null) {
      title = title.replaceFirst(saldoAmount, '');
    }
    
    bool isDebit = title.contains(RegExp(r'\bDB\b'));
    
    title = title.replaceAll(RegExp(r'\bDB\b'), '');
    title = title.replaceAll(RegExp(r'\bCR\b'), '');
    title = title.replaceAll(RegExp(r' {2,}'), ' ').trim();
    final titleLines = title.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    title = titleLines.join('\n');
    
    print("Mutasi: " + mutasiAmount);
    print("Saldo: " + (saldoAmount ?? ''));
    print("Is Debit: " + isDebit.toString());
    print("Title:\n" + title);
  }
}
