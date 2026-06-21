// ignore_for_file: avoid_print
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  final bytes = File('assets/pdf/1870587259Oct2025 (1).pdf').readAsBytesSync();
  final document = PdfDocument(inputBytes: bytes);
  final PdfTextExtractor extractor = PdfTextExtractor(document);

  for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
    print('--- PAGE ${pageIndex + 1} ---');
    final List<TextLine> lines = extractor.extractTextLines(startPageIndex: pageIndex, endPageIndex: pageIndex);
    for (var i = 0; i < lines.length; i++) {
      print('${lines[i].text} -> ${lines[i].bounds}');
    }
  }
}
