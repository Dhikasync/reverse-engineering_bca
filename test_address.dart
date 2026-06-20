import 'dart:io';

void main() {
  String text = '''
01/04/25      15:35:10

PT BCA Tbk
KCU GRESIK

JOHN DOE
JL. GRESIK NO. 1
GRESIK
INDONESIA

HALAMAN : 1 / 1
PERIODE : APRIL 2025
''';

  final linesForAddress = text.split('\n');
  bool passedBCA = false;
  bool foundBranch = false;
  bool foundName = false;
  List<String> tempAddress = [];
  String detectedBranch = 'KCP PERAK';

  for (int i = 0; i < 40 && i < linesForAddress.length; i++) {
    String line = linesForAddress[i].trim();
    if (line.isEmpty) continue;

    String leftPart = line.split(RegExp(r'\s{2,}'))[0].trim();
    String upperLeft = leftPart.toUpperCase();

    if (!passedBCA) {
      if (line.toUpperCase().contains('BANK CENTRAL ASIA')) {
        passedBCA = true;
      } else if (!foundBranch &&
          (upperLeft.startsWith('KCP ') ||
              upperLeft.startsWith('KCU ') ||
              upperLeft.startsWith('KPO ') ||
              upperLeft.startsWith('CABANG ') ||
              upperLeft.startsWith('KANTOR '))) {
        detectedBranch = upperLeft;
        foundBranch = true;
        passedBCA = true;
      }
      continue;
    }

    if (passedBCA && !foundBranch) {
      detectedBranch = upperLeft;
      foundBranch = true;
      continue;
    }

    if (foundBranch && !foundName) {
      foundName = true;
      continue;
    }

    if (foundName) {
      if (upperLeft.startsWith('NO. REKENING') ||
          upperLeft.startsWith('HALAMAN') ||
          upperLeft.startsWith('PERIODE') ||
          upperLeft.startsWith('MATA UANG') ||
          upperLeft.startsWith('CATATAN') ||
          upperLeft.startsWith('TANGGAL') ||
          upperLeft.startsWith('SALDO AWAL') ||
          upperLeft.contains('BANK CENTRAL ASIA')) {
        break;
      }

      if (leftPart.isNotEmpty &&
          !upperLeft.contains('HALAMAN') &&
          !upperLeft.contains('PERIODE')) {
        tempAddress.add(upperLeft);
      }

      if (upperLeft == 'INDONESIA') {
        break;
      }
    }
  }

  print('Branch: ' + detectedBranch);
  print('Address: ' + tempAddress.toString());
}
