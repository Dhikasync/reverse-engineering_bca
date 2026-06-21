import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  final doc = PdfDocument();
  final page = doc.pages.add();
  page.graphics.drawString(
    'Test Bold',
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    pen: PdfPen(PdfColor(0, 0, 0), width: 0.3),
    brush: PdfSolidBrush(PdfColor(0, 0, 0)),
  );
  print('Success');
}
