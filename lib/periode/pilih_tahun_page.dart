import 'package:flutter/material.dart';

class PilihTahunPage extends StatefulWidget {
  const PilihTahunPage({Key? key}) : super(key: key);

  @override
  State<PilihTahunPage> createState() => _PilihTahunPageState();
}

class _PilihTahunPageState extends State<PilihTahunPage> {
  final Color bcaBlue = const Color(0xFF0066AE);
  List<String> years = [];
  List<String> filteredYears = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengambil tahun saat ini secara real-time dari sistem HP
    int currentYear = DateTime.now().year;

    // Menghasilkan daftar tahun dari tahun saat ini mundur hingga 2010
    for (int i = currentYear; i >= 2010; i--) {
      years.add(i.toString());
    }
    filteredYears = years;
  }

  void _filterYears(String query) {
    setState(() {
      filteredYears = years.where((year) => year.contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bcaBlue,
      appBar: AppBar(
        backgroundColor: bcaBlue,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Pilih Tahun',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Sans',
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterYears,
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'Sans',
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // List Tahun
            Expanded(
              child: ListView.separated(
                itemCount: filteredYears.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    title: Text(
                      filteredYears[index],
                      style: TextStyle(
                        color: bcaBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Sans',
                      ),
                    ),
                    onTap: () {
                      // Mengirimkan tahun yang dipilih kembali ke halaman sebelumnya
                      Navigator.pop(context, filteredYears[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
