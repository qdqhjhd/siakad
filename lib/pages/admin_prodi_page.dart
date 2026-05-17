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
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _AdminProdiDashboard(),
    ProdiMahasiswaPage(),
    MataKuliahPage(),
    KelasKuliahPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      sidebarItems: const [
        SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        SidebarItem(icon: Icons.groups_rounded, label: 'Mahasiswa'),
        SidebarItem(icon: Icons.library_books_rounded, label: 'Mata Kuliah'),
        SidebarItem(icon: Icons.class_rounded, label: 'Kelas Kuliah'),
      ],
      selectedIndex: _selectedIndex,
      onItemSelected: (i) => setState(() => _selectedIndex = i),
      child: _pages[_selectedIndex],
    );
  }
}

class _AdminProdiDashboard extends StatelessWidget {
  const _AdminProdiDashboard();

  @override
  Widget build(BuildContext context) {
    final kodeProdi = AppData.currentAdminProdiKode;
    final mahasiswa = AppData.daftarMahasiswa.where((m) => m.kodeProdi == kodeProdi).length;
    final matkul = AppData.daftarMataKuliah.where((m) => m.kodeProdi == kodeProdi).length;
    final kelas = AppData.daftarKelas.where((k) => k.kodeProdi == kodeProdi).toList();
    final idKelas = kelas.map((k) => k.id).toSet();
    final nilaiProdi = AppData.daftarNilai.where((n) => idKelas.contains(n.idKelasKuliah)).toList();
    final belumDinilai = nilaiProdi.where((n) => n.nilaiAngka == null).length;
    final totalKapasitas = kelas.fold<int>(0, (s, k) => s + k.kapasitas);
    final totalPeserta = kelas.fold<int>(0, (s, k) => s + AppData.hitungPesertaKelas(k.id));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admin Prodi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text('Program Studi: $kodeProdi', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => logout(context),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('LOGOUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: CyberPanel(
                  color: AppColors.bg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mahasiswa Prodi', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('$mahasiswa', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CyberPanel(
                  color: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mata Kuliah', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text('$matkul', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.accent)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CyberPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statistik Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Keterisian Kelas',
                  value: '$totalPeserta / $totalKapasitas',
                  progress: totalKapasitas == 0 ? 0 : totalPeserta / totalKapasitas,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Nilai Belum Masuk',
                  value: '$belumDinilai / ${nilaiProdi.length}',
                  progress: nilaiProdi.isEmpty ? 0 : belumDinilai / nilaiProdi.length,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
