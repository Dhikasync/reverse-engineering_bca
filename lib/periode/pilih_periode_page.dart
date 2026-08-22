import 'package:flutter/material.dart';
// Pastikan path import ini disesuaikan jika letak foldernya berbeda
import 'pilih_tahun_page.dart';

class PilihPeriodePage extends StatefulWidget {
  const PilihPeriodePage({Key? key}) : super(key: key);

  @override
  State<PilihPeriodePage> createState() => _PilihPeriodePageState();
}

class _PilihPeriodePageState extends State<PilihPeriodePage> {
  final Color bcaBlue = const Color(0xFF0066AE);

  late String selectedYear;
  int? selectedMonthIndex;

  final List<String> months = [
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];

  @override
  void initState() {
    super.initState();
    // Set default value ke tahun saat ini secara real-time
    selectedYear = DateTime.now().year.toString();
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
          'Periode',
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
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label Tahun
            Text(
              'Tahun',
              style: TextStyle(
                color: bcaBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Sans',
              ),
            ),
            const SizedBox(height: 8),

            // Tombol Pilih Tahun
            GestureDetector(
              onTap: () async {
                // Navigasi ke halaman Pilih Tahun dan tunggu hasilnya
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PilihTahunPage(),
                  ),
                );

                // Jika user memilih tahun (tidak menekan tombol back saja), perbarui state
                if (result != null) {
                  setState(() {
                    selectedYear = result as String;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedYear,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontFamily: 'Sans',
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: bcaBlue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Label Bulan
            Text(
              'Bulan',
              style: TextStyle(
                color: bcaBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Sans',
              ),
            ),
            const SizedBox(height: 16),

            // Grid Bulan Penuh
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedMonthIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMonthIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? bcaBlue : Colors.white,
                        border: Border.all(
                          color: isSelected ? bcaBlue : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        months[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : bcaBlue,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Button Tampilkan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedMonthIndex != null
                    ? () {
                        // Aksi untuk membuka PDF berdasarkan kombinasi bulan dan tahun
                        // Contoh: String selectedPeriod = "${months[selectedMonthIndex!]} $selectedYear";
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcaBlue,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Tampilkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
