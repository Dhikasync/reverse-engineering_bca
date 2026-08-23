import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan ini mengarah ke file halaman utama Anda:
import 'package:reverse_engineering_bca/dashboard/dashboard.dart';

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

  void _validatePassword() async {
    if (_passwordController.text == correctPassword) {
      // 1. Simpan "ingatan" ke HP kalau aktivasi sukses
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isActivated', true);

      if (!mounted) return; // Mencegah error widget tree

      // 2. Pindah ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyBcaHomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktivasi Berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Password Salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password Salah! Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Agar tidak error overflow saat keyboard muncul
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // 👇 BAGIAN LOGO YANG DIPERBARUI 👇
                Center(
                  child: Image.asset(
                    'assets/images/mybca-logo.png',
                    height: 120,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),

                // 👆 👆 👆
                const SizedBox(height: 60),
                Text(
                  'Aktivasi Aplikasi',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan password operasional untuk melanjutkan.',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                // Form Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: bcaBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: bcaBlue, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bcaBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _validatePassword,
                    child: Text(
                      'Lanjutkan',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
