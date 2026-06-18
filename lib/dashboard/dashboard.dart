import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:reverse_engineering_bca/account/accountinformation.dart';
import 'package:reverse_engineering_bca/settings/settings_page.dart';

class MyBcaHomeScreen extends StatefulWidget {
  const MyBcaHomeScreen({super.key});

  @override
  State<MyBcaHomeScreen> createState() => _MyBcaHomeScreenState();
}

class _MyBcaHomeScreenState extends State<MyBcaHomeScreen> {
  final Color bcaBlue = const Color(0xFF005BAC);
  final Color bcaLightBlue = const Color(0xFF1CB5E0);

  String userName = 'Default';
  String accountNumber = '0240219280';
  String balance = '154830048';
  bool isBalanceVisible = false;

  double scale = 1.0;

  String _formatBalance(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '0';
    String result = '';
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) {
        result = '.$result';
      }
      result = digits[i] + result;
      count++;
    }
    return result;
  }

  String _formatAccountNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    String result = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) {
        if (digits.length - i == 1) {
        } else {
          result += '-';
        }
      }
      result += digits[i];
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    scale = (MediaQuery.of(context).size.width / 430.0).clamp(0.7, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  _buildGreeting(),
                  _buildAccountCard(context),
                  Stack(
                    children: [
                      _buildPromoBanner(),
                      Padding(
                        padding: EdgeInsets.only(top: 70 * scale),
                        child: _buildMainMenu(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  const BcaPromoCarousel(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0 * scale,
        vertical: 12.0 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/header_myBCA.png', height: 30 * scale),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.headset_mic_outlined,
                  color: Colors.white,
                  size: 24 * scale,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 24 * scale,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        initialName: userName,
                        initialAccountNumber: accountNumber,
                        initialBalance: balance,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      userName = result['name'];
                      accountNumber = result['accountNumber'];
                      balance = result['balance'];
                    });
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white, size: 24 * scale),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0 * scale,
        vertical: 4.0 * scale,
      ),
      child: RichText(
        text: TextSpan(
          text: 'HELLO, ',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 14.5 * scale,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5,
          ),
          children: [
            TextSpan(
              text: userName.toUpperCase(),
              style: GoogleFonts.openSans(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10 * scale,
              offset: Offset(0, 5 * scale),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0 * scale),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF17C3CE), Color(0xFF0C97B2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16 * scale),
                  topRight: Radius.circular(16 * scale),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 14 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'BCA ID >',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 10 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    children: [
                      Text(
                        'Account: ${_formatAccountNumber(accountNumber)}',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Icon(Icons.copy, color: Colors.white70, size: 14 * scale),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Balance',
                        style: GoogleFonts.openSans(
                          color: Colors.grey,
                          fontSize: 12 * scale,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Text(
                            'IDR ',
                            style: GoogleFonts.openSans(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            isBalanceVisible
                                ? _formatBalance(balance)
                                : '••••••••',
                            style: GoogleFonts.openSans(
                              fontSize: 18 * scale,
                              letterSpacing: isBalanceVisible ? 0 : 2 * scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: bcaBlue,
                      size: 24 * scale,
                    ),
                    onPressed: () {
                      setState(() {
                        isBalanceVisible = !isBalanceVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountInformationPage(
                        accountNumber: accountNumber,
                        balance: balance,
                        isBalanceVisible: isBalanceVisible,
                        userName: userName,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16 * scale),
                  bottomRight: Radius.circular(16 * scale),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0 * scale),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: bcaBlue,
                        size: 20 * scale,
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        'Account Transactions',
                        style: GoogleFonts.openSans(
                          color: bcaBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0 * scale,
        right: 20.0 * scale,
        top: 16.0 * scale,
        bottom: 50.0 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 1, 91, 180),
            Color.fromARGB(255, 79, 214, 255),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 40.0 * scale),
            child: Image.asset(
              'assets/images/TheNewGebyar.png',
              height: 48 * scale,
              width: 140 * scale,
            ),
          ),
          Row(
            children: [
              Text(
                'Menangkan di Sini',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1 * scale),
                      blurRadius: 2.0 * scale,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white, size: 16 * scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              20 * scale,
              20 * scale,
              10 * scale,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Main Menu',
                  style: GoogleFonts.openSans(
                    color: const Color(0xFF003D79),
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.tune, color: bcaLightBlue, size: 16 * scale),
                    SizedBox(width: 4 * scale),
                    Text(
                      'Atur',
                      style: GoogleFonts.openSans(
                        color: bcaLightBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14 * scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildMenuGrid(),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    Widget buildTransferIcon() =>
        Icon(Icons.send, color: const Color(0xFF004D8E), size: 32 * scale);

    Widget buildBayarIsiUlangIcon() {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.receipt, color: const Color(0xFF004D8E), size: 30 * scale),
          Positioned(
            top: -2 * scale,
            left: -4 * scale,
            child: Container(
              padding: EdgeInsets.all(3 * scale),
              decoration: const BoxDecoration(
                color: Color(0xFF1CB5E0),
                shape: BoxShape.circle,
              ),
              child: Text(
                'Rp',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 7 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget buildInvestasiIcon() {
      return Container(
        width: 28 * scale,
        height: 28 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF004D8E),
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        child: Icon(Icons.show_chart, color: Colors.yellow, size: 20 * scale),
      );
    }

    Widget buildLifestyleIcon() {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.local_mall,
            color: const Color(0xFF004D8E),
            size: 30 * scale,
          ),
          Positioned(
            bottom: -2 * scale,
            right: -6 * scale,
            child: Icon(
              Icons.local_mall,
              color: const Color(0xFF1CB5E0),
              size: 18 * scale,
            ),
          ),
        ],
      );
    }

    Widget buildEStatementIcon() => Icon(
      Icons.description,
      color: const Color(0xFF004D8E),
      size: 32 * scale,
    );

    Widget buildFlazzIcon() {
      return Container(
        width: 32 * scale,
        height: 22 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF004D8E),
          borderRadius: BorderRadius.circular(4 * scale),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 2 * scale,
              left: 2 * scale,
              child: Icon(
                Icons.wifi,
                color: const Color(0xFF1CB5E0),
                size: 10 * scale,
              ),
            ),
            Text(
              'Flazz',
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 8 * scale,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildCardlessIcon() {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.phone_android,
            color: const Color(0xFF004D8E),
            size: 30 * scale,
          ),
          Positioned(
            bottom: 4 * scale,
            right: -6 * scale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4 * scale,
                vertical: 2 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1CB5E0),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
              child: Text(
                'Rp',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 6 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget buildProdukPerbankanIcon() {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.account_balance,
            color: const Color(0xFF004D8E),
            size: 30 * scale,
          ),
          Positioned(
            bottom: -2 * scale,
            right: -4 * scale,
            child: Container(
              padding: EdgeInsets.all(2 * scale),
              decoration: const BoxDecoration(
                color: Color(0xFF1CB5E0),
                shape: BoxShape.circle,
              ),
              child: Text(
                'Rp',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 7 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget buildProteksiIcon() => Icon(
      Icons.health_and_safety,
      color: const Color(0xFF004D8E),
      size: 32 * scale,
    );

    Widget buildSemuaFiturIcon() {
      return SizedBox(
        width: 26 * scale,
        height: 26 * scale,
        child: Wrap(
          spacing: 2 * scale,
          runSpacing: 2 * scale,
          children: [
            Container(
              width: 12 * scale,
              height: 12 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF004D8E),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
            Container(
              width: 12 * scale,
              height: 12 * scale,
              decoration: BoxDecoration(
                color: Colors.amber.shade400,
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
            Container(
              width: 12 * scale,
              height: 12 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF004D8E),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
            Container(
              width: 12 * scale,
              height: 12 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF004D8E),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ],
        ),
      );
    }

    final List<Map<String, dynamic>> menuItems = [
      {'customIcon': buildTransferIcon(), 'label': 'Transfer', 'isNew': false},
      {
        'customIcon': buildBayarIsiUlangIcon(),
        'label': 'Bayar & Isi\nUlang',
        'isNew': true,
      },
      {
        'customIcon': buildInvestasiIcon(),
        'label': 'Investasi',
        'isNew': false,
      },
      {'customIcon': buildLifestyleIcon(), 'label': 'Lifestyle', 'isNew': true},
      {
        'customIcon': buildEStatementIcon(),
        'label': 'e-Statement',
        'isNew': false,
      },
      {'customIcon': buildFlazzIcon(), 'label': 'Flazz', 'isNew': false},
      {'customIcon': buildCardlessIcon(), 'label': 'Cardless', 'isNew': false},
      {
        'customIcon': buildProdukPerbankanIcon(),
        'label': 'Produk\nPerbankan',
        'isNew': false,
      },
      {'customIcon': buildProteksiIcon(), 'label': 'Proteksi', 'isNew': false},
      {
        'customIcon': buildSemuaFiturIcon(),
        'label': 'Semua Fitur',
        'isNew': false,
      },
    ];

    Widget buildItem(Map<String, dynamic> item) {
      return SizedBox(
        width: 95 * scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 60 * scale,
                  height: 60 * scale,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5F6FA),
                    shape: BoxShape.circle,
                  ),
                  child: item['customIcon'],
                ),
                if (item['isNew'])
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 8 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10 * scale),
            Text(
              item['label'],
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 11 * scale,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
            ),
          ],
        ),
      );
    }

    final ScrollController scrollController = ScrollController();
    double scrollProgress = 0.0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.maxScrollExtent > 0) {
                  setState(() {
                    scrollProgress =
                        notification.metrics.pixels /
                        notification.metrics.maxScrollExtent;
                    if (scrollProgress < 0.0) scrollProgress = 0.0;
                    if (scrollProgress > 1.0) scrollProgress = 1.0;
                  });
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(10 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: menuItems
                          .sublist(0, 5)
                          .map((item) => buildItem(item))
                          .toList(),
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: menuItems
                          .sublist(5, 10)
                          .map((item) => buildItem(item))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: 16 * scale,
                    color: bcaLightBlue,
                  ),
                  SizedBox(width: 4 * scale),
                  Container(
                    width: 24 * scale,
                    height: 5 * scale,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: scrollProgress * ((24 * scale) - (12 * scale)),
                          child: Container(
                            width: 12 * scale,
                            height: 5 * scale,
                            decoration: BoxDecoration(
                              color: bcaLightBlue,
                              borderRadius: BorderRadius.circular(10 * scale),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Icon(
                    Icons.chevron_right,
                    size: 16 * scale,
                    color: bcaLightBlue,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0 * scale,
        right: 20.0 * scale,
        bottom: 20.0 * scale,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0 * scale,
            vertical: 16.0 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F6FA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.contactless_outlined,
                      color: bcaBlue,
                      size: 20 * scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    'NFC Pay',
                    style: GoogleFonts.openSans(
                      color: const Color(0xFF003D79),
                      fontWeight: FontWeight.w800,
                      fontSize: 14 * scale,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/images/qris.png', // Logo QRIS dikembalikan menggunakan file barumu
                    height:
                        60 *
                        scale, // Tinggi di-set 20 agar seimbang proporsinya dengan ikon NFC Pay
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF003D79),
                    size: 24 * scale,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF004D8E)),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', isSelected: true),
              _buildNavItem(
                Icons.receipt_long,
                'Activity',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountInformationPage(
                        accountNumber: accountNumber,
                        balance: balance,
                        isBalanceVisible: isBalanceVisible,
                        userName: userName,
                      ),
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1CB5E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 28 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'QRIS',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildNavItem(Icons.star_border, 'For You'),
              _buildNavItem(
                Icons.person_outline,
                'My Account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        initialName: 'GUSTI FARHAN MUTTAQIN',
                        initialAccountNumber: accountNumber,
                        initialBalance: balance,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white60,
            size: 24 * scale,
          ),
          SizedBox(height: 4 * scale),
          Text(
            label,
            style: GoogleFonts.openSans(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10 * scale,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET CAROUSEL PROMO
// ---------------------------------------------------------------------------

class BcaPromoCarousel extends StatefulWidget {
  const BcaPromoCarousel({super.key});

  @override
  State<BcaPromoCarousel> createState() => _BcaPromoCarouselState();
}

class _BcaPromoCarouselState extends State<BcaPromoCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  double scale = 1.0;

  final List<String> _promoItems = [
    'assets/images/gebyar_hadiah.jpeg',
    'assets/images/diskon.jpeg',
    'assets/images/investasi.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _promoItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scale = (MediaQuery.of(context).size.width / 430.0).clamp(0.7, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 120 * scale,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _promoItems.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 8.0 * scale,
                  vertical: 8.0 * scale,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5 * scale,
                      offset: Offset(0, 3 * scale),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(_promoItems[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.0 * scale),
              height: 6 * scale,
              width: _currentPage == index ? 20 * scale : 6 * scale,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF1CB5E0)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3 * scale),
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * scale),
      ],
    );
  }
}
