import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:reverse_engineering_bca/account/accountinformation.dart';
import 'package:reverse_engineering_bca/settings/settings_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:reverse_engineering_bca/providers/transaction_provider.dart';
import 'package:reverse_engineering_bca/authentication/login_page.dart';

class MyBcaHomeScreen extends StatefulWidget {
  const MyBcaHomeScreen({super.key});

  @override
  State<MyBcaHomeScreen> createState() => _MyBcaHomeScreenState();
}

class _MyBcaHomeScreenState extends State<MyBcaHomeScreen> {
  final Color bcaBlue = const Color(0xFF005BAC);
  final Color bcaLightBlue = const Color(0xFF1CB5E0);

  String userName = 'Default';
  String bcaId = 'DE********T';
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
          result += ' - ';
        }
      }
      result += digits[i];
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    scale = (MediaQuery.of(context).size.width / 430.0).clamp(0.7, 1.0);
    final provider = context.watch<TransactionProvider>();
    userName = provider.userName;
    bcaId = provider.bcaId;
    accountNumber = provider.accountNumber;
    balance = provider.balance;

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
                        initialBcaId: bcaId,
                        initialAccountNumber: accountNumber,
                        initialBalance: balance,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      userName = result['name'];
                      bcaId = result['bcaId'];
                      accountNumber = result['accountNumber'];
                      balance = result['balance'];
                    });
                  }
                },
              ),
              IconButton(
                icon: SvgPicture.string(
                  '''<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 511.989 511.989" style="enable-background:new 0 0 511.989 511.989;" xml:space="preserve" stroke="#000000" stroke-width="20" stroke-linejoin="round">
                      <g><g><g>
                        <path d="M111.855,2.304L31.172,34.586C8.448,43,0,54.418,0,76.715v358.477c0,22.298,8.448,33.715,30.959,42.061l81.058,32.427 c4.011,1.519,8.038,2.287,11.981,2.287c17.152,0,29.602-14.336,29.602-34.091V34.049C153.6,9.78,134.246-6.126,111.855,2.304z M136.533,477.876c0,10.18-5.035,17.024-12.535,17.024c-1.869,0-3.883-0.401-5.803-1.118L37.103,461.33 c-16.102-5.965-20.036-11.102-20.036-26.138V76.715c0-15.036,3.934-20.164,20.241-26.206l80.725-32.29 c2.082-0.785,4.087-1.186,5.956-1.186c7.501,0,12.544,6.835,12.544,17.016V477.876z"/>
                        <path d="M178.133,51.115h120.533c14.114,0,25.6,11.486,25.6,25.6v128c0,4.71,3.814,8.533,8.533,8.533 c4.719,0,8.533-3.823,8.533-8.533v-128c0-23.526-19.14-42.667-42.667-42.667H178.133c-4.71,0-8.533,3.823-8.533,8.533 S173.423,51.115,178.133,51.115z"/>
                        <path d="M332.8,298.582c-4.719,0-8.533,3.823-8.533,8.533v128c0,14.114-11.486,25.6-25.6,25.6H179.2 c-4.71,0-8.533,3.823-8.533,8.533s3.823,8.533,8.533,8.533h119.467c23.526,0,42.667-19.14,42.667-42.667v-128 C341.333,302.405,337.519,298.582,332.8,298.582z"/>
                        <path d="M511.343,252.655c-0.435-1.05-1.058-1.988-1.852-2.782l-85.325-85.333c-3.337-3.336-8.73-3.336-12.066,0 c-3.337,3.337-3.337,8.73,0,12.066l70.767,70.775H325.000c-4.71,0-8.533,3.823-8.533,8.533c0,4.71,3.823,8.533,8.533,8.533 h157.868L412.1,335.215c-3.337,3.337-3.337,8.73,0,12.066c1.664,1.664,3.849,2.5,6.033,2.5c2.185,0,4.369-0.836,6.033-2.5 l85.325-85.325c0.794-0.794,1.417-1.732,1.852-2.782C512.205,257.093,512.205,254.738,511.343,252.655z"/>
                      </g></g></g>
                    </svg>''',
                  width: 22 * scale,
                  height: 22 * scale,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        title: Text(
                          'Konfirmasi',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF005BAC),
                          ),
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin keluar dari aplikasi?',
                          style: GoogleFonts.openSans(color: Colors.black87),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Tidak',
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Tutup dialog
                              Navigator.pop(context);
                              // Kembali ke halaman Login
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Ya',
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF005BAC),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
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
          text: 'HALO, ',
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
                  colors: [
                    Color.fromARGB(255, 95, 180, 206),
                    Color(0xFF0C97B2),
                  ],
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
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    children: [
                      Text(
                        'Rekening: ${_formatAccountNumber(accountNumber)}',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      GestureDetector(
                        onTap: () async {
                          // Menyalin nomor rekening secara senyap
                          await Clipboard.setData(
                            ClipboardData(text: accountNumber),
                          );
                        },
                        child: Transform.scale(
                          scaleX:
                              -1, // <--- Ini yang berfungsi me-mirror icon secara horizontal
                          child: Icon(
                            CupertinoIcons.square_on_square,
                            color: Colors.white70,
                            size: 16 * scale,
                          ),
                        ),
                      ),
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
                        'Saldo Aktif',
                        style: GoogleFonts.openSans(
                          color: const Color(0xFF333333),
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Text(
                            'IDR ',
                            style: GoogleFonts.openSans(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 54, 54, 54),
                            ),
                          ),
                          Text(
                            isBalanceVisible
                                ? _formatBalance(balance)
                                : '••••••••',
                            style: GoogleFonts.openSans(
                              fontSize: 18 * scale,
                              letterSpacing: isBalanceVisible ? 0 : 2 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 54, 54, 54),
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
                        'Mutasi Rekening',
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
                  'Menu Utama',
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
                      'Kelola',
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
        'label': 'Bayar & Isi Ulang',
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
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 52 * scale,
                    height: 52 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F6FA),
                      borderRadius: BorderRadius.circular(12 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: -0.785398, // counter-rotate icon back to upright
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: item['isNew'] ? 6.0 * scale : 0.0,
                        ),
                        child: item['customIcon'],
                      ),
                    ),
                  ),
                ),
                if (item['isNew'])
                  Positioned(
                    bottom: -2 * scale,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5 * scale,
                        vertical: 1.5 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        'BARU',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 7 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 14 * scale),
            Text(
              item['label'],
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 13 * scale,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
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
                    SizedBox(height: 28 * scale),
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
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16 * scale,
              spreadRadius: 1 * scale,
              offset: Offset(0, 6 * scale),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.0 * scale,
            vertical: 6.0 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 44 * scale,
                      height: 44 * scale,
                      color: bcaBlue,
                      child: Center(
                        child: SvgPicture.string(
                          '''<svg id="Capa_1" enable-background="new 0 0 512 512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><g><path d="m291.88 507.606c-5.858-5.858-5.858-15.355 0-21.213 127.039-127.039 127.039-333.747 0-460.786-5.858-5.858-5.858-15.355 0-21.213s15.355-5.858 21.213 0c33.962 33.962 60.26 73.568 78.163 117.717 17.289 42.635 26.056 87.682 26.056 133.89 0 46.207-8.767 91.254-26.056 133.89-17.903 44.149-44.201 83.755-78.163 117.717-5.857 5.856-15.355 5.856-21.213-.002z"/><path d="m227.614 443.34c-5.858-5.858-5.858-15.355 0-21.213 91.602-91.602 91.602-240.651 0-332.253-5.858-5.858-5.858-15.355 0-21.213s15.355-5.858 21.213 0c50.04 50.04 77.598 116.572 77.599 187.34 0 70.768-27.559 137.3-77.599 187.34-5.858 5.856-15.355 5.856-21.213-.001z"/><path d="m163.347 379.073c-5.858-5.858-5.858-15.355 0-21.213 56.166-56.166 56.166-147.554 0-203.72-5.858-5.858-5.858-15.355 0-21.213s15.355-5.858 21.213 0c67.863 67.863 67.863 178.283 0 246.146-5.857 5.858-15.355 5.858-21.213 0z"/><path d="m99.08 314.806c-5.858-5.858-5.858-15.355 0-21.213 20.729-20.729 20.729-54.458 0-75.187-5.858-5.858-5.858-15.355 0-21.213s15.355-5.858 21.213 0c32.426 32.426 32.426 85.187 0 117.613-5.857 5.858-15.355 5.858-21.213 0z"/></g></svg>''',
                          width: 26 * scale,
                          height: 26 * scale,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
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
                  Image.asset('assets/images/qris.png', height: 72 * scale),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF003D79),
                    size: 36 * scale,
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
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double barHeight = 64.0 * scale;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // 1. Main Navigation Bar
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          child: Container(
            height: barHeight + bottomPadding,
            decoration: const BoxDecoration(color: Color(0xFF004D8E)),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        Icons.account_balance,
                        'Beranda',
                        isSelected: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        Icons.history,
                        'Aktivitas',
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
                    ),
                  ),
                  // Middle item: placeholder space and aligned QRIS label image
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24 * scale,
                          ), // Matches NavItem icon size
                          SizedBox(
                            height: 4 * scale,
                          ), // Matches NavItem gap size
                          Image.asset(
                            'assets/images/Logo QRIS.png',
                            height: 18 * scale,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        null,
                        'Untuk Anda',
                        customIcon: Builder(
                          builder: (context) {
                            final Color iconColor = Colors.white60;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.circle_outlined,
                                  color: iconColor,
                                  size: 24 * scale,
                                ),
                                Icon(
                                  Icons.star,
                                  color: iconColor,
                                  size: 13 * scale,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        Icons.person_outline,
                        'Akun Saya',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                initialName: userName,
                                initialBcaId: bcaId,
                                initialAccountNumber: accountNumber,
                                initialBalance: balance,
                              ),
                            ),
                          );
                          if (result != null && result is Map) {
                            setState(() {
                              userName = result['name'];
                              bcaId = result['bcaId'];
                              accountNumber = result['accountNumber'];
                              balance = result['balance'];
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Floating Diamond QRIS Scan Button
        Positioned(
          bottom: barHeight + bottomPadding - 23 * scale,
          child: GestureDetector(
            onTap: () {
              // QRIS Scan Tap Action
            },
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF1CB5E0),
                  borderRadius: BorderRadius.circular(12 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -0.785398, // Rotate back
                  child: Center(
                    child: Image.asset(
                      'assets/images/LogoQRIS_SCAN.png',
                      width: 24 * scale,
                      height: 24 * scale,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    IconData? icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
    Widget? customIcon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          customIcon ??
              Icon(
                icon!,
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
          height: 160 * scale,
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
