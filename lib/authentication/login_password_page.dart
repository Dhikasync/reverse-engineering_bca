import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan ini mengarah ke file halaman utama Anda:
import 'package:reverse_engineering_bca/dashboard/dashboard.dart';
import '../widgets/animated_bca_logo.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class LoginPasswordPage extends StatefulWidget {
  const LoginPasswordPage({Key? key}) : super(key: key);

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final Color bcaBlue = const Color(0xFF0066AE);
  final TextEditingController _passwordController = TextEditingController();

  // Ini password rahasianya
  final String correctPassword = "Surabaya123";

  bool _isObscure = true; // Untuk buka/tutup ikon mata (hide password)

  @override
  void initState() {
    super.initState();
    // Tidak lagi menggunakan setState di sini agar tidak me-rebuild seluruh layar
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isPasswordValid => _passwordController.text.isNotEmpty;

  void _validatePassword() async {
    // Tutup keyboard terlebih dahulu agar tidak nyangkut
    FocusManager.instance.primaryFocus?.unfocus();

    // 1. Munculkan dialog loading BCA
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan klik luar
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(child: AnimatedBCALogo()),
        );
      },
    );

    // 2. Simulasi proses loading (misal 1.5 detik)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 3. Pindah ke halaman utama dan hapus seluruh riwayat (termasuk dialog loading)

    // 4. Pindah ke halaman utama dengan animasi slide dari kanan
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MyBcaHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = (MediaQuery.of(context).size.width / 430.0).clamp(0.7, 1.0);
    final provider = context.watch<TransactionProvider>();
    final userName = provider.userName.toUpperCase();
    final bcaId = provider.bcaId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Biru Wavy
          RepaintBoundary(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar custom
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0 * scale,
                    vertical: 16.0 * scale,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20 * scale,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        'Masuk',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16 * scale),

                // White Container filling the rest of the screen
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24 * scale),
                        topRight: Radius.circular(24 * scale),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(24.0 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.openSans(
                                color: Colors.black54,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              bcaId,
                              style: GoogleFonts.openSans(
                                color: Colors.black45,
                                fontSize: 12 * scale,
                              ),
                            ),
                            SizedBox(height: 32 * scale),

                            // TextField Password
                            TextField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              style: GoogleFonts.openSans(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.openSans(
                                  color: const Color(0xFF005BAC),
                                  fontWeight: FontWeight.bold,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF005BAC),
                                    width: 2,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF005BAC),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16 * scale),

                            // Reset Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Reset Password',
                                style: GoogleFonts.openSans(
                                  color: const Color(0xFF1CB5E0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ),
                            SizedBox(height: 32 * scale),

                            // Bottom Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50 * scale,
                                    child:
                                        ValueListenableBuilder<
                                          TextEditingValue
                                        >(
                                          valueListenable: _passwordController,
                                          builder: (context, value, child) {
                                            bool isValid =
                                                value.text.isNotEmpty;
                                            return ElevatedButton(
                                              onPressed: isValid
                                                  ? _validatePassword
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF005BAC,
                                                ),
                                                disabledBackgroundColor:
                                                    Colors.grey.shade300,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        25 * scale,
                                                      ),
                                                ),
                                              ),
                                              child: Text(
                                                'Masuk',
                                                style: GoogleFonts.openSans(
                                                  color: Colors.white,
                                                  fontSize: 16 * scale,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ),
                                SizedBox(width: 16 * scale),
                                Container(
                                  width: 50 * scale,
                                  height: 50 * scale,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF005BAC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Image.asset(
                                      'assets/images/face-id.png',
                                      width: 28 * scale,
                                      height: 28 * scale,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
