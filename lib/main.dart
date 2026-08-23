import 'package:flutter/material.dart';
import 'package:reverse_engineering_bca/dashboard/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:reverse_engineering_bca/providers/transaction_provider.dart';

// 1. Tambahkan import shared_preferences
import 'package:shared_preferences/shared_preferences.dart';
// 2. Import halaman password yang tadi dibuat (sesuaikan path-nya jika ditaruh di dalam folder)
import 'package:reverse_engineering_bca/authentication/login_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final transactionProvider = TransactionProvider();
  await transactionProvider.loadData();

  // 3. Cek "ingatan" HP sebelum menjalankan aplikasi
  final prefs = await SharedPreferences.getInstance();
  final bool isActivated = prefs.getBool('isActivated') ?? false;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: transactionProvider)],
      // 4. Kirim status isActivated ke dalam widget utama
      child: MyBcaCloneApp(isActivated: isActivated),
    ),
  );
}

class MyBcaCloneApp extends StatelessWidget {
  // 5. Buat variabel untuk menerima status dari void main
  final bool isActivated;

  const MyBcaCloneApp({super.key, required this.isActivated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myBCA',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF005BAC),
      ),
      // 6. Logika penentu: Kalau sudah aktivasi langsung ke Home, kalau belum ke Password
      home: isActivated ? const MyBcaHomeScreen() : const LoginPasswordPage(),
    );
  }
}
