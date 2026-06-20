import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EStatementViewerPage extends StatefulWidget {
  final String pdfPath;
  final String accountNumber;
  final DateTime statementDate;

  const EStatementViewerPage({
    Key? key,
    required this.pdfPath,
    required this.accountNumber,
    required this.statementDate,
  }) : super(key: key);

  @override
  State<EStatementViewerPage> createState() => _EStatementViewerPageState();
}

class _EStatementViewerPageState extends State<EStatementViewerPage> {
  late String _generatedFileName;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _generatedFileName = _generateFileName(
      widget.accountNumber,
      widget.statementDate,
    );
  }

  String _generateFileName(String accNumber, DateTime date) {
    String monthName = DateFormat('MMMM', 'id_ID').format(date);
    return '${accNumber}_${monthName}_${date.year}.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .black, // Menggunakan warna gelap untuk membuktikan ini bukan trik background
      appBar: AppBar(
        title: Text(
          _generatedFileName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Logic share file PDF
            },
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              // TODO: Logic navigasi ke halaman Login
            },
          ),
        ],
        elevation: 0,
        titleSpacing: 0,
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: SizedBox.expand(
          // SOLUSI: Menggunakan Transform.scale untuk mendorong margin
          // bawaan PDF Viewer keluar dari layar.
          child: Transform.scale(
            scale:
                1.03, // Naikkan skala 3% agar menabrak bezel layar (sesuaikan jika perlu, misal 1.04 atau 1.05)
            child: SfPdfViewer.file(
              File(widget.pdfPath),
              controller: _pdfViewerController,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              pageSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
