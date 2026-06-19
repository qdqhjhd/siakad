import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class PimpinanUnivPage extends StatefulWidget {
  const PimpinanUnivPage({super.key});

  @override
  State<PimpinanUnivPage> createState() => _PimpinanUnivPageState();
}

class _PimpinanUnivPageState extends State<PimpinanUnivPage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String? _selectedProdiCode;
  String? _selectedSemesterId;

  List<SidebarItem> get _sidebarItems => const [
        SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        SidebarItem(icon: Icons.school_rounded, label: 'Data Mahasiswa'),
        SidebarItem(icon: Icons.people_alt_rounded, label: 'Data Dosen'),
        SidebarItem(icon: Icons.library_books_rounded, label: 'Mata Kuliah'),
        SidebarItem(icon: Icons.class_rounded, label: 'Kelas Kuliah'),
        SidebarItem(icon: Icons.room_rounded, label: 'Ruangan'),
        SidebarItem(icon: Icons.person_pin_rounded, label: 'Dosen Pengajar'),
        SidebarItem(icon: Icons.calendar_today_rounded, label: 'Jadwal Kuliah'),
        SidebarItem(icon: Icons.date_range_rounded, label: 'Jadwal KRS'),
        SidebarItem(icon: Icons.fact_check_rounded, label: 'Data KRS'),
        SidebarItem(icon: Icons.how_to_reg_rounded, label: 'Presensi Mahasiswa'),
        SidebarItem(icon: Icons.co_present_rounded, label: 'Presensi Dosen'),
        SidebarItem(icon: Icons.assessment_rounded, label: 'Laporan Akademik'),
      ];

  List<String> get _breadcrumbs {
    switch (_selectedIndex) {
      case 0: return ['Pimpinan', 'Dashboard'];
      case 1: return ['Pimpinan', 'Data Mahasiswa'];
      case 2: return ['Pimpinan', 'Data Dosen'];
      case 3: return ['Pimpinan', 'Mata Kuliah'];
      case 4: return ['Pimpinan', 'Kelas Kuliah'];
      case 5: return ['Pimpinan', 'Ruangan'];
      case 6: return ['Pimpinan', 'Dosen Pengajar'];
      case 7: return ['Pimpinan', 'Jadwal Kuliah'];
      case 8: return ['Pimpinan', 'Jadwal KRS'];
      case 9: return ['Pimpinan', 'Data KRS'];
      case 10: return ['Pimpinan', 'Presensi Mahasiswa'];
      case 11: return ['Pimpinan', 'Presensi Dosen'];
      case 12: return ['Pimpinan', 'Laporan Akademik'];
      default: return ['Pimpinan', 'Dashboard'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      userName: 'Prof. Dr. Ir. Rektor, M.Si.',
      userRole: 'pimpinan_univ',
      sidebarItems: _sidebarItems,
      selectedIndex: _selectedIndex,
      breadcrumbs: _breadcrumbs,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
          _searchQuery = ''; // Reset search query on tab change
        });
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildMahasiswaContent();
      case 2:
        return _buildDosenContent();
      case 3:
        return _buildMataKuliahContent();
      case 4:
        return _buildKelasKuliahContent();
      case 5:
        return _buildRuanganContent();
      case 6:
        return _buildDosenPengajarContent();
      case 7:
        return _buildJadwalKuliahContent();
      case 8:
        return _buildJadwalKrsContent();
      case 9:
        return _buildDataKrsContent();
      case 10:
        return _buildPresensiMahasiswaContent();
      case 11:
        return _buildPresensiDosenContent();
      case 12:
        return _buildLaporanContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    var students = AppData.daftarMahasiswa;
    if (_selectedProdiCode != null) {
      students = students.where((m) => m.kodeProdi == _selectedProdiCode).toList();
    }
    final totalMhs = students.length;
    final aktifMhs = students.where((m) => m.isAktif).length;
    final tidakAktifMhs = totalMhs - aktifMhs;

    var dosens = AppData.daftarDosen;
    if (_selectedProdiCode != null) {
      dosens = dosens.where((d) => d.kodeProdi == _selectedProdiCode).toList();
    }
    final totalDosen = dosens.length;

    var courses = AppData.daftarMataKuliah;
    if (_selectedProdiCode != null) {
      courses = courses.where((mk) => mk.kodeProdi == _selectedProdiCode).toList();
    }
    final totalMk = courses.length;

    var classes = AppData.daftarKelas;
    if (_selectedProdiCode != null) {
      classes = classes.where((k) => k.kodeProdi == _selectedProdiCode).toList();
    }
    final totalKelas = classes.length;
    final totalRuangan = AppData.daftarRuangan.length;

    var krsList = AppData.daftarKrs;
    if (_selectedProdiCode != null) {
      final studentNims = students.map((m) => m.nim).toSet();
      krsList = krsList.where((k) => studentNims.contains(k.nim)).toList();
    }
    if (_selectedSemesterId != null) {
      krsList = krsList.where((k) {
        final kelas = AppData.daftarKelas.firstWhere((c) => c.id == k.idKelasKuliah, orElse: () => AppData.daftarKelas.first);
        return kelas.kodeProdi.contains(_selectedSemesterId!);
      }).toList();
    }
    
    final draftKrs = krsList.where((k) => k.statusKrs == 'draft').length;
    final pendingKrs = krsList.where((k) => k.statusKrs == 'pending').length;
    final validKrs = krsList.where((k) => k.statusKrs == 'valid').length;
    final rejectedKrs = krsList.where((k) {
      final mhs = AppData.daftarMahasiswa.firstWhere((m) => m.nim == k.nim, orElse: () => AppData.daftarMahasiswa.first);
      return mhs.catatanKrs != null && k.statusKrs == 'draft';
    }).length;

    final classIds = classes.map((c) => c.id).toSet();
    var meetings = AppData.daftarPertemuanKuliah.where((p) => classIds.contains(p.idKelasKuliah)).toList();
    final meetingIds = meetings.map((p) => p.id).toSet();
    
    final studentPresences = AppData.daftarPresensiMahasiswa.where((pm) => meetingIds.contains(pm.idPertemuan)).toList();
    final totalStudPresences = studentPresences.length;
    final presentStudCount = studentPresences.where((pm) => pm.status == 'Hadir').length;
    final permitStudCount = studentPresences.where((pm) => pm.status == 'Izin').length;
    final sickStudCount = studentPresences.where((pm) => pm.status == 'Sakit').length;
    final absentStudCount = studentPresences.where((pm) => pm.status == 'Alfa').length;
    
    final double presencePercentageStud = totalStudPresences > 0 ? (presentStudCount / totalStudPresences) : 1.0;

    final dosenPresences = AppData.daftarPresensiDosen.where((pd) => meetingIds.contains(pd.idPertemuan)).toList();
    final totalDosenPresences = dosenPresences.length;
    final presentDosenCount = dosenPresences.where((pd) => pd.status == 'Hadir').length;
    final double presencePercentageDosen = totalDosenPresences > 0 ? (presentDosenCount / totalDosenPresences) : 1.0;

    final activeJadwal = AppData.daftarJadwalKrs.firstWhere((j) => j.status == 'Aktif', orElse: () => AppData.daftarJadwalKrs.first);

    final chartValues = AppData.daftarProdi.map((prodi) {
      final count = AppData.daftarMahasiswa.where((m) => m.kodeProdi == prodi.kodeProdi).length;
      final colors = [
        const Color(0xFF3B82F6),
        const Color(0xFF10B981),
        const Color(0xFFF59E0B),
        const Color(0xFFEC4899),
      ];
      final color = colors[AppData.daftarProdi.indexOf(prodi) % colors.length];
      return ChartValue(
        label: prodi.aliasProdi,
        value: count.toDouble(),
        color: color,
      );
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CyberHeader(
            tag: 'ANALITIKA UNIVERSITAS',
            title: 'Sistem Informasi Eksekutif (Pimpinan)',
            subtitle: 'Pemantauan analitik real-time terhadap kinerja akademik, status KRS, presensi kelas, dan jadwal universitas.',
            icon: Icons.query_stats_rounded,
          ),
          const SizedBox(height: 16),

          // FILTERS ROW
          CyberPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Filter Dashboard:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProdiCode,
                    decoration: const InputDecoration(labelText: 'Program Studi', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Program Studi')),
                      ...AppData.daftarProdi.map((p) => DropdownMenuItem(value: p.kodeProdi, child: Text(p.namaProdi))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedProdiCode = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSemesterId,
                    decoration: const InputDecoration(labelText: 'Tahun Akademik / Semester', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Semua Semester')),
                      DropdownMenuItem(value: 'ILKOM', child: Text('2024/2025 - Ganjil')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedSemesterId = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '$totalMhs',
                  label: 'Total Mahasiswa',
                  color: AppColors.primary,
                  icon: Icons.school_rounded,
                  progress: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  value: '$totalDosen',
                  label: 'Total Dosen',
                  color: Colors.orange,
                  icon: Icons.person_search_rounded,
                  progress: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  value: '$totalMk',
                  label: 'Mata Kuliah',
                  color: Colors.teal,
                  icon: Icons.library_books_rounded,
                  progress: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  value: '$totalKelas',
                  label: 'Kelas Kuliah',
                  color: Colors.purple,
                  icon: Icons.class_rounded,
                  progress: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: CyberPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Status KRS Mahasiswa',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  const Text('DRAFT', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('$draftKrs', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  const Text('PENDING', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('$pendingKrs', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  const Text('APPROVED', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('$validKrs', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  const Text('REJECTED', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('$rejectedKrs', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.error)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: CyberPanel(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jadwal Registrasi KRS', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: activeJadwal.status == 'Aktif' ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activeJadwal.status,
                              style: TextStyle(color: activeJadwal.status == 'Aktif' ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tahun Akademik: ${activeJadwal.tahunAkademik} (${activeJadwal.semester})',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Periode: ${activeJadwal.tanggalMulai.day}/${activeJadwal.tanggalMulai.month}/${activeJadwal.tanggalMulai.year} - ${activeJadwal.tanggalSelesai.day}/${activeJadwal.tanggalSelesai.month}/${activeJadwal.tanggalSelesai.year}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Sisa Waktu Pengisian: ${activeJadwal.sisaHari} Hari lagi',
                            style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CyberPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Analitik Kehadiran Perkuliahan (Presensi)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _AttendanceBar(
                            label: 'Presensi Mahasiswa',
                            percent: presencePercentageStud,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 10),
                          _AttendanceBar(
                            label: 'Presensi Dosen',
                            percent: presencePercentageDosen,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(child: _MiniStatusStat('Hadir', '$presentStudCount', AppColors.success)),
                          const SizedBox(width: 6),
                          Expanded(child: _MiniStatusStat('Izin', '$permitStudCount', AppColors.primary)),
                          const SizedBox(width: 6),
                          Expanded(child: _MiniStatusStat('Sakit', '$sickStudCount', AppColors.warning)),
                          const SizedBox(width: 6),
                          Expanded(child: _MiniStatusStat('Alfa', '$absentStudCount', AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: MiniBarChart(
                  title: 'Distribusi Mahasiswa per Program Studi',
                  values: chartValues,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: CyberPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Keaktifan',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProgressMetric(
                        label: 'Persentase Mahasiswa Aktif',
                        value: '$aktifMhs / $totalMhs Mhs',
                        progress: totalMhs > 0 ? aktifMhs / totalMhs : 0.0,
                        color: Colors.green,
                      ),
                      const Divider(height: 32, color: AppColors.border),
                      ProgressMetric(
                        label: 'Persentase Mahasiswa Inaktif',
                        value: '$tidakAktifMhs / $totalMhs Mhs',
                        progress: totalMhs > 0 ? tidakAktifMhs / totalMhs : 0.0,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMahasiswaContent() {
    final filtered = AppData.daftarMahasiswa.where((m) {
      final q = _searchQuery.toLowerCase();
      final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == m.kodeProdi);
      return m.namaLengkap.toLowerCase().contains(q) ||
          m.nim.toLowerCase().contains(q) ||
          prodi.namaProdi.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Pemantauan Data Mahasiswa',
          subtitle: 'Lihat status keaktifan dan detail seluruh mahasiswa secara keseluruhan.',
          icon: Icons.school_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari nama, NIM, atau program studi...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ditemukan data mahasiswa yang cocok',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == m.kodeProdi);
                    final dosen = AppData.daftarDosen.firstWhere(
                      (d) => d.nidn == m.dosenPembimbingNidn,
                      orElse: () => AppData.daftarDosen.first,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                m.namaLengkap[0],
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        m.namaLengkap,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: m.isAktif ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: m.isAktif ? Colors.green : Colors.red,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          m.isAktif ? 'Aktif' : 'Tidak Aktif',
                                          style: TextStyle(
                                            color: m.isAktif ? Colors.green : Colors.red,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NIM: ${m.nim} • Prodi: ${prodi.namaProdi} • Angkatan: ${m.angkatan}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dosen PA: ${dosen.nama} (${dosen.nidn})',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDosenContent() {
    final filtered = AppData.daftarDosen.where((d) {
      final q = _searchQuery.toLowerCase();
      final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == d.kodeProdi);
      return d.nama.toLowerCase().contains(q) ||
          d.nidn.toLowerCase().contains(q) ||
          prodi.namaProdi.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Pemantauan Data Dosen Wali (PA)',
          subtitle: 'Lihat daftar dosen beserta program studi pengajaran.',
          icon: Icons.people_alt_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari nama, NIDN, atau prodi dosen...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada data dosen wali', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == d.kodeProdi);
                    final bimbinganCount = AppData.daftarMahasiswa.where((m) => m.dosenPembimbingNidn == d.nidn).length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange.withValues(alpha: 0.1),
                              child: const Icon(Icons.person, color: Colors.orange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.nama,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NIDN: ${d.nidn} • Prodi: ${prodi.namaProdi}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Jumlah Mahasiswa Bimbingan: $bimbinganCount',
                                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMataKuliahContent() {
    var list = AppData.daftarMataKuliah;
    if (_selectedProdiCode != null) {
      list = list.where((mk) => mk.kodeProdi == _selectedProdiCode).toList();
    }
    final filtered = list.where((mk) {
      final q = _searchQuery.toLowerCase();
      return mk.namaMataKuliah.toLowerCase().contains(q) || mk.kodeMataKuliah.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Daftar Mata Kuliah',
          subtitle: 'Daftar kurikulum mata kuliah yang tersedia di universitas.',
          icon: Icons.library_books_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari kode atau nama mata kuliah...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada mata kuliah', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final mk = filtered[index];
                    final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == mk.kodeProdi, orElse: () => AppData.daftarProdi.first);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.book, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mk.namaMataKuliah,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kode: ${mk.kodeMataKuliah} • SKS: ${mk.jumlahSks} • Prodi: ${prodi.namaProdi}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildKelasKuliahContent() {
    var list = AppData.daftarKelas;
    if (_selectedProdiCode != null) {
      list = list.where((k) => k.kodeProdi == _selectedProdiCode).toList();
    }
    final filtered = list.where((k) {
      final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == k.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
      final q = _searchQuery.toLowerCase();
      return k.namaKelas.toLowerCase().contains(q) || mk.namaMataKuliah.toLowerCase().contains(q) || k.dosenPengampu.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Daftar Kelas Kuliah',
          subtitle: 'Daftar seluruh kelas perkuliahan aktif beserta dosen pengampu.',
          icon: Icons.class_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari kelas, mata kuliah, atau dosen...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada kelas kuliah', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final kelas = filtered[index];
                    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
                    final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == kelas.kodeProdi, orElse: () => AppData.daftarProdi.first);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kelas ${kelas.namaKelas} (${kelas.id})',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    prodi.aliasProdi,
                                    style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mk.namaMataKuliah,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dosen: ${kelas.dosenPengampu}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              'Jadwal: ${kelas.hari}, ${kelas.jamMulai} - ${kelas.jamSelesai} (Ruang ${kelas.ruangan})',
                              style: const TextStyle(color: AppColors.grey, fontSize: 12),
                            ),
                            Text(
                              'Kapasitas: ${kelas.kapasitas} Mahasiswa',
                              style: const TextStyle(color: AppColors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRuanganContent() {
    final list = AppData.daftarRuangan;
    final filtered = list.where((r) {
      final q = _searchQuery.toLowerCase();
      return r.kodeRuangan.toLowerCase().contains(q) || r.namaRuangan.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Informasi Ruangan',
          subtitle: 'Daftar kapasitas dan lokasi ruangan perkuliahan.',
          icon: Icons.room_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari kode atau nama ruangan...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada ruangan', style: TextStyle(color: AppColors.textSecondary)))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return CyberPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.meeting_room, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.namaRuangan,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Kode: ${r.kodeRuangan}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Kapasitas: ${r.kapasitasRuangan} Kursi', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDosenPengajarContent() {
    var list = AppData.daftarDosenPengajar;
    if (_selectedProdiCode != null) {
      list = list.where((dp) {
        final dosen = AppData.daftarDosen.firstWhere((d) => d.nidn == dp.nidnDosen, orElse: () => AppData.daftarDosen.first);
        return dosen.kodeProdi == _selectedProdiCode;
      }).toList();
    }
    final filtered = list.where((dp) {
      final dosen = AppData.daftarDosen.firstWhere((d) => d.nidn == dp.nidnDosen, orElse: () => AppData.daftarDosen.first);
      final kelas = AppData.daftarKelas.firstWhere((k) => k.id == dp.idKelas, orElse: () => AppData.daftarKelas.first);
      final q = _searchQuery.toLowerCase();
      return dosen.nama.toLowerCase().contains(q) || dp.nidnDosen.toLowerCase().contains(q) || kelas.namaKelas.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Dosen Pengajar Kelas',
          subtitle: 'Daftar dosen yang ditugaskan mengajar kelas-kelas perkuliahan.',
          icon: Icons.person_pin_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari nama dosen, NIDN, atau kelas...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada data dosen pengajar', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final dp = filtered[index];
                    final dosen = AppData.daftarDosen.firstWhere((d) => d.nidn == dp.nidnDosen, orElse: () => AppData.daftarDosen.first);
                    final kelas = AppData.daftarKelas.firstWhere((k) => k.id == dp.idKelas, orElse: () => AppData.daftarKelas.first);
                    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange.withValues(alpha: 0.1),
                              child: const Icon(Icons.assignment_ind, color: Colors.orange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dosen.nama,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kelas: ${kelas.namaKelas} • MK: ${mk.namaMataKuliah} (${mk.kodeMataKuliah})',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  Text(
                                    'Peran: ${dp.peranMengajar} • NIDN: ${dosen.nidn}',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJadwalKuliahContent() {
    var list = AppData.daftarKelas;
    if (_selectedProdiCode != null) {
      list = list.where((k) => k.kodeProdi == _selectedProdiCode).toList();
    }
    final filtered = list.where((k) {
      final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == k.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
      final q = _searchQuery.toLowerCase();
      return k.hari.toLowerCase().contains(q) || mk.namaMataKuliah.toLowerCase().contains(q) || k.dosenPengampu.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Jadwal Kuliah',
          subtitle: 'Jadwal pelaksanaan kuliah harian mahasiswa.',
          icon: Icons.calendar_today_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari hari, mata kuliah, atau dosen...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada jadwal kuliah', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final k = filtered[index];
                    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == k.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(k.hari, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(k.jamMulai, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mk.namaMataKuliah,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kelas ${k.namaKelas} • Ruang ${k.ruangan}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  Text(
                                    'Dosen: ${k.dosenPengampu}',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJadwalKrsContent() {
    final list = AppData.daftarJadwalKrs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Periode Jadwal KRS',
          subtitle: 'Periode pengisian kartu rencana studi mahasiswa.',
          icon: Icons.date_range_rounded,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Tidak ada jadwal KRS', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final j = list[index];
                    final isAktif = j.status == 'Aktif';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (isAktif ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                              child: Icon(Icons.date_range, color: isAktif ? AppColors.success : AppColors.error),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Tahun Akademik: ${j.tahunAkademik}',
                                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isAktif ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          j.status,
                                          style: TextStyle(color: isAktif ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Semester: ${j.semester} • Periode: ${j.tanggalMulai.day}/${j.tanggalMulai.month}/${j.tanggalMulai.year} - ${j.tanggalSelesai.day}/${j.tanggalSelesai.month}/${j.tanggalSelesai.year}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  Text(
                                    'Sisa Waktu: ${j.sisaHari} Hari',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDataKrsContent() {
    var students = AppData.daftarMahasiswa;
    if (_selectedProdiCode != null) {
      students = students.where((m) => m.kodeProdi == _selectedProdiCode).toList();
    }
    final filtered = students.where((m) {
      final q = _searchQuery.toLowerCase();
      return m.namaLengkap.toLowerCase().contains(q) || m.nim.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Database',
          title: 'Status KRS Mahasiswa',
          subtitle: 'Daftar pengajuan KRS mahasiswa beserta status validasi pembimbing akademik.',
          icon: Icons.fact_check_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari nama atau NIM mahasiswa...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada mahasiswa', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final mhs = filtered[index];
                    final krs = AppData.daftarKrs.where((k) => k.nim == mhs.nim).toList();
                    
                    String overallStatus = 'Belum Mengajukan';
                    Color statusColor = AppColors.grey;
                    if (krs.isNotEmpty) {
                      final allValid = krs.every((k) => k.statusKrs == 'valid');
                      final hasPending = krs.any((k) => k.statusKrs == 'pending');
                      if (allValid) {
                        overallStatus = 'Approved';
                        statusColor = AppColors.success;
                      } else if (hasPending) {
                        overallStatus = 'Pending';
                        statusColor = Colors.orange;
                      } else {
                        overallStatus = 'Draft / Rejected';
                        statusColor = AppColors.error;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(side: BorderSide.none),
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(mhs.namaLengkap, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                    Text('NIM: ${mhs.nim}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  overallStatus,
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (krs.isEmpty)
                                    const Text('Belum ada kelas yang dipilih.', style: TextStyle(color: AppColors.grey, fontSize: 13))
                                  else ...[
                                    const Text('Mata Kuliah Diambil:', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    ...krs.map((k) {
                                      final kelas = AppData.daftarKelas.firstWhere((c) => c.id == k.idKelasKuliah, orElse: () => AppData.daftarKelas.first);
                                      final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle, size: 6, color: AppColors.primary),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${mk.namaMataKuliah} (Kelas ${kelas.namaKelas}) - ${k.statusKrs.toUpperCase()}',
                                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                  if (mhs.catatanKrs != null && mhs.catatanKrs!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Catatan Penolakan: ${mhs.catatanKrs}',
                                      style: const TextStyle(color: AppColors.error, fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPresensiMahasiswaContent() {
    var students = AppData.daftarMahasiswa;
    if (_selectedProdiCode != null) {
      students = students.where((m) => m.kodeProdi == _selectedProdiCode).toList();
    }
    final filtered = students.where((m) {
      final q = _searchQuery.toLowerCase();
      return m.namaLengkap.toLowerCase().contains(q) || m.nim.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Presensi',
          title: 'Rekap Presensi Mahasiswa',
          subtitle: 'Persentase kehadiran dan status detil presensi mahasiswa.',
          icon: Icons.how_to_reg_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari nama atau NIM mahasiswa...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada data presensi mahasiswa', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final mhs = filtered[index];
                    
                    final mhsPresences = AppData.daftarPresensiMahasiswa.where((p) => p.nim == mhs.nim).toList();
                    final total = mhsPresences.length;
                    final hadir = mhsPresences.where((p) => p.status == 'Hadir').length;
                    final izin = mhsPresences.where((p) => p.status == 'Izin').length;
                    final sakit = mhsPresences.where((p) => p.status == 'Sakit').length;
                    final alfa = mhsPresences.where((p) => p.status == 'Alfa').length;
                    
                    final pct = total > 0 ? hadir / total : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(mhs.namaLengkap[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mhs.namaLengkap, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('NIM: ${mhs.nim}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _buildPresenceBadge('Hadir: $hadir', AppColors.success),
                                      const SizedBox(width: 6),
                                      _buildPresenceBadge('Izin: $izin', AppColors.primary),
                                      const SizedBox(width: 6),
                                      _buildPresenceBadge('Sakit: $sakit', AppColors.warning),
                                      const SizedBox(width: 6),
                                      _buildPresenceBadge('Alfa: $alfa', AppColors.error),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(pct * 100).toInt()}%',
                                  style: TextStyle(
                                    color: pct >= 0.8 ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text('Kehadiran', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPresenceBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPresensiDosenContent() {
    var dosens = AppData.daftarDosen;
    if (_selectedProdiCode != null) {
      dosens = dosens.where((d) => d.kodeProdi == _selectedProdiCode).toList();
    }
    final filtered = dosens.where((d) {
      final q = _searchQuery.toLowerCase();
      return d.nama.toLowerCase().contains(q) || d.nidn.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'Presensi',
          title: 'Rekap Kehadiran Dosen',
          subtitle: 'Persentase mengajar dan status kehadiran dosen pengampu.',
          icon: Icons.co_present_rounded,
        ),
        const SizedBox(height: 20),
        _buildSearchField('Cari nama atau NIDN dosen...'),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada data presensi dosen', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final dosen = filtered[index];
                    
                    final dosenPresences = AppData.daftarPresensiDosen.where((p) => p.nidn == dosen.nidn).toList();
                    final total = dosenPresences.length;
                    final hadir = dosenPresences.where((p) => p.status == 'Hadir').length;
                    final absen = total - hadir;
                    final pct = total > 0 ? hadir / total : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange.withValues(alpha: 0.1),
                              child: const Icon(Icons.person, color: Colors.orange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dosen.nama, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('NIDN: ${dosen.nidn}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _buildPresenceBadge('Sesi Mengajar: $total', AppColors.primary),
                                      const SizedBox(width: 8),
                                      _buildPresenceBadge('Hadir: $hadir', AppColors.success),
                                      const SizedBox(width: 8),
                                      _buildPresenceBadge('Absen: $absen', AppColors.error),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(pct * 100).toInt()}%',
                                  style: TextStyle(
                                    color: pct >= 0.8 ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text('Kehadiran', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLaporanContent() {
    final totalMhs = AppData.daftarMahasiswa.length;
    final totalDosen = AppData.daftarDosen.length;
    final totalKelas = AppData.daftarKelas.length;
    final totalMeetings = AppData.daftarPertemuanKuliah.length;
    
    final mhsPres = AppData.daftarPresensiMahasiswa;
    final hadirPct = mhsPres.isEmpty ? 0.0 : mhsPres.where((p) => p.status == 'Hadir').length / mhsPres.length;
    
    final dosenPres = AppData.daftarPresensiDosen;
    final dosenHadirPct = dosenPres.isEmpty ? 0.0 : dosenPres.where((p) => p.status == 'Hadir').length / dosenPres.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CyberHeader(
            tag: 'Laporan',
            title: 'Laporan Akademik & Presensi',
            subtitle: 'Ringkasan formal kinerja akademik universitas.',
            icon: Icons.assessment_rounded,
          ),
          const SizedBox(height: 16),
          CyberPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LAPORAN EKSEKUTIF AKADEMIK',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('STATUS: FINAL', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const Divider(height: 24),
                _buildReportRow('Total Mahasiswa Terdaftar', '$totalMhs Orang'),
                _buildReportRow('Total Dosen Pengampu', '$totalDosen Orang'),
                _buildReportRow('Total Kelas Perkuliahan', '$totalKelas Kelas'),
                _buildReportRow('Total Sesi Pertemuan Kuliah', '$totalMeetings Sesi'),
                const Divider(height: 24),
                _buildReportRow('Persentase Kehadiran Rata-Rata Mahasiswa', '${(hadirPct * 100).toStringAsFixed(1)}%'),
                _buildReportRow('Persentase Kehadiran Rata-Rata Dosen', '${(dosenHadirPct * 100).toStringAsFixed(1)}%'),
                const Divider(height: 24),
                const SizedBox(height: 8),
                const Text(
                  'Catatan Laporan:',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  '1. Laporan ini di-generate secara real-time dari database akademik.\n'
                  '2. Seluruh data di atas bersifat rahasia dan hanya dapat diakses oleh pemegang peran Pimpinan.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Laporan berhasil diunduh (Simulasi PDF)')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Unduh Laporan PDF'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSearchField(String hintText) {
    return TextField(
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.grey),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
    );
  }

  Widget _MiniStatusStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(bottom: BorderSide(color: color, width: 2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AttendanceBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _AttendanceBar({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (percent.clamp(0.0, 1.0) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$pct%', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
