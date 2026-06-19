import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/pertemuan_kuliah.dart';
import '../models/presensi_mahasiswa.dart';
import '../models/presensi_dosen.dart';
import '../models/kelas_kuliah.dart';
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/mata_kuliah.dart';
import '../models/prodi.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class PresensiPage extends StatefulWidget {
  final String role;
  final String? kodeProdi;
  final String? identifier;

  const PresensiPage({
    super.key,
    required this.role,
    this.kodeProdi,
    this.identifier,
  });

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  // Filters for Admin / Pimpinan
  String? _selectedProdiCode;
  String? _selectedMataKuliahCode;
  String? _selectedDosenNidn;
  String? _selectedKelasId;
  String? _selectedStatusKrs; // for general filters if needed

  // Active view state for Dosen
  KelasKuliah? _activeDosenKelas;
  
  // Search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Default filter for prodi-level roles
    if (widget.role == 'admin_prodi' || widget.role == 'pimpinan_prodi') {
      _selectedProdiCode = widget.kodeProdi ?? AppData.currentAdminProdiKode;
    }
  }

  // Helper getters
  List<Prodi> get _filteredProdiList {
    if (widget.role == 'admin_prodi' || widget.role == 'pimpinan_prodi') {
      return AppData.daftarProdi.where((p) => p.kodeProdi == _selectedProdiCode).toList();
    }
    return AppData.daftarProdi;
  }

  List<MataKuliah> get _filteredMataKuliahList {
    if (_selectedProdiCode != null) {
      return AppData.daftarMataKuliah.where((mk) => mk.kodeProdi == _selectedProdiCode).toList();
    }
    return AppData.daftarMataKuliah;
  }

  List<Dosen> get _filteredDosenList {
    if (_selectedProdiCode != null) {
      return AppData.daftarDosen.where((d) => d.kodeProdi == _selectedProdiCode).toList();
    }
    return AppData.daftarDosen;
  }

  List<KelasKuliah> get _filteredKelasList {
    Iterable<KelasKuliah> list = AppData.daftarKelas;
    if (_selectedProdiCode != null) {
      list = list.where((k) => k.kodeProdi == _selectedProdiCode);
    }
    if (_selectedMataKuliahCode != null) {
      list = list.where((k) => k.kodeMataKuliah == _selectedMataKuliahCode);
    }
    if (_selectedDosenNidn != null) {
      // Find classes where dosen is pengampu
      final dosen = AppData.daftarDosen.firstWhere((d) => d.nidn == _selectedDosenNidn, orElse: () => AppData.daftarDosen.first);
      list = list.where((k) => k.dosenPengampu == dosen.nama);
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'mahasiswa') {
      return _buildMahasiswaView();
    } else if (widget.role == 'dosen') {
      return _buildDosenView();
    } else {
      // admin_univ, admin_prodi, pimpinan_univ, pimpinan_prodi
      return _buildManagementView();
    }
  }

  // ===========================================================================
  // MAHASISWA VIEW
  // ===========================================================================
  Widget _buildMahasiswaView() {
    final nim = widget.identifier ?? AppData.currentNim;
    final mhs = AppData.daftarMahasiswa.firstWhere((m) => m.nim == nim, orElse: () => AppData.daftarMahasiswa.first);
    
    // Get student classes from KRS (Nilai where statusKrs == 'valid')
    final studentClasses = AppData.daftarNilai
        .where((n) => n.nim == nim && n.statusKrs == 'valid')
        .map((n) => n.idKelasKuliah)
        .toSet();

    // Filter meetings for these classes
    final meetings = AppData.daftarPertemuanKuliah
        .where((p) => studentClasses.contains(p.idKelasKuliah))
        .toList();

    // Active meetings that are open for presence
    final activeMeetings = meetings.where((p) => p.statusSesi == 'aktif').toList();

    // Calculate statistics
    final totalMeetings = meetings.length;
    final presensiMhs = AppData.daftarPresensiMahasiswa.where((pm) => pm.nim == nim).toList();
    final presentCount = presensiMhs.where((pm) => pm.status == 'Hadir').length;
    final permitCount = presensiMhs.where((pm) => pm.status == 'Izin').length;
    final sickCount = presensiMhs.where((pm) => pm.status == 'Sakit').length;
    final absentCount = presensiMhs.where((pm) => pm.status == 'Alfa').length;
    
    final double presencePercentage = totalMeetings > 0 ? (presentCount / totalMeetings) : 1.0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CyberHeader(
              tag: 'PRESENSI MAHASISWA',
              title: 'Sistem Kehadiran Perkuliahan',
              subtitle: 'Lakukan presensi kehadiran pada sesi kuliah aktif dan pantau riwayat kehadiran Anda.',
              icon: Icons.fingerprint_rounded,
            ),
            const SizedBox(height: 16),
            
            // Statistics panel
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CyberPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 68,
                                height: 68,
                                child: CircularProgressIndicator(
                                  value: presencePercentage,
                                  strokeWidth: 6,
                                  strokeCap: StrokeCap.round,
                                  color: presencePercentage >= 0.8 ? AppColors.success : AppColors.error,
                                  backgroundColor: (presencePercentage >= 0.8 ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                ),
                              ),
                              Text(
                                '${(presencePercentage * 100).toInt()}%',
                                style: TextStyle(
                                  color: presencePercentage >= 0.8 ? AppColors.success : AppColors.error,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rata-rata Kehadiran', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '$presentCount dari $totalMeetings Pertemuan',
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                presencePercentage >= 0.8 ? 'Memenuhi syarat ujian (>= 80%)' : 'Di bawah batas minimum ujian (< 80%)',
                                style: TextStyle(
                                  color: presencePercentage >= 0.8 ? AppColors.success : AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(child: _MiniStatusStat('Hadir', '$presentCount', AppColors.success)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStatusStat('Izin', '$permitCount', AppColors.primary)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStatusStat('Sakit', '$sickCount', AppColors.warning)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStatusStat('Alfa', '$absentCount', AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_tethering_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Pertemuan Aktif (${activeMeetings.length})'),
                    ],
                  ),
                ),
                const Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Riwayat Presensi'),
                    ],
                  ),
                ),
              ],
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMahasiswaPertemuanAktif(activeMeetings, nim),
                  _buildMahasiswaRiwayat(meetings, nim),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildMahasiswaPertemuanAktif(List<PertemuanKuliah> activeMeetings, String nim) {
    if (activeMeetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_tethering_off_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada sesi perkuliahan aktif saat ini.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const Text(
              'Silakan hubungi dosen pengampu untuk membuka sesi presensi.',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: activeMeetings.length,
      itemBuilder: (context, index) {
        final meeting = activeMeetings[index];
        final kelas = AppData.daftarKelas.firstWhere((k) => k.id == meeting.idKelasKuliah);
        final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
        
        // Check if student has already checked in
        final presence = AppData.daftarPresensiMahasiswa.firstWhere(
          (pm) => pm.idPertemuan == meeting.id && pm.nim == nim,
          orElse: () => PresensiMahasiswa(id: '', idPertemuan: meeting.id, nim: nim, status: 'Alfa'),
        );
        
        final hasCheckedIn = presence.id.isNotEmpty && presence.status != 'Alfa';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CyberPanel(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pertemuan #${meeting.nomorPertemuan}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mk.namaMataKuliah,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosen: ${kelas.dosenPengampu} • Kelas ${kelas.namaKelas}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Topik: ${meeting.catatan ?? "Materi Perkuliahan"}',
                        style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${meeting.namaRuangan.isNotEmpty ? meeting.namaRuangan : kelas.ruangan}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.school_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${meeting.semester} ${meeting.tahunAkademik}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primaryLight),
                          const SizedBox(width: 4),
                          Text(
                            '${meeting.hari.isNotEmpty ? meeting.hari : kelas.hari}, ${meeting.jamMulai.isNotEmpty ? meeting.jamMulai : kelas.jamMulai} – ${meeting.jamSelesai.isNotEmpty ? meeting.jamSelesai : kelas.jamSelesai}',
                            style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                hasCheckedIn
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              presence.status,
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            if (presence.waktuPresensi != null)
                              Text(
                                '${presence.waktuPresensi!.hour.toString().padLeft(2, '0')}:${presence.waktuPresensi!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _doMahasiswaPresence(meeting.id, nim),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: const Text('HADIR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _doMahasiswaPresence(String meetingId, String nim) {
    setState(() {
      // Find if entry exists
      final existingIndex = AppData.daftarPresensiMahasiswa.indexWhere(
        (pm) => pm.idPertemuan == meetingId && pm.nim == nim,
      );

      if (existingIndex != -1) {
        AppData.daftarPresensiMahasiswa[existingIndex] = PresensiMahasiswa(
          id: AppData.daftarPresensiMahasiswa[existingIndex].id,
          idPertemuan: meetingId,
          nim: nim,
          status: 'Hadir',
          waktuPresensi: DateTime.now(),
          catatan: 'Presensi Mandiri via Mobile/Web',
        );
      } else {
        AppData.daftarPresensiMahasiswa.add(
          PresensiMahasiswa(
            id: 'PM-${DateTime.now().millisecondsSinceEpoch}',
            idPertemuan: meetingId,
            nim: nim,
            status: 'Hadir',
            waktuPresensi: DateTime.now(),
            catatan: 'Presensi Mandiri via Mobile/Web',
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Presensi hadir berhasil dicatat!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildMahasiswaRiwayat(List<PertemuanKuliah> meetings, String nim) {
    if (meetings.isEmpty) {
      return const Center(
        child: Text('Belum ada riwayat pertemuan perkuliahan.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        final kelas = AppData.daftarKelas.firstWhere((k) => k.id == meeting.idKelasKuliah);
        final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
        
        final presence = AppData.daftarPresensiMahasiswa.firstWhere(
          (pm) => pm.idPertemuan == meeting.id && pm.nim == nim,
          orElse: () => PresensiMahasiswa(id: '', idPertemuan: meeting.id, nim: nim, status: 'Alfa'),
        );

        Color statusColor = AppColors.error;
        IconData statusIcon = Icons.cancel_rounded;

        if (presence.status == 'Hadir') {
          statusColor = AppColors.success;
          statusIcon = Icons.check_circle_rounded;
        } else if (presence.status == 'Izin') {
          statusColor = AppColors.primary;
          statusIcon = Icons.info_rounded;
        } else if (presence.status == 'Sakit') {
          statusColor = AppColors.warning;
          statusIcon = Icons.healing_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CyberPanel(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mk.namaMataKuliah,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pertemuan #${meeting.nomorPertemuan} • ${meeting.tanggal.day}/${meeting.tanggal.month}/${meeting.tanggal.year}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      Text(
                        '${meeting.semester} ${meeting.tahunAkademik} • ${meeting.namaRuangan.isNotEmpty ? meeting.namaRuangan : kelas.ruangan} • ${meeting.jamMulai.isNotEmpty ? meeting.jamMulai : kelas.jamMulai}–${meeting.jamSelesai.isNotEmpty ? meeting.jamSelesai : kelas.jamSelesai}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      if (meeting.catatan != null)
                        Text(
                          'Materi: ${meeting.catatan}',
                          style: const TextStyle(color: AppColors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(presence.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          if (presence.waktuPresensi != null)
                            Text(
                              '${presence.waktuPresensi!.hour.toString().padLeft(2,'0')}:${presence.waktuPresensi!.minute.toString().padLeft(2,'0')}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // DOSEN VIEW
  // ===========================================================================
  Widget _buildDosenView() {
    final nidn = widget.identifier ?? AppData.currentDosenNidn;
    
    // Get classes taught by this Dosen
    final classes = AppData.daftarKelas.where((k) {
      // Dosen name match or Relasi DosenPengajar
      final taught = AppData.daftarDosenPengajar.any((dp) => dp.idKelas == k.id && dp.nidnDosen == nidn);
      return taught || k.dosenPengampu == AppData.currentDosenNama;
    }).toList();

    if (_activeDosenKelas != null) {
      return _buildDosenKelasDetailView(_activeDosenKelas!, nidn);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CyberHeader(
          tag: 'DOSEN PENGAMPU',
          title: 'Manajemen Kehadiran Kelas',
          subtitle: 'Pilih kelas kuliah yang Anda ampu untuk mengelola pertemuan dan presensi mahasiswa.',
          icon: Icons.assignment_rounded,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: classes.isEmpty
              ? const Center(
                  child: Text('Anda tidak memiliki kelas perkuliahan aktif semester ini.', style: TextStyle(color: AppColors.textSecondary)),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final kelas = classes[index];
                    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
                    final totalMhs = AppData.daftarNilai.where((n) => n.idKelasKuliah == kelas.id && n.statusKrs == 'valid').length;
                    final totalPertemuan = AppData.daftarPertemuanKuliah.where((p) => p.idKelasKuliah == kelas.id).length;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _activeDosenKelas = kelas;
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: CyberPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Kelas ${kelas.namaKelas}',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                Text(
                                  '${mk.jumlahSks} SKS',
                                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mk.namaMataKuliah,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.people_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text('$totalMhs Peserta', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(width: 16),
                                const Icon(Icons.event_note_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text('$totalPertemuan Pertemuan', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

  Widget _buildDosenKelasDetailView(KelasKuliah kelas, String nidn) {
    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
    
    // Meetings for this class
    final meetings = AppData.daftarPertemuanKuliah
        .where((p) => p.idKelasKuliah == kelas.id)
        .toList()
      ..sort((a, b) => a.nomorPertemuan.compareTo(b.nomorPertemuan));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
              onPressed: () {
                setState(() {
                  _activeDosenKelas = null;
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mk.namaMataKuliah} (Kelas ${kelas.namaKelas})',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Semester ${AppData.daftarJadwalKrs.isNotEmpty ? AppData.daftarJadwalKrs.first.semester : '-'} ${AppData.daftarJadwalKrs.isNotEmpty ? AppData.daftarJadwalKrs.first.tahunAkademik : '-'} • Ruang: ${kelas.ruangan} • ${kelas.hari}, ${kelas.jamMulai}-${kelas.jamSelesai}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreateMeetingDialog(kelas),
              icon: const Icon(Icons.add),
              label: const Text('+ Buat Pertemuan'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: meetings.isEmpty
              ? const Center(
                  child: Text('Belum ada pertemuan perkuliahan yang dibuat untuk kelas ini.', style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    final isSesiOpen = meeting.statusSesi == 'aktif';

                    // Get Dosen attendance
                    final dosenPresence = AppData.daftarPresensiDosen.firstWhere(
                      (pd) => pd.idPertemuan == meeting.id && pd.nidn == nidn,
                      orElse: () => PresensiDosen(id: '', idPertemuan: meeting.id, nidn: nidn, status: 'Belum Presensi'),
                    );

                    // Student attendance stats
                    final studentPresences = AppData.daftarPresensiMahasiswa.where((pm) => pm.idPertemuan == meeting.id).toList();
                    final presentCount = studentPresences.where((pm) => pm.status == 'Hadir').length;
                    final totalStudents = AppData.daftarNilai.where((n) => n.idKelasKuliah == kelas.id && n.statusKrs == 'valid').length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CyberPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pertemuan #${meeting.nomorPertemuan}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Sesi Presensi: ',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                    Switch(
                                      value: isSesiOpen,
                                      activeColor: AppColors.success,
                                      onChanged: (val) {
                                        setState(() {
                                          meeting.statusSesi = val ? 'aktif' : 'tutup';
                                        });
                                      },
                                    ),
                                    Text(
                                      isSesiOpen ? 'BUKA' : 'TUTUP',
                                      style: TextStyle(
                                        color: isSesiOpen ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                      '${meeting.hari.isNotEmpty ? meeting.hari : kelas.hari}, ${meeting.tanggal.day}/${meeting.tanggal.month}/${meeting.tanggal.year}  •  ${meeting.jamMulai.isNotEmpty ? meeting.jamMulai : kelas.jamMulai}–${meeting.jamSelesai.isNotEmpty ? meeting.jamSelesai : kelas.jamSelesai}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${meeting.namaRuangan.isNotEmpty ? meeting.namaRuangan : kelas.ruangan}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.school_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Semester ${meeting.semester} ${meeting.tahunAkademik}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                    if (meeting.catatan != null && meeting.catatan!.isNotEmpty)
                      Text('Topik: ${meeting.catatan}', style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Presensi Dosen', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                              Text(
                                                dosenPresence.status,
                                                style: TextStyle(
                                                  color: dosenPresence.status == 'Belum Presensi' ? AppColors.warning : AppColors.success,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _showDosenPresenceDialog(meeting, nidn),
                                          child: const Text('Isi Presensi'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.people, color: AppColors.success),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Presensi Mahasiswa', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                              Text(
                                                '$presentCount / $totalStudents Hadir',
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _showStudentPresenceManagementDialog(meeting, kelas),
                                          child: const Text('Kelola'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

  void _showCreateMeetingDialog(KelasKuliah kelas) {
    final noController = TextEditingController(
      text: '${AppData.daftarPertemuanKuliah.where((p) => p.idKelasKuliah == kelas.id).length + 1}',
    );
    final catatanController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    // Resolve ruangan dari master data
    final ruanganObj = AppData.daftarRuangan.where((r) => r.kodeRuangan == kelas.kodeRuangan).toList();
    final namaRuanganKelas = ruanganObj.isNotEmpty ? ruanganObj.first.namaRuangan : kelas.ruangan;

    // Jadwal KRS aktif
    final jadwalAktif = AppData.daftarJadwalKrs.isNotEmpty ? AppData.daftarJadwalKrs.first : null;
    final tahunAkademik = jadwalAktif?.tahunAkademik ?? '2024/2025';
    final semester = jadwalAktif?.semester ?? 'Ganjil';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Buat Pertemuan – ${kelas.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info konteks akademik (read-only)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('INFORMASI KELAS', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      _InfoRow(Icons.book_outlined, 'Mata Kuliah',
                        AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first).namaMataKuliah),
                      _InfoRow(Icons.person_outline, 'Dosen', kelas.dosenPengampu),
                      _InfoRow(Icons.location_on_outlined, 'Ruangan', '$namaRuanganKelas (${kelas.kodeRuangan})'),
                      _InfoRow(Icons.access_time, 'Jadwal', '${kelas.hari}, ${kelas.jamMulai}–${kelas.jamSelesai}'),
                      _InfoRow(Icons.school_outlined, 'Semester', '$semester $tahunAkademik'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nomor Pertemuan (1–16)'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                  title: Text('Tanggal: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setDlgState(() => selectedDate = picked);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(labelText: 'Topik / Catatan Materi'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final numVal = int.tryParse(noController.text) ?? 1;
                final newMeeting = PertemuanKuliah(
                  id: 'P-${DateTime.now().millisecondsSinceEpoch}',
                  nomorPertemuan: numVal,
                  tanggal: selectedDate,
                  idKelasKuliah: kelas.id,
                  statusSesi: 'tutup',
                  catatan: catatanController.text.trim(),
                  tahunAkademik: tahunAkademik,
                  semester: semester,
                  kodeRuangan: kelas.kodeRuangan,
                  namaRuangan: namaRuanganKelas,
                  hari: kelas.hari,
                  jamMulai: kelas.jamMulai,
                  jamSelesai: kelas.jamSelesai,
                );
                setState(() => AppData.daftarPertemuanKuliah.add(newMeeting));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pertemuan #$numVal berhasil dibuat!')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDosenPresenceDialog(PertemuanKuliah meeting, String nidn) {
    String currentStatus = 'Hadir';
    
    // Find active presence
    final idx = AppData.daftarPresensiDosen.indexWhere((pd) => pd.idPertemuan == meeting.id && pd.nidn == nidn);
    if (idx != -1) {
      currentStatus = AppData.daftarPresensiDosen[idx].status;
      if (currentStatus == 'Belum Presensi') currentStatus = 'Hadir';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Isi Presensi Dosen', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Hadir', 'Izin', 'Sakit', 'Alfa'].map((status) {
              return RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: currentStatus,
                onChanged: (val) {
                  if (val != null) {
                    setDlgState(() {
                      currentStatus = val;
                    });
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final idx = AppData.daftarPresensiDosen.indexWhere((pd) => pd.idPertemuan == meeting.id && pd.nidn == nidn);
                  if (idx != -1) {
                    AppData.daftarPresensiDosen[idx] = PresensiDosen(
                      id: AppData.daftarPresensiDosen[idx].id,
                      idPertemuan: meeting.id,
                      nidn: nidn,
                      status: currentStatus,
                      waktuPresensi: DateTime.now(),
                    );
                  } else {
                    AppData.daftarPresensiDosen.add(
                      PresensiDosen(
                        id: 'PD-${DateTime.now().millisecondsSinceEpoch}',
                        idPertemuan: meeting.id,
                        nidn: nidn,
                        status: currentStatus,
                        waktuPresensi: DateTime.now(),
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Presensi Dosen berhasil diperbarui!')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentPresenceManagementDialog(PertemuanKuliah meeting, KelasKuliah kelas) {
    // Get all students enrolled in this class
    final students = AppData.daftarNilai
        .where((n) => n.idKelasKuliah == kelas.id && n.statusKrs == 'valid')
        .map((n) => AppData.daftarMahasiswa.firstWhere((m) => m.nim == n.nim))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Presensi Mahasiswa - Pertemuan #${meeting.nomorPertemuan}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: students.isEmpty
                        ? const Center(child: Text('Tidak ada mahasiswa terdaftar di kelas ini.'))
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              
                              // Find student presence
                              final presence = AppData.daftarPresensiMahasiswa.firstWhere(
                                (pm) => pm.idPertemuan == meeting.id && pm.nim == student.nim,
                                orElse: () => PresensiMahasiswa(id: '', idPertemuan: meeting.id, nim: student.nim, status: 'Alfa'),
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(student.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(student.nim, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    // Status Selector
                                    Row(
                                      children: ['Hadir', 'Izin', 'Sakit', 'Alfa'].map((status) {
                                        final isSelected = presence.status == status;
                                        Color activeColor = AppColors.primary;
                                        if (status == 'Hadir') activeColor = AppColors.success;
                                        if (status == 'Izin') activeColor = AppColors.primary;
                                        if (status == 'Sakit') activeColor = AppColors.warning;
                                        if (status == 'Alfa') activeColor = AppColors.error;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: ChoiceChip(
                                            label: Text(status, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textSecondary)),
                                            selected: isSelected,
                                            selectedColor: activeColor,
                                            onSelected: (selected) {
                                              if (selected) {
                                                setDlgState(() {
                                                  // Update list
                                                  final idx = AppData.daftarPresensiMahasiswa.indexWhere(
                                                    (pm) => pm.idPertemuan == meeting.id && pm.nim == student.nim,
                                                  );
                                                  if (idx != -1) {
                                                    AppData.daftarPresensiMahasiswa[idx].status = status;
                                                  } else {
                                                    AppData.daftarPresensiMahasiswa.add(
                                                      PresensiMahasiswa(
                                                        id: 'PM-${DateTime.now().millisecondsSinceEpoch}',
                                                        idPertemuan: meeting.id,
                                                        nim: student.nim,
                                                        status: status,
                                                        waktuPresensi: status == 'Hadir' ? DateTime.now() : null,
                                                      ),
                                                    );
                                                  }
                                                });
                                                setState(() {}); // refresh outer widget
                                              }
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // MANAGEMENT VIEW (ADMIN & PIMPINAN)
  // ===========================================================================
  Widget _buildManagementView() {
    final isPimpinan = widget.role == 'pimpinan_univ' || widget.role == 'pimpinan_prodi';
    
    // Get filtered list of meetings
    final filteredMeetings = AppData.daftarPertemuanKuliah.where((meeting) {
      final kelas = AppData.daftarKelas.firstWhere((k) => k.id == meeting.idKelasKuliah, orElse: () => AppData.daftarKelas.first);
      final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
      
      // Filter by prodi
      if (_selectedProdiCode != null && kelas.kodeProdi != _selectedProdiCode) return false;
      // Filter by MK
      if (_selectedMataKuliahCode != null && kelas.kodeMataKuliah != _selectedMataKuliahCode) return false;
      // Filter by Dosen
      if (_selectedDosenNidn != null) {
        final hasDosen = AppData.daftarDosenPengajar.any((dp) => dp.idKelas == kelas.id && dp.nidnDosen == _selectedDosenNidn);
        if (!hasDosen && kelas.dosenPengampu != AppData.daftarDosen.firstWhere((d) => d.nidn == _selectedDosenNidn).nama) {
          return false;
        }
      }
      // Filter by Kelas
      if (_selectedKelasId != null && kelas.id != _selectedKelasId) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return mk.namaMataKuliah.toLowerCase().contains(q) ||
            kelas.dosenPengampu.toLowerCase().contains(q) ||
            kelas.namaKelas.toLowerCase().contains(q);
      }

      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CyberHeader(
          tag: widget.role.toUpperCase().replaceAll('_', ' '),
          title: isPimpinan ? 'Pemantauan Kehadiran Kuliah' : 'Kelola Kehadiran Kuliah',
          subtitle: isPimpinan 
              ? 'Mode View-Only: Lihat dan telusuri rekap presensi dosen dan mahasiswa.'
              : 'Kelola data pertemuan perkuliahan, buka/tutup sesi, dan atur presensi kelas.',
          icon: Icons.fact_check_rounded,
        ),
        const SizedBox(height: 16),
        
        // FILTERS ROW
        CyberPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_alt, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Filter Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (widget.role != 'admin_prodi' && widget.role != 'pimpinan_prodi') {
                          _selectedProdiCode = null;
                        }
                        _selectedMataKuliahCode = null;
                        _selectedDosenNidn = null;
                        _selectedKelasId = null;
                      });
                    },
                    child: const Text('Reset Filter'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Prodi filter (Disabled for prodi-level roles)
                  if (widget.role != 'admin_prodi' && widget.role != 'pimpinan_prodi') ...[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedProdiCode,
                        decoration: const InputDecoration(labelText: 'Prodi', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Semua Prodi')),
                          ..._filteredProdiList.map((p) => DropdownMenuItem(value: p.kodeProdi, child: Text(p.aliasProdi))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedProdiCode = val;
                            _selectedMataKuliahCode = null;
                            _selectedDosenNidn = null;
                            _selectedKelasId = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // Mata Kuliah filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMataKuliahCode,
                      decoration: const InputDecoration(labelText: 'Mata Kuliah', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua MK')),
                        ..._filteredMataKuliahList.map((mk) => DropdownMenuItem(value: mk.kodeMataKuliah, child: Text(mk.namaMataKuliah, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedMataKuliahCode = val;
                          _selectedKelasId = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dosen filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDosenNidn,
                      decoration: const InputDecoration(labelText: 'Dosen', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Dosen')),
                        ..._filteredDosenList.map((d) => DropdownMenuItem(value: d.nidn, child: Text(d.nama, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedDosenNidn = val;
                          _selectedKelasId = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Kelas filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedKelasId,
                      decoration: const InputDecoration(labelText: 'Kelas', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Kelas')),
                        ..._filteredKelasList.map((k) => DropdownMenuItem(value: k.id, child: Text('Kelas ${k.namaKelas} (${k.id})'))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedKelasId = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Search bar
        TextField(
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari mata kuliah, dosen, kelas...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            fillColor: AppColors.surface,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),

        // Add meeting button for Admin (not Pimpinan)
        if (!isPimpinan) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (_selectedKelasId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pilih Kelas filter terlebih dahulu untuk membuat pertemuan!'), backgroundColor: AppColors.error),
                    );
                    return;
                  }
                  final targetKelas = AppData.daftarKelas.firstWhere((k) => k.id == _selectedKelasId);
                  _showCreateMeetingDialog(targetKelas);
                },
                icon: const Icon(Icons.add),
                label: const Text('Buat Pertemuan di Kelas Terpilih'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // MEETINGS TABLE / LIST
        Expanded(
          child: filteredMeetings.isEmpty
              ? const Center(child: Text('Tidak ada pertemuan yang cocok dengan kriteria filter.', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  itemCount: filteredMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = filteredMeetings[index];
                    final kelas = AppData.daftarKelas.firstWhere((k) => k.id == meeting.idKelasKuliah, orElse: () => AppData.daftarKelas.first);
                    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
                    final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == kelas.kodeProdi, orElse: () => AppData.daftarProdi.first);

                    // Presence stats
                    final studentPresences = AppData.daftarPresensiMahasiswa.where((pm) => pm.idPertemuan == meeting.id).toList();
                    final presentCount = studentPresences.where((pm) => pm.status == 'Hadir').length;
                    final totalStudents = AppData.daftarNilai.where((n) => n.idKelasKuliah == kelas.id && n.statusKrs == 'valid').length;

                    // Dosen presence status
                    final dosenPresence = AppData.daftarPresensiDosen.firstWhere(
                      (pd) => pd.idPertemuan == meeting.id,
                      orElse: () => PresensiDosen(id: '', idPertemuan: meeting.id, nidn: '', status: 'Belum Presensi'),
                    );

                    final isSesiOpen = meeting.statusSesi == 'aktif';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CyberPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Pertemuan #${meeting.nomorPertemuan}',
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      prodi.aliasProdi,
                                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                                // Session Status
                                isPimpinan 
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSesiOpen ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: isSesiOpen ? AppColors.success : AppColors.error),
                                        ),
                                        child: Text(
                                          isSesiOpen ? 'Sesi Terbuka' : 'Sesi Tertutup',
                                          style: TextStyle(
                                            color: isSesiOpen ? AppColors.success : AppColors.error,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          const Text('Sesi: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                          Switch(
                                            value: isSesiOpen,
                                            onChanged: (val) {
                                              setState(() {
                                                meeting.statusSesi = val ? 'aktif' : 'tutup';
                                              });
                                            },
                                            activeColor: AppColors.success,
                                          ),
                                          Text(
                                            isSesiOpen ? 'BUKA' : 'TUTUP',
                                            style: TextStyle(
                                              color: isSesiOpen ? AppColors.success : AppColors.error,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${mk.kodeMataKuliah} - ${mk.namaMataKuliah} (Kelas ${kelas.namaKelas})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${kelas.dosenPengampu} • ${meeting.namaRuangan.isNotEmpty ? meeting.namaRuangan : kelas.ruangan} • ${meeting.semester} ${meeting.tahunAkademik}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            if (meeting.catatan != null && meeting.catatan!.isNotEmpty)
                              Text(
                                'Topik: ${meeting.catatan}',
                                style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: AppColors.primary, size: 16),
                                    const SizedBox(width: 4),
                                    const Text('Presensi Dosen: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    Text(
                                      dosenPresence.status,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: dosenPresence.status == 'Belum Presensi' ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.people, color: AppColors.success, size: 16),
                                    const SizedBox(width: 4),
                                    const Text('Mhs Hadir: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    Text(
                                      '$presentCount / $totalStudents',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => _showMeetingDetailViewOnlyDialog(meeting, kelas),
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('Detail Presensi'),
                                ),
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

  void _showMeetingDetailViewOnlyDialog(PertemuanKuliah meeting, KelasKuliah kelas) {
    // Get all students enrolled in this class
    final students = AppData.daftarNilai
        .where((n) => n.idKelasKuliah == kelas.id && n.statusKrs == 'valid')
        .map((n) => AppData.daftarMahasiswa.firstWhere((m) => m.nim == n.nim))
        .toList();

    // Dosen presence status
    final dosenPresence = AppData.daftarPresensiDosen.firstWhere(
      (pd) => pd.idPertemuan == meeting.id,
      orElse: () => PresensiDosen(id: '', idPertemuan: meeting.id, nidn: '', status: 'Belum Presensi'),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Kehadiran - Pertemuan #${meeting.nomorPertemuan}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              // Header info pertemuan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DETAIL PERTEMUAN', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    (() {
                      final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah, orElse: () => AppData.daftarMataKuliah.first);
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _InfoRow(Icons.book_outlined, 'Mata Kuliah', '${mk.kodeMataKuliah} – ${mk.namaMataKuliah} (${mk.jumlahSks} SKS)'),
                        _InfoRow(Icons.class_outlined, 'Kelas', 'Kelas ${kelas.namaKelas} (${kelas.id})'),
                        _InfoRow(Icons.person_outline, 'Dosen', '${kelas.dosenPengampu} (${dosenPresence.nidn.isNotEmpty ? dosenPresence.nidn : '-'})'),
                        _InfoRow(Icons.location_on_outlined, 'Ruangan', meeting.namaRuangan.isNotEmpty ? '${meeting.namaRuangan} (${meeting.kodeRuangan})' : kelas.ruangan),
                        _InfoRow(Icons.access_time, 'Jadwal', '${meeting.hari.isNotEmpty ? meeting.hari : kelas.hari}, ${meeting.jamMulai.isNotEmpty ? meeting.jamMulai : kelas.jamMulai}–${meeting.jamSelesai.isNotEmpty ? meeting.jamSelesai : kelas.jamSelesai}'),
                        _InfoRow(Icons.school_outlined, 'Semester', '${meeting.semester} ${meeting.tahunAkademik}'),
                        if (meeting.catatan != null && meeting.catatan!.isNotEmpty)
                          _InfoRow(Icons.notes, 'Topik', meeting.catatan!),
                      ]);
                    })(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Dosen Presensi
              CyberPanel(
                padding: const EdgeInsets.all(12),
                color: AppColors.bg,
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DOSEN PENGAMPU', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(kelas.dosenPengampu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (dosenPresence.waktuPresensi != null)
                            Text(
                              'Presensi pukul ${dosenPresence.waktuPresensi!.hour.toString().padLeft(2,'0')}:${dosenPresence.waktuPresensi!.minute.toString().padLeft(2,'0')}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (dosenPresence.status == 'Hadir' ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dosenPresence.status,
                        style: TextStyle(
                          color: dosenPresence.status == 'Hadir' ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Daftar Kehadiran Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: students.isEmpty
                    ? const Center(child: Text('Tidak ada mahasiswa terdaftar di kelas ini.'))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          
                          // Find student presence
                          final presence = AppData.daftarPresensiMahasiswa.firstWhere(
                            (pm) => pm.idPertemuan == meeting.id && pm.nim == student.nim,
                            orElse: () => PresensiMahasiswa(id: '', idPertemuan: meeting.id, nim: student.nim, status: 'Alfa'),
                          );

                          Color statusColor = AppColors.error;
                          if (presence.status == 'Hadir') statusColor = AppColors.success;
                          if (presence.status == 'Izin') statusColor = AppColors.primary;
                          if (presence.status == 'Sakit') statusColor = AppColors.warning;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(student.nim, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    presence.status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
