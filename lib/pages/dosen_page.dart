import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'input_nilai_page.dart';
import 'validasi_krs_page.dart';

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  int _selectedIndex = 0;
  List<String> _breadcrumbs = const ['Beranda', 'Dashboard Dosen'];

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final namaDosen = AppData.currentDosenNama;
    final prodiDosen = AppData.currentDosenProdi;
    final kelasDosen = akademik.kelasDosenAktif();
    final semuaNilai = akademik.nilaiDosenAktif();
    final belumInput = akademik.nilaiBelumInputDosenAktif();
    final progressInput = akademik.progresInputNilaiDosenAktif();
    final rataRata = akademik.rataRataNilaiDosenAktif();

    final List<Widget> pages = [
      _DosenDashboard(
        namaDosen: namaDosen,
        prodiDosen: prodiDosen,
        kelasDosen: kelasDosen,
        semuaNilai: semuaNilai,
        belumInput: belumInput,
        progressInput: progressInput,
        rataRata: rataRata,
      ),
      const InputNilaiPage(),
      const ValidasiKrsPage(),
    ];

    return CyberScaffold(
      userName: namaDosen,
      userRole: 'dosen',
      breadcrumbs: _breadcrumbs,
      sidebarItems: const [
        SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        SidebarItem(icon: Icons.edit_note_rounded, label: 'Input Nilai'),
        SidebarItem(icon: Icons.fact_check_rounded, label: 'Validasi KRS'),
        SidebarItem(icon: Icons.settings_rounded, label: 'Settings'),
      ],
      selectedIndex: _selectedIndex,
      onItemSelected: (i) {
        if (i < pages.length) {
          setState(() {
            _selectedIndex = i;
            if (i == 0) _breadcrumbs = const ['Beranda', 'Dashboard Dosen'];
            if (i == 1) _breadcrumbs = const ['Beranda', 'Akademik', 'Input Nilai'];
            if (i == 2) _breadcrumbs = const ['Beranda', 'Akademik', 'Validasi KRS'];
          });
        }
      },
      child: pages[_selectedIndex < pages.length ? _selectedIndex : 0],
    );
  }
}

class _DosenDashboard extends StatelessWidget {
  final String namaDosen;
  final String prodiDosen;
  final List<dynamic> kelasDosen;
  final List<dynamic> semuaNilai;
  final int belumInput;
  final double progressInput;
  final double rataRata;

  const _DosenDashboard({
    required this.namaDosen,
    required this.prodiDosen,
    required this.kelasDosen,
    required this.semuaNilai,
    required this.belumInput,
    required this.progressInput,
    required this.rataRata,
  });

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Hi, $namaDosen!',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                  Text('NIDN: ${AppData.currentDosenNidn} - Prodi $prodiDosen', style: const TextStyle(color: AppColors.textSecondary)),
                ],
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
                      const Text('Kelas Diampu', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('${kelasDosen.length}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                      Text('${semuaNilai.length} Mahasiswa total', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                      const Text('Rata-rata Nilai', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(rataRata == 0 ? '-' : rataRata.toStringAsFixed(1), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.accent)),
                      const Text('IPK Semester ini', style: TextStyle(fontSize: 12, color: Colors.white54)),
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
                const Text('Progress Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Progress Input Nilai',
                  value: '${(progressInput * 100).round()}%',
                  progress: progressInput,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Nilai Belum Diinput',
                  value: '$belumInput / ${semuaNilai.length}',
                  progress: semuaNilai.isEmpty ? 0 : belumInput / semuaNilai.length,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Daftar Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...kelasDosen.map((kelas) {
            final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
            final peserta = const AkademikService().pesertaKelas(kelas.id);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ExpansionTile(
                leading: const CircleAvatar(backgroundColor: AppColors.bg, child: Icon(Icons.class_, color: AppColors.primary)),
                title: Text(mk.namaMataKuliah, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                subtitle: Text('Kelas ${kelas.namaKelas} • ${peserta.length} / ${kelas.kapasitas} Mhs', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: peserta.map((m) => ListTile(
                        leading: const Icon(Icons.person_outline, size: 18),
                        title: Text(m.namaLengkap, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                        subtitle: Text('NIM: ${m.nim}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        dense: true,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
