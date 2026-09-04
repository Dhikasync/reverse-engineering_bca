import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_password_page.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double scale = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache gambar background untuk menghindari ngelag (jank) saat pertama kali buka LoginPasswordPage
    precacheImage(const AssetImage('assets/images/background.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    scale = (MediaQuery.of(context).size.width / 430.0).clamp(0.7, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_putih.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false, // Biarkan footer menempel sampai bawah layar
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context)
                          .padding
                          .top, // Jangan kurangi bottom padding agar bisa mentok
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildAppBar(),
                      const _LoginPromoCarousel(),
                      SizedBox(height: 8 * scale),
                      _buildGreeting(),
                      SizedBox(height: 12 * scale),
                      _buildLoginCard(),
                      const Spacer(),
                      _buildOtherServices(),
                      // SizedBox dihapus agar footer mentok bawah
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.0 * scale,
        8.0 * scale, // Kurangi top padding agar lebih ke atas
        20.0 * scale,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/mybca-logo-remove.png',
            height: 84 * scale, // Lebih besar dari 64, lebih kecil dari 120
            errorBuilder: (context, error, stackTrace) => Text(
              "myBCA",
              style: GoogleFonts.openSans(
                color: const Color(0xFF005BAC),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.headset_mic_outlined,
                    color: const Color(0xFF005BAC),
                    size: 18 * scale,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16 * scale,
                      height: 16 * scale,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      // Fake Indonesia Flag
                      child: Column(
                        children: [
                          Expanded(child: Container(color: Colors.red)),
                          Expanded(child: Container(color: Colors.white)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      'ID',
                      style: GoogleFonts.openSans(
                        color: const Color(0xFF005BAC),
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final provider = context.watch<TransactionProvider>();
    final userName = provider.userName.toUpperCase();
    final bcaId = provider.bcaId;

    return Column(
      children: [
        Text(
          'Halo,',
          style: GoogleFonts.openSans(
            color: Colors.black87,
            fontSize: 16 * scale,
          ),
        ),
        Text(
          userName,
          style: GoogleFonts.openSans(
            color: Colors.black87,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          bcaId,
          style: GoogleFonts.openSans(
            color: Colors.black54,
            fontSize: 14 * scale,
          ),
        ),
        SizedBox(height: 8 * scale),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Ganti Akun',
            style: GoogleFonts.openSans(
              color: const Color(0xFF005BAC),
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0 * scale),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    20 * scale,
                    20 * scale,
                    16 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F9FD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16 * scale),
                      topRight: Radius.circular(16 * scale),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(
                        Container(
                          width: 24 * scale,
                          height: 16 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFF004D8E),
                            borderRadius: BorderRadius.circular(3 * scale),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 1 * scale,
                                left: 1 * scale,
                                child: Icon(
                                  Icons.wifi,
                                  color: const Color(0xFF1CB5E0),
                                  size: 8 * scale,
                                ),
                              ),
                              Text(
                                'Flazz',
                                style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontSize: 6 * scale,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        'Flazz',
                      ),
                      _buildQuickAction(
                        Image.asset(
                          'assets/images/nfc-pay.png',
                          width: 32 * scale,
                          height: 32 * scale,
                        ),
                        'NFC Pay',
                      ),
                      _buildQuickAction(
                        Image.asset(
                          'assets/images/scan-qris.png',
                          width: 32 * scale,
                          height: 32 * scale,
                        ),
                        'Scan QRIS',
                      ),
                      _buildQuickAction(
                        Image.asset(
                          'assets/images/qris-transfer.png',
                          width: 32 * scale,
                          height: 32 * scale,
                        ),
                        'QRIS Transfer',
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16 * scale),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF8FAFC,
                    ), // "sedikit putih", off-white
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16 * scale),
                      bottomRight: Radius.circular(16 * scale),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(
                          color: const Color(0xFFE8F0F7),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune,
                            color: const Color(0xFF005BAC),
                            size: 16 * scale,
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            'Atur',
                            style: GoogleFonts.openSans(
                              color: const Color(0xFF005BAC),
                              fontWeight: FontWeight.bold,
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
          SizedBox(height: 24 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0 * scale),
            child: SizedBox(
              width: double.infinity,
              height: 56 * scale,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 160),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 160,
                      ),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const LoginPasswordPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Geser dari kanan
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
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005BAC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                  ),
                ),
                child: Text(
                  'Masuk',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.normal, // not bold
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(Widget iconWidget, String label) {
    return Column(
      children: [
        Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: 44 * scale,
            height: 44 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F6FA), // Light blue like dashboard
              borderRadius: BorderRadius.circular(10 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Transform.rotate(angle: -0.785398, child: iconWidget),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          label,
          style: GoogleFonts.openSans(
            color: const Color(0xFF003D79),
            fontWeight: FontWeight.w700,
            fontSize: 12 * scale,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtherServices() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 0, 20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC), // Sedikit terang
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ), // Radius di sudut atas agar tidak kaku
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.0 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan Lainnya',
                  style: GoogleFonts.openSans(
                    color: const Color(0xFF4A5568),
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.chevron_right, color: const Color(0xFF005BAC)),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildServiceItem(
                  Image.asset('assets/images/kpr.png'),
                  'Pengajuan\nKPR',
                ),
                _buildServiceItem(
                  Image.asset('assets/images/big.png'),
                  'BIG by BCA\nInsurance',
                ),
                _buildServiceItem(
                  Transform.translate(
                    offset: const Offset(
                      0,
                      -10,
                    ), // Geser sedikit ke atas (sebelum di-scale)
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        24,
                      ), // Radius besar karena gambar di-scale down
                      child: Image.asset(
                        'assets/images/bca-life.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  'BCA Life',
                ),
                _buildServiceItem(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/blu.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  'blu by\nBCA',
                ),
                SizedBox(width: 8 * scale),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF005BAC),
                size: 18 * scale,
              ),
              SizedBox(width: 8 * scale),
              Text(
                'About myBCA',
                style: GoogleFonts.openSans(
                  color: const Color(0xFF005BAC),
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Widget iconWidget, String label) {
    return Container(
      width: 100 * scale,
      height: 105 * scale,
      margin: EdgeInsets.only(right: 12 * scale),
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4 * scale,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28 * scale,
            height: 28 * scale,
            child: FittedBox(fit: BoxFit.contain, child: iconWidget),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              color: Colors.black54,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET CAROUSEL PROMO FOR LOGIN
// ---------------------------------------------------------------------------
class _LoginPromoCarousel extends StatefulWidget {
  const _LoginPromoCarousel();

  @override
  State<_LoginPromoCarousel> createState() => _LoginPromoCarouselState();
}

class _LoginPromoCarouselState extends State<_LoginPromoCarousel> {
  // Start at a large multiple of 5 so user can swipe left infinitely too
  int _currentPage = 1000;
  late PageController _pageController;
  Timer? _timer;
  double scale = 1.0;

  final List<String> _promoItems = [
    'assets/images/promo-1.jpeg',
    'assets/images/promo-2.jpeg',
    'assets/images/promo-3.jpeg',
    'assets/images/promo-4.jpeg',
    'assets/images/promo-5.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _currentPage++; // Selalu bertambah, tidak pernah reset ke 0

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
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

    return SizedBox(
      height: 160 * scale,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int index) {
          _currentPage = index;
        },
        // itemCount dihilangkan agar bisa scroll tak terbatas (infinite loop)
        itemBuilder: (context, index) {
          // Gunakan modulus untuk mengambil index array dengan aman
          final int itemIndex = index % _promoItems.length;

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
                image: AssetImage(_promoItems[itemIndex]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
