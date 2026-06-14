import 'package:flutter/material.dart';
import 'package:reverse_engineering_bca/dashboard/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:reverse_engineering_bca/providers/transaction_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyBcaCloneApp(),
    ),
  );
}

class MyBcaCloneApp extends StatelessWidget {
  const MyBcaCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myBCA Clone',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF005BAC),
      ),
      home: const MyBcaHomeScreen(),
    );
  }
}
