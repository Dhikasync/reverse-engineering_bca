import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class EStatementViewerPage extends StatefulWidget {
  final String pdfPath;
  final String accountNumber;
  final DateTime statementDate;

  const EStatementViewerPage({
    super.key,
    required this.pdfPath,
    required this.accountNumber,
    required this.statementDate,
  });

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

  /// Logika untuk membagikan file PDF
  Future<void> _sharePdf() async {
    try {
      final xFile = XFile(widget.pdfPath);
      await Share.shareXFiles([
        xFile,
      ], text: 'Laporan Mutasi Rekening - $_generatedFileName');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membagikan file: $e')));
      }
    }
  }

  /// Logika untuk mengunduh PDF secara paksa ke direktori perangkat
  Future<void> _downloadPdf() async {
    try {
      String targetPath = '';

      if (Platform.isAndroid) {
        // Bypass langsung ke root folder publik "Download" pada Android
        Directory dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = Directory('/storage/emulated/0/Downloads'); // Fallback path
        }

        targetPath = '${dir.path}/$_generatedFileName';

        // Jika file sudah ada, tambahkan penomoran otomatis agar tidak error
        int counter = 1;
        while (await File(targetPath).exists()) {
          String baseName = _generatedFileName.replaceAll('.pdf', '');
          targetPath = '${dir.path}/${baseName}_($counter).pdf';
          counter++;
        }
      } else if (Platform.isIOS) {
        // iOS mengunci ketat folder publik. Disimpan ke "Documents" agar bisa diakses dari app Files bawaan iPhone
        final Directory dir = await getApplicationDocumentsDirectory();
        targetPath = '${dir.path}/$_generatedFileName';
      }

      if (targetPath.isNotEmpty) {
        // Salin dari penyimpanan sementara (cache) ke folder publik yang dituju
        final File currentFile = File(widget.pdfPath);
        await currentFile.copy(targetPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil! File tersimpan di: $targetPath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengunduh: Pastikan memiliki izin penyimpanan.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _generatedFileName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _downloadPdf,
            tooltip: 'Unduh e-Statement',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _sharePdf,
            tooltip: 'Bagikan e-Statement',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    removeLeft: true,
                    removeRight: true,
                    child: Transform.scale(
                      scale: 1.03,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
