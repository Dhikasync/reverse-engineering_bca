void main() {
  final RegExp amountRegex = RegExp(r'\d{1,3}(?:,\d{3})*\.\d{2}');
  final text = '1,005,052.00DB563,565.65';
  final matches = amountRegex.allMatches(text);
  for (var m in matches) {
    print(m.group(0));
  }
}
