// ignore_for_file: avoid_print
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  try {
    final filePath = r'C:\Users\amiru\Downloads\1870587259Oct2025 (1).pdf';
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    File('pdf_text_output.txt').writeAsStringSync(text);
    print('Extracted successfully. Text length: ${text.length}');
  } catch (e) {
    print('Error: $e');
  }
}
