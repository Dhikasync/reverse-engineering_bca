import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../start/main_start.dart';

class SecretCodePage extends StatefulWidget {
  final bool isActivated;

  const SecretCodePage({super.key, required this.isActivated});

  @override
  State<SecretCodePage> createState() => _SecretCodePageState();
}

class _SecretCodePageState extends State<SecretCodePage> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  // Kode rahasia yang hanya diketahui oleh developer dan client
  final String _secretCode = 'Surabaya123';

  void _verifyCode() async {
    if (_codeController.text == _secretCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLicensed', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainStartScreen(isActivated: widget.isActivated),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Kode Akses Tidak Valid';
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scale = (MediaQuery.of(context).size.width / 430.0).clamp(0.7, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(32.0 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64 * scale,
                    color: const Color(0xFF005BAC),
                  ),
                  SizedBox(height: 24 * scale),
                  Text(
                    'Akses Terbatas',
                    style: GoogleFonts.openSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF003D79),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Silakan masukkan kode akses (License Key) untuk menggunakan aplikasi ini.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 14 * scale,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 32 * scale),
                  TextField(
                    controller: _codeController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan Kode',
                      hintStyle: GoogleFonts.openSans(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide: const BorderSide(
                          color: Color(0xFF005BAC),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    SizedBox(height: 12 * scale),
                    Text(
                      _errorMessage,
                      style: GoogleFonts.openSans(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  SizedBox(height: 32 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 50 * scale,
                    child: ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005BAC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                      child: Text(
                        'Buka Aplikasi',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
