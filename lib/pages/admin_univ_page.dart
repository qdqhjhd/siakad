import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import 'admin_dosen_page.dart';
import 'kelas_kuliah_page.dart';
import 'mata_kuliah_page.dart';
import 'prodi_page.dart';
import 'admin_mahasiswa_page.dart';
import 'ruangan_page.dart';
import 'dosen_pengajar_page.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import '../widgets/topbar_nav.dart';
import 'presensi_page.dart';

class AdminUnivPage extends StatefulWidget {
  const AdminUnivPage({super.key});

  @override
  State<AdminUnivPage> createState() => _AdminUnivPageState();
}

enum _UnivPageEnum { beranda, prodi, mahasiswa, dosen, matkul, kelas, ruangan, dosenPengajar, presensi }

class _AdminUnivPageState extends State<AdminUnivPage> {
  _UnivPageEnum _activePage = _UnivPageEnum.beranda;
  String? _openDropdown;

  void _goTo(_UnivPageEnum page) => setState(() { _activePage = page; _openDropdown = null; });
  void _toggle(String key) => setState(() => _openDropdown = _openDropdown == key ? null : key);

  List<String> get _breadcrumbs {
    switch (_activePage) {
      case _UnivPageEnum.prodi: return ['Beranda', 'Master Data', 'Prodi'];
      case _UnivPageEnum.dosen: return ['Beranda', 'Master Data', 'Dosen'];
      case _UnivPageEnum.mahasiswa: return ['Beranda', 'Akademik', 'Mahasiswa'];
      case _UnivPageEnum.matkul: return ['Beranda', 'Akademik', 'Mata Kuliah'];
      case _UnivPageEnum.kelas: return ['Beranda', 'Akademik', 'Kelas Kuliah'];
      case _UnivPageEnum.ruangan: return ['Beranda', 'Akademik', 'Ruangan'];
      case _UnivPageEnum.dosenPengajar: return ['Beranda', 'Akademik', 'Dosen Pengajar'];
      case _UnivPageEnum.presensi: return ['Beranda', 'Akademik', 'Presensi Kuliah'];
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
              NavItem(label: 'Beranda', isActive: _activePage == _UnivPageEnum.beranda, onTap: () => _goTo(_UnivPageEnum.beranda)),
              NavDropdownItem(
                label: 'Master Data',
                isOpen: _openDropdown == 'master',
                isActive: _activePage == _UnivPageEnum.prodi || _activePage == _UnivPageEnum.dosen,
                onTap: () => _toggle('master'),
              ),
              NavDropdownItem(
                label: 'Akademik',
                isOpen: _openDropdown == 'akademik',
                isActive: _activePage != _UnivPageEnum.beranda && _activePage != _UnivPageEnum.prodi && _activePage != _UnivPageEnum.dosen,
                onTap: () => _toggle('akademik'),
              ),
            ],
          ),
          if (_openDropdown == 'master')
            DropdownPanel(
              title: 'Master Data',
              items: [
                DropdownOption(icon: Icons.school_rounded, title: 'Prodi', subtitle: 'Manajemen program studi', onTap: () => _goTo(_UnivPageEnum.prodi)),
                DropdownOption(icon: Icons.person_search_rounded, title: 'Dosen', subtitle: 'Data induk dosen', onTap: () => _goTo(_UnivPageEnum.dosen)),
              ],
            ),
          if (_openDropdown == 'akademik')
            DropdownPanel(
              title: 'Akademik',
              items: [
                DropdownOption(icon: Icons.people_rounded, title: 'Mahasiswa', subtitle: 'Data seluruh mahasiswa', onTap: () => _goTo(_UnivPageEnum.mahasiswa)),
                DropdownOption(icon: Icons.library_books_rounded, title: 'Mata Kuliah', subtitle: 'Manajemen kurikulum universitas', onTap: () => _goTo(_UnivPageEnum.matkul)),
                DropdownOption(icon: Icons.class_rounded, title: 'Kelas Kuliah', subtitle: 'Seluruh jadwal & kelas', onTap: () => _goTo(_UnivPageEnum.kelas)),
                DropdownOption(icon: Icons.meeting_room_rounded, title: 'Ruangan', subtitle: 'Manajemen fasilitas ruangan', onTap: () => _goTo(_UnivPageEnum.ruangan)),
                DropdownOption(icon: Icons.co_present_rounded, title: 'Dosen Pengajar', subtitle: 'Penugasan mengajar dosen', onTap: () => _goTo(_UnivPageEnum.dosenPengajar)),
                DropdownOption(icon: Icons.fingerprint_rounded, title: 'Presensi Kuliah', subtitle: 'Lihat seluruh rekap presensi', onTap: () => _goTo(_UnivPageEnum.presensi)),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _AdminDashboard(),
      const ProdiPage(),
      const AdminMahasiswaPage(),
      const AdminDosenPage(),
      const MataKuliahPage(),
      const KelasKuliahPage(),
      const RuanganPage(),
      const DosenPengajarPage(),
    ];

    Widget content;
    switch (_activePage) {
      case _UnivPageEnum.prodi: content = pages[1]; break;
      case _UnivPageEnum.mahasiswa: content = pages[2]; break;
      case _UnivPageEnum.dosen: content = pages[3]; break;
      case _UnivPageEnum.matkul: content = pages[4]; break;
      case _UnivPageEnum.kelas: content = pages[5]; break;
      case _UnivPageEnum.ruangan: content = pages[6]; break;
      case _UnivPageEnum.dosenPengajar: content = pages[7]; break;
      case _UnivPageEnum.presensi: content = const PresensiPage(role: 'admin_univ'); break;
      default: content = pages[0]; break;
    }

    return CyberScaffold(
      userName: 'Admin Universitas',
      userRole: 'admin_univ',
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
          const SizedBox(height: 16),
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
