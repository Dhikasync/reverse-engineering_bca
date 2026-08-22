import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Pastikan path import ini disesuaikan dengan struktur folder Anda
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
    // Mengambil tahun saat ini secara real-time
    selectedYear = DateTime.now().year.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil waktu sistem saat ini secara real-time
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    int selYearInt = int.parse(selectedYear);

    return Scaffold(
      // Mengubah agar body bisa digambar di bawah AppBar yang transparan
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors
            .transparent, // Diubah menjadi transparan agar background image terlihat
        elevation: 0,
        centerTitle:
            false, // Menyesuaikan jika Anda ingin ke tengah bisa ganti true
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Periode',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        // Menambahkan gambar background dari asset
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
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
                      Text(
                        'Tahun',
                        style: GoogleFonts.openSans(
                          color: bcaBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2), // Jarak merapat ke angka tahun
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PilihTahunPage(),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              selectedYear = result as String;

                              // Validasi Reset Bulan jika kembali ke tahun saat ini dan bulan belum terjadi
                              int newYear = int.parse(selectedYear);
                              if (selectedMonthIndex != null &&
                                  newYear == currentYear) {
                                if ((selectedMonthIndex! + 1) >= currentMonth) {
                                  selectedMonthIndex = null;
                                }
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 8),
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
                                style: GoogleFonts.openSans(
                                  fontSize: 18, // Font diatur kembali ke normal
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: bcaBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bulan',
                        style: GoogleFonts.openSans(
                          color: bcaBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 16,
                                // Mengubah rasio agar kotak bulan lebih ramping dan tidak gemuk
                                childAspectRatio: 2.8,
                              ),
                          itemCount: months.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedMonthIndex == index;

                            // Logika Disable (Abu-abu) untuk bulan yang belum terlewati di tahun ini
                            bool isDisabled =
                                (selYearInt == currentYear) &&
                                ((index + 1) >= currentMonth);

                            return GestureDetector(
                              onTap: isDisabled
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedMonthIndex = index;
                                      });
                                    },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDisabled
                                      ? Colors.grey.shade100
                                      : (isSelected ? bcaBlue : Colors.white),
                                  border: Border.all(
                                    width: 1.0,
                                    color: isDisabled
                                        ? Colors.grey.shade200
                                        : (isSelected
                                              ? bcaBlue
                                              : Colors.grey.shade300),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  months[index],
                                  style: GoogleFonts.openSans(
                                    color: isDisabled
                                        ? Colors.grey.shade400
                                        : (isSelected ? Colors.white : bcaBlue),
                                    // Tidak di-bold dan sedikit diperbesar
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedMonthIndex != null
                              ? () {
                                  String monthName =
                                      months[selectedMonthIndex!];
                                  String formattedMonth =
                                      monthName[0].toUpperCase() +
                                      monthName.substring(1).toLowerCase();

                                  String selectedPeriod =
                                      "$formattedMonth $selectedYear";

                                  Navigator.pop(context, selectedPeriod);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bcaBlue,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Tampilkan',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
