import 'package:flutter/material.dart';
import 'dart:async';
import '../authentication/login_page.dart';
import '../dashboard/dashboard.dart';

class MainStartScreen extends StatefulWidget {
  final bool isActivated;

  const MainStartScreen({super.key, required this.isActivated});

  @override
  State<MainStartScreen> createState() => _MainStartScreenState();
}

class _MainStartScreenState extends State<MainStartScreen> {
  @override
  void initState() {
    super.initState();

    // Langsung tunggu 1.5 detik (bagian 2), lalu pindah halaman
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.isActivated
                ? const MyBcaHomeScreen()
                : const LoginPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.fastOutSlowIn;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_putih_vertical.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/mybca-logo-remove.png',
                width: 180, // Ukuran bisa disesuaikan
                fit: BoxFit.contain,
              ),
            ),
            const Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    'BCA berizin dan diawasi oleh Otoritas Jasa Keuangan & Bank Indonesia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'BCA merupakan peserta penjaminan LPS.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
