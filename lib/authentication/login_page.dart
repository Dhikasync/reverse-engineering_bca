import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_password_page.dart';
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(),
                  const _LoginPromoCarousel(),
                  SizedBox(height: 8 * scale),
                  _buildGreeting(),
                  SizedBox(height: 12 * scale),
                  _buildLoginCard(),
                  SizedBox(height: 12 * scale),
                  _buildOtherServices(),
                  const SizedBox(height: 16),
                ],
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
        12.0 * scale,
        20.0 * scale,
        0, // Hilangkan padding bawah agar tidak terlalu jauh
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/mybca-logo-remove.png',
            height: 120 * scale,
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
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.headset_mic_outlined,
                    color: const Color(0xFF005BAC),
                    size: 20 * scale,
                  ),
                  onPressed: () {},
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
                      _buildQuickAction(Icons.credit_card, 'Flazz'),
                      _buildQuickAction(Icons.wifi, 'NFC Pay'),
                      _buildQuickAction(Icons.qr_code_scanner, 'Scan QRIS'),
                      _buildQuickAction(Icons.receipt_long, 'QRIS Transfer'),
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

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44 * scale,
          height: 44 * scale,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF4F7FA),
                Color(0xFFE4EBF3),
              ], // Gradasi abu-abu kebiruan
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF005BAC), size: 24 * scale),
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
                _buildServiceItem(Icons.home, 'Pengajuan\nKPR', Colors.amber),
                _buildServiceItem(
                  Icons.security,
                  'BIG by BCA\nInsurance',
                  const Color(0xFF005BAC),
                ),
                _buildServiceItem(
                  Icons.health_and_safety,
                  'BCA Life',
                  Colors.teal,
                ),
                _buildServiceItem(
                  Icons.shopping_bag,
                  'blu by\nBCA',
                  Colors.blue,
                ),
                SizedBox(width: 8 * scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label, Color iconColor) {
    return Container(
      width: 100 * scale,
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
          Icon(icon, color: iconColor, size: 28 * scale),
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
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  double scale = 1.0;

  // Empty images for now
  final List<String> _promoItems = ['', '', ''];

  @override
  void dispose() {
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
        itemCount: _promoItems.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: 8.0 * scale,
              vertical: 8.0 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF005BAC), // Placeholder color
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Promo Image Placeholder\n(Kosong)',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
