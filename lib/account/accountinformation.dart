import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Untuk format waktu UTC dinamis
import '../providers/transaction_provider.dart';

class AccountInformationPage extends StatefulWidget {
  final String accountNumber;
  final String balance;
  final bool isBalanceVisible;

  const AccountInformationPage({
    Key? key,
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
  }) : super(key: key);

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true; // State penanda loading

  @override
  void initState() {
    super.initState();
    // Menginisialisasi TabController untuk 3 tab
    _tabController = TabController(length: 3, vsync: this);

    // Simulasi pengambilan data (Loading selama 2 detik)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Warna dasar abu-abu terang
      body: Stack(
        children: [
          // 1. Background Biru Bertekstur (Fixed Position)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 2. Nested Scroll View untuk efek animasi Card & Sticky Tab Bar
          SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  // App Bar
                  SliverAppBar(
                    backgroundColor: innerBoxIsScrolled
                        ? const Color(0xFF004D8E)
                        : Colors.transparent,
                    elevation: innerBoxIsScrolled ? 4.0 : 0.0,
                    pinned: true,
                    centerTitle: false,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Account Information',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Account Info Card (Animasi Shrink: Bagian putih sembunyi, biru tetap sticky)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _AccountCardDelegate(
                      accountNumber: widget.accountNumber,
                      balance: widget.balance,
                      isBalanceVisible: widget.isBalanceVisible,
                    ),
                  ),

                  // Tab Bar (Akan menempel tepat di bawah kartu biru)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyTabBarDelegate(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFEEEEEE),
                              width: 1,
                            ),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true, // Agar tulisan melebar full
                          tabAlignment: TabAlignment.start, // Ratakan kiri
                          labelColor: const Color(0xFF00529C),
                          unselectedLabelColor: Colors.grey.shade500,
                          indicatorColor: const Color(0xFF00529C),
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          unselectedLabelStyle: GoogleFonts.openSans(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: 'Account Transactions'),
                            Tab(text: 'Card'),
                            Tab(text: 'Pocket'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                color: Colors.white, // Latar konten solid white
                child: Column(
                  children: [
                    // Search & Filter Bar
                    _buildSearchAndFilter(),

                    // Konten TabBar (Scrollable)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTransactionList(),
                          Center(
                            child: Text(
                              'Card Information',
                              style: GoogleFonts.openSans(),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Pocket Information',
                              style: GoogleFonts.openSans(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: GoogleFonts.openSans(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.filter_alt_outlined,
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: 6,
        itemBuilder: (context, index) => const SkeletonTransactionTile(),
      );
    }

    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada transaksi.\nUpload e-Statement di Pengaturan.',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return TransactionTile(
          dateOrStatus: tx.dateOrStatus,
          title: tx.title,
          subtitle: tx.subtitle,
          amount: tx.amount,
          isDebit: tx.isDebit,
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// DELEGATES UNTUK STICKY SCROLL
// -----------------------------------------------------------------------------

// Delegate untuk Sticky TabBar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => true;
}

// Delegate untuk animasi kartu (Sembunyikan bagian putih, sisakan biru di atas)
class _AccountCardDelegate extends SliverPersistentHeaderDelegate {
  final String accountNumber;
  final String balance;
  final bool isBalanceVisible;

  _AccountCardDelegate({
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
  });

  @override
  double get minExtent => 72.0; // 60 (Tinggi Card Biru) + 12 (Top Padding)
  @override
  double get maxExtent => 192.0; // 160 (Tinggi Total Card) + 12 (Top) + 20 (Bottom Padding)

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 0.0 (terbuka penuh) hingga 1.0 (menyusut penuh)
    double shrinkProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );

    // Padding bawah mengecil hingga 0 saat di-scroll agar TabBar menempel ke Header Biru
    double bottomPadding = 20.0 * (1.0 - shrinkProgress);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: bottomPadding,
      ),
      child: AccountInfoCard(
        accountNumber: accountNumber,
        balance: balance,
        isBalanceVisible: isBalanceVisible,
        shrinkProgress: shrinkProgress, // Progress dikirim ke kartu
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AccountCardDelegate oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// ACCOUNT INFO CARD WIDGET
// -----------------------------------------------------------------------------

class AccountInfoCard extends StatefulWidget {
  final String accountNumber;
  final String balance;
  final bool isBalanceVisible;
  final double shrinkProgress;

  const AccountInfoCard({
    Key? key,
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
    required this.shrinkProgress,
  }) : super(key: key);

  @override
  State<AccountInfoCard> createState() => _AccountInfoCardState();
}

class _AccountInfoCardState extends State<AccountInfoCard> {
  late bool _isBalanceVisible;
  late Timer _timer;
  String _currentUtcTime = '';

  @override
  void initState() {
    super.initState();
    _isBalanceVisible = widget.isBalanceVisible;
    _updateTime();

    // Timer UTC dinamis
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String pad(int n) => n.toString().padLeft(2, '0');

    if (mounted) {
      setState(() {
        _currentUtcTime =
            '${pad(now.day)} ${months[now.month - 1]} ${now.year} ${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)} UTC+7';
      });
    }
  }

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
    // Tinggi kartu mengecil dari 160 ke 60 sesuai scroll
    double cardHeight = 160.0 - (100.0 * widget.shrinkProgress);

    return SizedBox(
      height: cardHeight,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. Bagian Putih (Active Balance) - Akan slide ke atas & memudar saat diskrol
              Positioned(
                top: 60 - (60 * widget.shrinkProgress),
                left: 0,
                right: 0,
                height: 100,
                child: Opacity(
                  opacity: (1.0 - (widget.shrinkProgress * 1.5)).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Balance',
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'IDR ',
                                  style: GoogleFonts.openSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                Text(
                                  _isBalanceVisible
                                      ? _formatBalance(widget.balance)
                                      : '••••••••',
                                  style: GoogleFonts.openSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: _isBalanceVisible ? 0 : 2.0,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isBalanceVisible = !_isBalanceVisible;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  _isBalanceVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF005BAC),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'TAHAPAN - IDR',
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _currentUtcTime,
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Bagian Biru (Account No.) - Tetap di atas
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  color: const Color(0xFF6A8EAE),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Account No.',
                        style: GoogleFonts.openSans(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatAccountNumber(widget.accountNumber),
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, color: Colors.white, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LIST TRANSAKSI WIDGET
// -----------------------------------------------------------------------------

class TransactionTile extends StatelessWidget {
  final String dateOrStatus;
  final String title;
  final String subtitle;
  final String amount;
  final bool isDebit;

  const TransactionTile({
    Key? key,
    required this.dateOrStatus,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isDebit = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Kiri: Tanggal (Abu-abu standar) atau PEND (Oranye)
          SizedBox(width: 50, child: _buildDateOrStatus()),
          const SizedBox(width: 12),

          // Kolom Kanan: Detail Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.openSans(
                    color: const Color(0xFF003366),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.openSans(
                    color: const Color(0xFF003366),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: GoogleFonts.openSans(
                    color: isDebit
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF008A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOrStatus() {
    List<String> parts = dateOrStatus.split('\n');

    // Format Tanggal (cth: 06 \n JUN \n 2026) -> Warna abu-abu elegan seperti di BCA statement
    if (parts.length >= 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parts[0],
            style: GoogleFonts.openSans(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            parts[1].toUpperCase(),
            style: GoogleFonts.openSans(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            parts[2],
            style: GoogleFonts.openSans(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      );
    } else {
      // Kondisi untuk Status (contoh: PEND)
      bool isPending = dateOrStatus.toUpperCase() == 'PEND';

      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          dateOrStatus,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            color: isPending ? Colors.orange.shade700 : Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
            fontSize: 13,
          ),
        ),
      );
    }
  }
}

// -----------------------------------------------------------------------------
// SKELETON LOADING WIDGET
// -----------------------------------------------------------------------------

class SkeletonTransactionTile extends StatefulWidget {
  const SkeletonTransactionTile({Key? key}) : super(key: key);

  @override
  State<SkeletonTransactionTile> createState() =>
      _SkeletonTransactionTileState();
}

class _SkeletonTransactionTileState extends State<SkeletonTransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
