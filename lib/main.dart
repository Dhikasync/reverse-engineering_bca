import 'package:flutter/material.dart';
import 'package:reverse_engineering_bca/dashboard/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:reverse_engineering_bca/providers/transaction_provider.dart';

// 1. Tambahkan import shared_preferences
import 'package:shared_preferences/shared_preferences.dart';
// 2. Import halaman
import 'package:reverse_engineering_bca/authentication/license_page.dart';
import 'package:reverse_engineering_bca/start/main_start.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final transactionProvider = TransactionProvider();
  await transactionProvider.loadData();

  // 3. Cek "ingatan" HP sebelum menjalankan aplikasi
  final prefs = await SharedPreferences.getInstance();
  final bool isActivated = prefs.getBool('isActivated') ?? false;

  // Cek apakah aplikasi sudah diaktifkan dengan License Key
  final bool isLicensed = prefs.getBool('isLicensed') ?? false;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: transactionProvider)],
      // 4. Kirim status isActivated dan isLicensed ke dalam widget utama
      child: MyBcaCloneApp(isActivated: isActivated, isLicensed: isLicensed),
    ),
  );
}

class MyBcaCloneApp extends StatelessWidget {
  // 5. Buat variabel untuk menerima status dari void main
  final bool isActivated;
  final bool isLicensed;

  const MyBcaCloneApp({
    super.key,
    required this.isActivated,
    required this.isLicensed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myBCA',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF005BAC),
      ),
      // 6. Tampilkan License Page atau Splash Screen terlebih dahulu
      home: isLicensed
          ? MainStartScreen(isActivated: isActivated)
          : SecretCodePage(isActivated: isActivated),
    );
  }
}
