import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../utils/logout.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'prodi_mahasiswa_page.dart';
import 'mata_kuliah_page.dart';
import 'kelas_kuliah_page.dart';

class AdminProdiPage extends StatefulWidget {
  const AdminProdiPage({super.key});

  @override
  State<AdminProdiPage> createState() => _AdminProdiPageState();
}

class _AdminProdiPageState extends State<AdminProdiPage> {
  int selectedIndex = 0;

  final pages = const [
    ProdiMahasiswaPage(),
    MataKuliahPage(),
    KelasKuliahPage(),
  ];

  final titles = const ['Mahasiswa Prodi', 'Mata Kuliah', 'Kelas Kuliah'];

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      child: Column(
        children: [
          const _AdminProdiStats(),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Mahasiswa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Matkul'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Kelas'),
        ],
      ),
    );
  }
}

class _AdminProdiStats extends StatelessWidget {
  const _AdminProdiStats();

  @override
  Widget build(BuildContext context) {
    final kodeProdi = AppData.currentAdminProdiKode;
    final mahasiswa = AppData.daftarMahasiswa
        .where((mhs) => mhs.kodeProdi == kodeProdi)
        .length;
    final matkul = AppData.daftarMataKuliah
        .where((mk) => mk.kodeProdi == kodeProdi)
        .length;
    final kelas = AppData.daftarKelas
        .where((kelas) => kelas.kodeProdi == kodeProdi)
        .toList();
    final idKelas = kelas.map((kelas) => kelas.id).toSet();
    final nilaiProdi = AppData.daftarNilai
        .where((nilai) => idKelas.contains(nilai.idKelasKuliah))
        .toList();
    final belumDinilai = nilaiProdi.where((nilai) => nilai.nilaiAngka == null).length;
    final totalKapasitas = kelas.fold<int>(0, (sum, kelas) => sum + kelas.kapasitas);
    final totalPeserta = kelas.fold<int>(
      0,
      (sum, kelas) => sum + AppData.hitungPesertaKelas(kelas.id),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: StatTile(value: '$mahasiswa', label: 'Mahasiswa')),
              const SizedBox(width: 10),
              Expanded(child: StatTile(value: '$matkul', label: 'Matkul')),
              const SizedBox(width: 10),
              Expanded(child: StatTile(value: '${kelas.length}', label: 'Kelas')),
            ],
          ),
          const SizedBox(height: 10),
          CyberPanel(
            child: Column(
              children: [
                ProgressMetric(
                  label: 'Keterisian Kelas',
                  value: '$totalPeserta/$totalKapasitas',
                  progress: totalKapasitas == 0 ? 0 : totalPeserta / totalKapasitas,
                ),
                const SizedBox(height: 14),
                ProgressMetric(
                  label: 'Nilai Belum Masuk',
                  value: '$belumDinilai/${nilaiProdi.length}',
                  progress: nilaiProdi.isEmpty ? 0 : belumDinilai / nilaiProdi.length,
                  color: AppColors.goldLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
