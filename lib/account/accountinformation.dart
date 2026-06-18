import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/transaction_provider.dart';

// --- IMPORT FILE HALAMAN BARU ---
import 'e_statement_page.dart';

class AccountInformationPage extends StatefulWidget {
  final String accountNumber;
  final String balance;
  final bool isBalanceVisible;
  final String userName;

  const AccountInformationPage({
    super.key,
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
    required this.userName,
  });

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scrollProgress = (_scrollOffset / 108.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 1. Background Biru Bertekstur
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

          // 2. Nested Scroll View
          SafeArea(
            bottom: false,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                    Color appBarColor =
                        (innerBoxIsScrolled || scrollProgress == 1.0)
                        ? const Color(0xFF004D8E)
                        : Color.lerp(
                            Colors.transparent,
                            const Color(0xFF004D8E),
                            scrollProgress,
                          )!;

                    return <Widget>[
                      // App Bar
                      SliverAppBar(
                        backgroundColor: appBarColor,
                        elevation: 0.0,
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

                      // Account Info Card
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _AccountCardDelegate(
                          accountNumber: widget.accountNumber,
                          balance: widget.balance,
                          isBalanceVisible: widget.isBalanceVisible,
                          innerBoxIsScrolled: innerBoxIsScrolled,
                        ),
                      ),

                      // Tab Bar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyTabBarDelegate(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFEEEEEE),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              labelColor: const Color(0xFF00529C),
                              unselectedLabelColor: Colors.grey.shade500,
                              indicatorColor: const Color(0xFF00529C),
                              indicatorWeight: 3,
                              labelStyle: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              unselectedLabelStyle: GoogleFonts.openSans(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              tabs: const [
                                Tab(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Account Transactions'),
                                  ),
                                ),
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
                color: Colors.white,
                child: Column(
                  children: [
                    _buildSearchAndFilter(),
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

          // --- PERUBAHAN NAVIGASI HALAMAN E-STATEMENT DI SINI ---
          GestureDetector(
            onTap: () {
              // Buka halaman e-Statement secara penuh (Full Page)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EStatementPage(
                    userName: widget.userName,
                    accountNumber: widget.accountNumber,
                    balance: widget.balance,
                    accountTypeDetail: '',
                  ),
                ),
              );
            },
            child: Container(
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
          ),

          // --------------------------------------------------------
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
      itemCount: transactions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          if (provider.activeMonth.isNotEmpty) {
            String rawMonth = provider.activeMonth;
            String displayMonth = rawMonth
                .split(' ')
                .map((word) {
                  if (word.isEmpty) return '';
                  return word[0].toUpperCase() +
                      word.substring(1).toLowerCase();
                })
                .join(' ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 4.0, left: 4.0),
              child: Text(
                displayMonth,
                style: GoogleFonts.openSans(
                  color: const Color(0xFF003366), // Warna biru tua BCA
                  fontWeight: FontWeight.w800, // Tebal
                  fontSize: 16,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final tx = transactions[index - 1];
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

class _AccountCardDelegate extends SliverPersistentHeaderDelegate {
  final String accountNumber;
  final String balance;
  final bool isBalanceVisible;
  final bool innerBoxIsScrolled;

  _AccountCardDelegate({
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
    this.innerBoxIsScrolled = false,
  });

  @override
  double get minExtent => 84.0;
  @override
  double get maxExtent => 192.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    double shrinkProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );

    double horizontalPadding = 16.0;
    double topPadding = 12.0 - (4.0 * shrinkProgress);
    double bottomPadding = 20.0 - (4.0 * shrinkProgress);

    Color bgColor = (innerBoxIsScrolled || shrinkProgress == 1.0)
        ? const Color(0xFF004D8E)
        : Color.lerp(
            Colors.transparent,
            const Color(0xFF004D8E),
            shrinkProgress,
          )!;

    return Container(
      color: bgColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: topPadding,
            bottom: bottomPadding,
          ),
          child: AccountInfoCard(
            accountNumber: accountNumber,
            balance: balance,
            isBalanceVisible: isBalanceVisible,
            shrinkProgress: shrinkProgress,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AccountCardDelegate oldDelegate) {
    return oldDelegate.innerBoxIsScrolled != innerBoxIsScrolled ||
        oldDelegate.accountNumber != accountNumber ||
        oldDelegate.balance != balance ||
        oldDelegate.isBalanceVisible != isBalanceVisible;
  }
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
    super.key,
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
    required this.shrinkProgress,
  });

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
    double cardHeight = 160.0 - (100.0 * widget.shrinkProgress);
    double dynamicRadius = 16.0;

    return SizedBox(
      height: cardHeight,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(dynamicRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08 * (1.0 - widget.shrinkProgress),
              ),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(dynamicRadius),
          child: Stack(
            children: [
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

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  color: const Color(0xFF6A8EAE),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Account No.',
                        style: GoogleFonts.openSans(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatAccountNumber(widget.accountNumber),
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
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
    super.key,
    required this.dateOrStatus,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isDebit = true,
  });

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
          SizedBox(width: 60, child: _buildDateOrStatus()),
          const SizedBox(width: 12),
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

    if (parts.length >= 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            parts[0],
            style: GoogleFonts.openSans(
              color: const Color(0xFF333333).withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
              fontSize: 26,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            parts[1].toUpperCase(),
            style: GoogleFonts.openSans(
              color: Colors.grey.shade500.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 10,
              height: 1.0,
            ),
          ),
          Text(
            parts[2],
            style: GoogleFonts.openSans(
              color: Colors.grey.shade500.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 10,
              height: 1.0,
            ),
          ),
        ],
      );
    } else {
      bool isPending = dateOrStatus.toUpperCase() == 'PEND';
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          dateOrStatus,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            color: isPending ? Colors.orange.shade700 : Colors.grey.shade400,
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
  const SkeletonTransactionTile({super.key});

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
