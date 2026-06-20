// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  test('Extract PDF text', () async {
    final filePath = r'C:\Users\amiru\Downloads\1870587259Oct2025 (1).pdf';
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText(layoutText: true);
    File('pdf_text_layout.txt').writeAsStringSync(text);
    print('Extracted successfully with layoutText: true. Text length: ${text.length}');
  });
}
