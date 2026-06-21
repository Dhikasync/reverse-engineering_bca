void main() {
  final RegExp r = RegExp(r'(?<![\d.])(\d{1,3}(?:,\d{3})*\.\d{2})(?![\d.])');
  final matches = r.allMatches('1,005,052.00DB563,565.65');
  for (var m in matches) {
    print(m.group(0));
  }
}
