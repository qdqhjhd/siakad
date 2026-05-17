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
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _AdminDashboard(),
    ProdiPage(),
    AdminMahasiswaPage(),
    AdminDosenPage(),
    MataKuliahPage(),
    KelasKuliahPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      sidebarItems: const [
        SidebarItem(icon: Icons.analytics_rounded, label: 'Dashboard'),
        SidebarItem(icon: Icons.school_rounded, label: 'Prodi'),
        SidebarItem(icon: Icons.people_rounded, label: 'Mahasiswa'),
        SidebarItem(icon: Icons.person_search_rounded, label: 'Dosen'),
        SidebarItem(icon: Icons.library_books_rounded, label: 'Matkul'),
        SidebarItem(icon: Icons.class_rounded, label: 'Kelas'),
      ],
      selectedIndex: _selectedIndex,
      onItemSelected: (index) => setState(() => _selectedIndex = index),
      child: _pages[_selectedIndex],
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    final totalKrs = AppData.daftarNilai.length;
    final belumDinilai = AppData.daftarNilai.where((n) => n.nilaiAngka == null).length;
    final kelasPenuh = AppData.daftarKelas
        .where((k) => AppData.hitungPesertaKelas(k.id) >= k.kapasitas)
        .length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Panel',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  Text('Kelola seluruh data akademik universitas.', style: TextStyle(color: AppColors.textSecondary)),
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
                      const Text('Total Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('${AppData.daftarMahasiswa.length}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                      const Text('Terdaftar aktif', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                      const Text('Total Dosen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text('${AppData.daftarDosen.length}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.accent)),
                      const Text('Tenaga pengajar', style: TextStyle(fontSize: 12, color: Colors.white54)),
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
                const Text('Progres Input Nilai', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Siswa Belum Dinilai',
                  value: '$belumDinilai / $totalKrs',
                  progress: totalKrs == 0 ? 0 : belumDinilai / totalKrs,
                  color: AppColors.error,
                ),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Kapasitas Kelas Terpakai',
                  value: '$kelasPenuh / ${AppData.daftarKelas.length}',
                  progress: AppData.daftarKelas.isEmpty ? 0 : kelasPenuh / AppData.daftarKelas.length,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
