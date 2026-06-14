import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          // 1. Background Biru Bertekstur
          _buildBlueBackground(),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                          return [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _AccountCardDelegate(
                                accountNumber: widget.accountNumber,
                                balance: widget.balance,
                                isBalanceVisible: widget.isBalanceVisible,
                                expandedHeight: 220.0,
                                collapsedHeight: 70.0,
                              ),
                            ),
                          ];
                        },
                    body: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 5. Tab Bar
                          _buildTabBar(),

                          // 6. Search & Filter Bar
                          _buildSearchAndFilter(),

                          // 7. TabBarView untuk konten tiap tab
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTransactionList(),
                                const Center(child: Text('Card Information')),
                                const Center(child: Text('Pocket Information')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ), // Closes Container (body)
                  ), // Closes NestedScrollView
                ), // Closes Expanded
              ], // Closes children of Column
            ), // Closes Column
          ), // Closes SafeArea
        ], // Closes children of Stack
      ), // Closes Stack
    ); // Closes Scaffold
  } // Closes build method

  // --- Komponen Internal Halaman ---

  Widget _buildBlueBackground() {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              // Kembali ke halaman Dashboard
              Navigator.pop(context);
            },
          ),
          const Text(
            'Account Information',
            style: TextStyle(
              fontFamily: 'MyBcaFont',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF00529C),
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: const Color(0xFF00529C),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Account Transactions'),
          Tab(text: 'Card'),
          Tab(text: 'Pocket'),
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
                  Text('Search', style: TextStyle(color: Colors.grey.shade400)),
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
    // Merender skeleton jika data masih dimuat
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: 6, // Jumlah skeleton
        itemBuilder: (context, index) => const SkeletonTransactionTile(),
      );
    }

    // Ambil data transaksi dari Provider
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada transaksi.\nUpload e-Statement di Pengaturan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Merender data dari PDF jika tersedia
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

class _AccountCardDelegate extends SliverPersistentHeaderDelegate {
  final String accountNumber;
  final String balance;
  final bool isBalanceVisible;
  final double expandedHeight;
  final double collapsedHeight;

  _AccountCardDelegate({
    required this.accountNumber,
    required this.balance,
    required this.isBalanceVisible,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant _AccountCardDelegate oldDelegate) {
    return oldDelegate.accountNumber != accountNumber ||
        oldDelegate.balance != balance ||
        oldDelegate.isBalanceVisible != isBalanceVisible;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
        alignment: Alignment.topCenter,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: AccountInfoCard(
            accountNumber: accountNumber,
            balance: balance,
            isBalanceVisible: isBalanceVisible,
            shrinkProgress: progress,
          ),
        ),
      ),
    );
  }
}

// --- Widget Terpisah (Clean Architecture UI) ---

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
    this.shrinkProgress = 0.0,
  }) : super(key: key);

  @override
  State<AccountInfoCard> createState() => _AccountInfoCardState();
}

class _AccountInfoCardState extends State<AccountInfoCard> {
  late bool _isBalanceVisible;

  @override
  void initState() {
    super.initState();
    _isBalanceVisible = widget.isBalanceVisible;
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Kartu
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF6A8EAE), // Adjust to grey-blue in image
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(16 * widget.shrinkProgress),
                bottomRight: Radius.circular(16 * widget.shrinkProgress),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account No.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatAccountNumber(widget.accountNumber),
                            style: const TextStyle(
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
              ],
            ),
          ),

          // Body Kartu
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Balance',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'IDR ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          _isBalanceVisible
                              ? _formatBalance(widget.balance)
                              : '••••••••',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: _isBalanceVisible ? 0 : 2.0,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _isBalanceVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF005BAC),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'TAHAPAN - IDR',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '06 Jun 2026 22:39:11 UTC+7',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          // Kolom Kiri: Tanggal / Status PEND
          SizedBox(
            width: 44, // Slightly wider to fit the year
            child: _buildDateOrStatus(),
          ),
          const SizedBox(width: 16),

          // Kolom Kanan: Detail Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF003366), // Warna biru gelap teks myBCA
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF003366),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: TextStyle(
                    color: isDebit
                        ? const Color(0xFFD32F2F)
                        : Colors.green, // Merah untuk pengeluaran
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
    if (parts.length == 3) {
      return Column(
        children: [
          Text(
            parts[0],
            style: const TextStyle(
              color: Color(0xFF003366),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            parts[1].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF003366),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            parts[2],
            style: const TextStyle(
              color: Color(0xFF003366),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      );
    } else {
      return Text(
        dateOrStatus,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
          fontSize: dateOrStatus == 'PEND' ? 12 : 14,
        ),
      );
    }
  }
}

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
    // Animasi denyut (pulse) untuk skeleton
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
            // Skeleton untuk Kolom Tanggal/Status
            Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),

            // Skeleton untuk Detail Transaksi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton Title (Baris 1)
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Skeleton Subtitle (Baris 2)
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Skeleton Amount (Baris 3)
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
