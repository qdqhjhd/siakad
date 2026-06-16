import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'presensi_page.dart';

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
        SidebarItem(icon: Icons.school_rounded, label: 'Daftar Mahasiswa'),
        SidebarItem(icon: Icons.people_alt_rounded, label: 'Daftar Dosen'),
        SidebarItem(icon: Icons.fingerprint_rounded, label: 'Presensi Kuliah'),
      ];

  List<String> get _breadcrumbs {
    switch (_selectedIndex) {
      case 1:
        return ['Pimpinan', 'Mahasiswa'];
      case 2:
        return ['Pimpinan', 'Dosen'];
      case 3:
        return ['Pimpinan', 'Presensi Kuliah'];
      default:
        return ['Pimpinan', 'Dashboard'];
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
        });
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 1:
        return _buildMahasiswaContent();
      case 2:
        return _buildDosenContent();
      case 3:
        return const PresensiPage(role: 'pimpinan_univ');
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    // ─── Filtered Data Calculations ──────────────────────────────────────────
    // Get all students matching prodi filter
    var students = AppData.daftarMahasiswa;
    if (_selectedProdiCode != null) {
      students = students.where((m) => m.kodeProdi == _selectedProdiCode).toList();
    }
    final totalMhs = students.length;
    final aktifMhs = students.where((m) => m.isAktif).length;
    final tidakAktifMhs = totalMhs - aktifMhs;

    // Get all dosen matching prodi filter
    var dosens = AppData.daftarDosen;
    if (_selectedProdiCode != null) {
      dosens = dosens.where((d) => d.kodeProdi == _selectedProdiCode).toList();
    }
    final totalDosen = dosens.length;

    // Courses matching prodi filter
    var courses = AppData.daftarMataKuliah;
    if (_selectedProdiCode != null) {
      courses = courses.where((mk) => mk.kodeProdi == _selectedProdiCode).toList();
    }
    final totalMk = courses.length;

    // Classes matching prodi filter
    var classes = AppData.daftarKelas;
    if (_selectedProdiCode != null) {
      classes = classes.where((k) => k.kodeProdi == _selectedProdiCode).toList();
    }
    final totalKelas = classes.length;

    // Rooms
    final totalRuangan = AppData.daftarRuangan.length;

    // KRS Stats based on students & semester
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

    // Presensi Stats
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

    // Active Jadwal KRS
    final activeJadwal = AppData.daftarJadwalKrs.firstWhere((j) => j.status == 'Aktif', orElse: () => AppData.daftarJadwalKrs.first);

    // Distribution chart
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
                // Prodi filter
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
                // Semester filter
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

          // GENERAL STATISTICS CARDS
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

          // KRS STATISTICS & JADWAL KRS Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KRS Statistics
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
              // Jadwal KRS Status
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

          // PRESENSI STATISTICS
          CyberPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Analitik Kehadiran Perkuliahan (Presensi)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Average student presence
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: presencePercentageStud,
                              strokeWidth: 5,
                              color: AppColors.success,
                              backgroundColor: AppColors.success.withValues(alpha: 0.1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Presensi Mahasiswa', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                Text('${(presencePercentageStud * 100).toInt()}% Rata-rata', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Average Dosen presence
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: presencePercentageDosen,
                              strokeWidth: 5,
                              color: AppColors.primary,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Presensi Dosen', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                Text('${(presencePercentageDosen * 100).toInt()}% Kehadiran', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Attendance counts
                    Expanded(
                      flex: 3,
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

          // Student keaktifan & Distribution chart
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
        TextField(
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari nama, NIM, atau program studi...',
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
        ),
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
        Expanded(
          child: ListView.builder(
            itemCount: AppData.daftarDosen.length,
            itemBuilder: (context, index) {
              final d = AppData.daftarDosen[index];
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

  Widget _MiniStatusStat(String label, String value, Color color) {
    return CyberPanel(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
