void main() {
  print(RegExp(r'\bDB\b').hasMatch("1,005,052.00DB563,565.65"));
  print(RegExp(r'\bDB\b').hasMatch("1,005,052.00DB"));
  print(RegExp(r'\bDB\b').hasMatch("DB563,565.65"));
  print(RegExp(r'\bDB\b').hasMatch(" DB "));
}
