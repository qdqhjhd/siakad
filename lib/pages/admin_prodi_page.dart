import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import '../widgets/topbar_nav.dart';
import 'prodi_mahasiswa_page.dart';
import 'mata_kuliah_page.dart';
import 'kelas_kuliah_page.dart';
import 'ruangan_page.dart';
import 'dosen_pengajar_page.dart';
import 'presensi_page.dart';

class AdminProdiPage extends StatefulWidget {
  const AdminProdiPage({super.key});

  @override
  State<AdminProdiPage> createState() => _AdminProdiPageState();
}

enum _ProdiPageEnum { beranda, mahasiswa, matkul, kelas, ruangan, dosenPengajar, presensi }

class _AdminProdiPageState extends State<AdminProdiPage> {
  _ProdiPageEnum _activePage = _ProdiPageEnum.beranda;
  String? _openDropdown;

  void _goTo(_ProdiPageEnum page) => setState(() { _activePage = page; _openDropdown = null; });
  void _toggle(String key) => setState(() => _openDropdown = _openDropdown == key ? null : key);

  List<String> get _breadcrumbs {
    switch (_activePage) {
      case _ProdiPageEnum.mahasiswa: return ['Beranda', 'Akademik', 'Mahasiswa'];
      case _ProdiPageEnum.matkul: return ['Beranda', 'Akademik', 'Mata Kuliah'];
      case _ProdiPageEnum.kelas: return ['Beranda', 'Akademik', 'Kelas Kuliah'];
      case _ProdiPageEnum.ruangan: return ['Beranda', 'Akademik', 'Ruangan'];
      case _ProdiPageEnum.dosenPengajar: return ['Beranda', 'Akademik', 'Dosen Pengajar'];
      case _ProdiPageEnum.presensi: return ['Beranda', 'Akademik', 'Presensi Kuliah'];
      default: return ['Beranda', 'Dashboard'];
    }
  }

  Widget _buildNavBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              NavItem(label: 'Beranda', isActive: _activePage == _ProdiPageEnum.beranda, onTap: () => _goTo(_ProdiPageEnum.beranda)),
              NavDropdownItem(
                label: 'Akademik',
                isOpen: _openDropdown == 'akademik',
                isActive: _activePage != _ProdiPageEnum.beranda,
                onTap: () => _toggle('akademik'),
              ),
            ],
          ),
          if (_openDropdown == 'akademik')
            DropdownPanel(
              title: 'Akademik',
              items: [
                DropdownOption(icon: Icons.groups_rounded, title: 'Mahasiswa', subtitle: 'Data mahasiswa prodi', onTap: () => _goTo(_ProdiPageEnum.mahasiswa)),
                DropdownOption(icon: Icons.library_books_rounded, title: 'Mata Kuliah', subtitle: 'Manajemen kurikulum', onTap: () => _goTo(_ProdiPageEnum.matkul)),
                DropdownOption(icon: Icons.class_rounded, title: 'Kelas Kuliah', subtitle: 'Jadwal & pembagian kelas', onTap: () => _goTo(_ProdiPageEnum.kelas)),
                DropdownOption(icon: Icons.meeting_room_rounded, title: 'Ruangan', subtitle: 'Kelola ruangan', onTap: () => _goTo(_ProdiPageEnum.ruangan)),
                DropdownOption(icon: Icons.co_present_rounded, title: 'Dosen Pengajar', subtitle: 'Kelola pengajar', onTap: () => _goTo(_ProdiPageEnum.dosenPengajar)),
                DropdownOption(icon: Icons.fingerprint_rounded, title: 'Presensi Kuliah', subtitle: 'Kelola kehadiran kelas', onTap: () => _goTo(_ProdiPageEnum.presensi)),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _AdminProdiDashboard(),
      const ProdiMahasiswaPage(),
      const MataKuliahPage(),
      const KelasKuliahPage(),
      const RuanganPage(),
      const DosenPengajarPage(),
    ];

    Widget content;
    switch (_activePage) {
      case _ProdiPageEnum.mahasiswa: content = pages[1]; break;
      case _ProdiPageEnum.matkul: content = pages[2]; break;
      case _ProdiPageEnum.kelas: content = pages[3]; break;
      case _ProdiPageEnum.ruangan: content = pages[4]; break;
      case _ProdiPageEnum.dosenPengajar: content = pages[5]; break;
      case _ProdiPageEnum.presensi: content = const PresensiPage(role: 'admin_prodi'); break;
      default: content = pages[0]; break;
    }

    return CyberScaffold(
      userName: 'Admin ${AppData.currentAdminProdiKode}',
      userRole: 'admin_prodi',
      breadcrumbs: _breadcrumbs,
      child: Column(
        children: [
          _buildNavBar(),
          Expanded(child: content),
        ],
      ),
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
          const SizedBox(height: 16),
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
