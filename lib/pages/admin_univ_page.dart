import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import 'admin_dosen_page.dart';
import 'kelas_kuliah_page.dart';
import 'mata_kuliah_page.dart';
import 'prodi_page.dart';
import 'admin_mahasiswa_page.dart';
import '../utils/logout.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class AdminUnivPage extends StatefulWidget {
  const AdminUnivPage({super.key});

  @override
  State<AdminUnivPage> createState() => _AdminUnivPageState();
}

class _AdminUnivPageState extends State<AdminUnivPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    ProdiPage(),
    AdminMahasiswaPage(),
    AdminDosenPage(),
    MataKuliahPage(),
    KelasKuliahPage(),
  ];

  final List<String> titles = const [
    'Manajemen Prodi',
    'Manajemen Mahasiswa',
    'Manajemen Dosen',
    'Manajemen Mata Kuliah',
    'Manajemen Kelas Kuliah',
  ];

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
          const _AdminUnivStats(),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Prodi'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Mahasiswa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Dosen'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Matkul'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Kelas'),
        ],
      ),
    );
  }
}

class _AdminUnivStats extends StatelessWidget {
  const _AdminUnivStats();

  @override
  Widget build(BuildContext context) {
    final totalKrs = AppData.daftarNilai.length;
    final belumDinilai = AppData.daftarNilai
        .where((nilai) => nilai.nilaiAngka == null)
        .length;
    final kelasPenuh = AppData.daftarKelas
        .where((kelas) => AppData.hitungPesertaKelas(kelas.id) >= kelas.kapasitas)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${AppData.daftarMahasiswa.length}',
                  label: 'Mahasiswa',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(value: '${AppData.daftarDosen.length}', label: 'Dosen'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(value: '${AppData.daftarKelas.length}', label: 'Kelas'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CyberPanel(
            child: Column(
              children: [
                ProgressMetric(
                  label: 'Nilai Belum Diinput',
                  value: '$belumDinilai/$totalKrs',
                  progress: totalKrs == 0 ? 0 : belumDinilai / totalKrs,
                  color: AppColors.goldLight,
                ),
                const SizedBox(height: 14),
                ProgressMetric(
                  label: 'Kelas Penuh',
                  value: '$kelasPenuh/${AppData.daftarKelas.length}',
                  progress: AppData.daftarKelas.isEmpty
                      ? 0
                      : kelasPenuh / AppData.daftarKelas.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
