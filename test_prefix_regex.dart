void main() {
  final prefixRegex = RegExp(
    r'^(TRSF E-BANKING CR|TRSF E-BANKING DB|SETORAN VIA CDM \d{2}/\d{2}|TARIKAN ATM \d{2}/\d{2}|SWITCHING (?:DB|CR) TRANSFER[^\d/]*\d*|BIAYA ADM|PAJAK BUNGA|BUNGA|PEND KARTU|BIAYA KARTU|SALDO AWAL|KOR\.? (?:KREDIT|DEBET)|KOREKSI)',
    caseSensitive: false,
  );
  
  final lines = [
    "TRSF E-BANKING DB 0104/FTSCY/WS95031",
    "SETORAN VIA CDM 21/10 WSID:ZP8M1",
    "TARIKAN ATM 24/10",
    "SWITCHING DB TRANSFER KE 200 ROYAL EMRAN",
    "BIAYA ADM 1000",
    "UNKNOWN TX 1234",
  ];
  
  for (var line in lines) {
    final match = prefixRegex.firstMatch(line);
    if (match != null) {
      print('Matched: "${match.group(0)}" -> Remainder: "${line.substring(match.end).trim()}"');
    } else {
      print('No match for: "$line"');
    }
  }
}
