import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../services/materi_service.dart';
import '../models/kelas_kuliah.dart';
import '../models/materi_kuliah.dart';
import '../models/pertemuan_kuliah.dart';
import '../models/presensi_dosen.dart';
import '../models/presensi_mahasiswa.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class MulaiKuliahPage extends StatefulWidget {
  final KelasKuliah kelas;
  const MulaiKuliahPage({super.key, required this.kelas});

  @override
  State<MulaiKuliahPage> createState() => _MulaiKuliahPageState();
}

class _MulaiKuliahPageState extends State<MulaiKuliahPage> {
  final _materiService = const MateriService();
  int _selectedWeek = 1;
  
  // Controllers for Material Upload
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  // Add File Temp State
  final _fileNameController = TextEditingController();
  final _fileUrlController = TextEditingController();
  String _selectedFileType = 'pdf';
  List<MateriFile> _tempFilesList = [];

  // Attendance states
  Map<String, String> _studentPresenceStatuses = {}; // NIM -> Status
  bool _dosenHadir = true;

  @override
  void initState() {
    super.initState();
    _loadWeekData();
  }

  void _loadWeekData() {
    // Load existing material if any
    final materis = _materiService.materiPadaMinggu(widget.kelas.id, _selectedWeek);
    final materi = materis.isNotEmpty ? materis.first : null;
    if (materi != null) {
      _judulController.text = materi.judulBab;
      _deskripsiController.text = materi.deskripsiBab;
      _tempFilesList = List.from(materi.files);
    } else {
      // Pre-fill from syllabus template if available
      final syllabus = _materiService.rencanaPadaKelas(widget.kelas.id);
      final weekSyllabus = syllabus.firstWhere(
        (s) => s.minggu == _selectedWeek,
        orElse: () => RencanaMateri(minggu: _selectedWeek, judulBab: 'Bab $_selectedWeek', subBab: ''),
      );
      _judulController.text = weekSyllabus.judulBab;
      _deskripsiController.text = weekSyllabus.subBab;
      _tempFilesList = [];
    }

    // Load attendance state if meeting exists
    final meeting = _getMeetingForWeek(_selectedWeek);
    if (meeting != null) {
      final nidn = AppData.currentDosenNidn;
      final dp = AppData.daftarPresensiDosen.firstWhere(
        (p) => p.idPertemuan == meeting.id && p.nidn == nidn,
        orElse: () => PresensiDosen(id: '', idPertemuan: meeting.id, nidn: nidn, status: 'Hadir'),
      );
      _dosenHadir = dp.status == 'Hadir';

      // Load students
      _studentPresenceStatuses.clear();
      final enrolled = _getEnrolledStudents();
      for (var s in enrolled) {
        final pm = AppData.daftarPresensiMahasiswa.firstWhere(
          (p) => p.idPertemuan == meeting.id && p.nim == s.nim,
          orElse: () => PresensiMahasiswa(id: '', idPertemuan: meeting.id, nim: s.nim, status: 'Alfa'),
        );
        _studentPresenceStatuses[s.nim] = pm.status;
      }
    } else {
      _dosenHadir = true;
      _studentPresenceStatuses.clear();
      final enrolled = _getEnrolledStudents();
      for (var s in enrolled) {
        _studentPresenceStatuses[s.nim] = 'Hadir'; // Default to Hadir for new meeting
      }
    }
  }

  PertemuanKuliah? _getMeetingForWeek(int week) {
    try {
      return AppData.daftarPertemuanKuliah.firstWhere(
        (p) => p.idKelasKuliah == widget.kelas.id && p.nomorPertemuan == week,
      );
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _getEnrolledStudents() {
    return AppData.daftarMahasiswa.where((m) {
      return AppData.daftarNilai.any((n) => n.idKelasKuliah == widget.kelas.id && n.nim == m.nim && n.statusKrs == 'valid');
    }).toList();
  }

  void _saveMaterial() {
    if (_judulController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul Bab tidak boleh kosong!'), backgroundColor: AppColors.error),
      );
      return;
    }

    final newMateri = MateriKuliah(
      id: 'M-${widget.kelas.id}-W$_selectedWeek-${DateTime.now().millisecondsSinceEpoch}',
      idKelasKuliah: widget.kelas.id,
      minggu: _selectedWeek,
      judulBab: _judulController.text.trim(),
      deskripsiBab: _deskripsiController.text.trim(),
      files: _tempFilesList,
      createdAt: DateTime.now(),
    );

    // Save to database & local via service
    _materiService.tambahMateri(newMateri);

    // Also update RencanaMateri (syllabus status)
    final syllabus = _materiService.rencanaPadaKelas(widget.kelas.id);
    final weekSyllabusIndex = syllabus.indexWhere((s) => s.minggu == _selectedWeek);
    if (weekSyllabusIndex != -1) {
      setState(() {
        syllabus[weekSyllabusIndex].judulBab = _judulController.text.trim();
        syllabus[weekSyllabusIndex].subBab = _deskripsiController.text.trim();
        syllabus[weekSyllabusIndex].sudahDibahas = true;
      });
      _materiService.updateRencana(syllabus[weekSyllabusIndex]);
    }

    // Update PertemuanKuliah catatan if meeting exists
    final meeting = _getMeetingForWeek(_selectedWeek);
    if (meeting != null) {
      // Just keep them in sync
      final idx = AppData.daftarPertemuanKuliah.indexOf(meeting);
      if (idx != -1) {
        AppData.daftarPertemuanKuliah[idx] = PertemuanKuliah(
          id: meeting.id,
          nomorPertemuan: meeting.nomorPertemuan,
          tanggal: meeting.tanggal,
          idKelasKuliah: meeting.idKelasKuliah,
          statusSesi: meeting.statusSesi,
          catatan: _judulController.text.trim(),
          tahunAkademik: meeting.tahunAkademik,
          semester: meeting.semester,
          kodeRuangan: meeting.kodeRuangan,
          namaRuangan: meeting.namaRuangan,
          jamMulai: meeting.jamMulai,
          jamSelesai: meeting.jamSelesai,
          hari: meeting.hari,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Materi berhasil disimpan & dipublikasikan untuk Mahasiswa!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _initializeMeeting() {
    final activeJadwal = AppData.daftarJadwalKrs.firstWhere((j) => j.status == 'Aktif', orElse: () => AppData.daftarJadwalKrs.first);
    
    final newMeeting = PertemuanKuliah(
      id: 'PK-${widget.kelas.id}-W$_selectedWeek',
      nomorPertemuan: _selectedWeek,
      tanggal: DateTime.now(),
      idKelasKuliah: widget.kelas.id,
      statusSesi: 'aktif',
      catatan: _judulController.text.isNotEmpty ? _judulController.text : 'Pertemuan Minggu $_selectedWeek',
      tahunAkademik: activeJadwal.tahunAkademik,
      semester: activeJadwal.semester,
      kodeRuangan: widget.kelas.kodeRuangan,
      namaRuangan: widget.kelas.ruangan,
      jamMulai: widget.kelas.jamMulai,
      jamSelesai: widget.kelas.jamSelesai,
      hari: widget.kelas.hari,
    );

    setState(() {
      AppData.daftarPertemuanKuliah.add(newMeeting);
      _loadWeekData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sesi pertemuan $_selectedWeek berhasil diinisialisasi & dibuka!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _saveAttendance() {
    final meeting = _getMeetingForWeek(_selectedWeek);
    if (meeting == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inisialisasi Pertemuan terlebih dahulu!'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Save Dosen attendance
    final nidn = AppData.currentDosenNidn;
    final dosenPresenceIndex = AppData.daftarPresensiDosen.indexWhere(
      (p) => p.idPertemuan == meeting.id && p.nidn == nidn,
    );

    final dpStatus = _dosenHadir ? 'Hadir' : 'Alfa';
    if (dosenPresenceIndex != -1) {
      AppData.daftarPresensiDosen[dosenPresenceIndex] = PresensiDosen(
        id: AppData.daftarPresensiDosen[dosenPresenceIndex].id,
        idPertemuan: meeting.id,
        nidn: nidn,
        status: dpStatus,
        waktuPresensi: DateTime.now(),
      );
    } else {
      AppData.daftarPresensiDosen.add(PresensiDosen(
        id: 'PD-${meeting.id}-$nidn',
        idPertemuan: meeting.id,
        nidn: nidn,
        status: dpStatus,
        waktuPresensi: DateTime.now(),
      ));
    }

    // Save students attendance
    _studentPresenceStatuses.forEach((nim, status) {
      final mhsPresenceIndex = AppData.daftarPresensiMahasiswa.indexWhere(
        (p) => p.idPertemuan == meeting.id && p.nim == nim,
      );

      if (mhsPresenceIndex != -1) {
        AppData.daftarPresensiMahasiswa[mhsPresenceIndex] = PresensiMahasiswa(
          id: AppData.daftarPresensiMahasiswa[mhsPresenceIndex].id,
          idPertemuan: meeting.id,
          nim: nim,
          status: status,
          waktuPresensi: DateTime.now(),
        );
      } else {
        AppData.daftarPresensiMahasiswa.add(PresensiMahasiswa(
          id: 'PM-${meeting.id}-$nim',
          idPertemuan: meeting.id,
          nim: nim,
          status: status,
          waktuPresensi: DateTime.now(),
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Presensi kehadiran dosen & mahasiswa berhasil disimpan!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == widget.kelas.kodeMataKuliah);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text('Mulai Kuliah: ${mk.namaMataKuliah} (${widget.kelas.namaKelas})'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Jadwal Materi'),
              Tab(icon: Icon(Icons.fingerprint), text: 'Absensi'),
              Tab(icon: Icon(Icons.upload_file), text: 'Input Materi'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),
        body: Column(
          children: [
            // Week Selector Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Pilih Sesi/Minggu Perkuliahan:',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedWeek,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        items: List.generate(16, (i) => i + 1).map((w) {
                          return DropdownMenuItem(
                            value: w,
                            child: Text('Minggu ke-$w'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedWeek = val;
                              _loadWeekData();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSyllabusTab(),
                  _buildAttendanceTab(),
                  _buildMaterialsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SYLLABUS TAB
  // ===========================================================================
  Widget _buildSyllabusTab() {
    final syllabus = _materiService.rencanaPadaKelas(widget.kelas.id);

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: syllabus.length,
      itemBuilder: (context, index) {
        final item = syllabus[index];
        final isSelectedWeek = item.minggu == _selectedWeek;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CyberPanel(
            color: isSelectedWeek ? AppColors.primary.withValues(alpha: 0.15) : null,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (item.sudahDibahas ? AppColors.success : AppColors.grey).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${item.minggu}',
                      style: TextStyle(
                        color: item.sudahDibahas ? AppColors.success : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judulBab,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subBab.isNotEmpty ? item.subBab : 'Sub bab belum diinput',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item.sudahDibahas ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.sudahDibahas ? 'Selesai' : 'Belum dibahas',
                        style: TextStyle(
                          color: item.sudahDibahas ? AppColors.success : AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: item.sudahDibahas,
                        activeColor: AppColors.success,
                        onChanged: (val) {
                          setState(() {
                            item.sudahDibahas = val;
                          });
                          _materiService.updateRencana(item);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // ATTENDANCE TAB
  // ===========================================================================
  Widget _buildAttendanceTab() {
    final meeting = _getMeetingForWeek(_selectedWeek);
    final enrolled = _getEnrolledStudents();

    if (meeting == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'Pertemuan Minggu ke-$_selectedWeek Belum Diinisialisasi',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Klik tombol di bawah untuk membuat sesi pertemuan baru, membuka sistem presensi untuk mahasiswa, dan menginput kehadiran kelas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeMeeting,
                icon: const Icon(Icons.wifi_tethering_rounded),
                label: Text('Inisialisasi Pertemuan $_selectedWeek'),
              ),
            ],
          ),
        ),
      );
    }

    final isSessionOpen = meeting.statusSesi == 'aktif';

    return Column(
      children: [
        // Dosen Attendance & Session Toggle Panel
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Kehadiran Dosen Pengajar',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _dosenHadir ? 'HADIR' : 'TIDAK HADIR',
                        style: TextStyle(
                          color: _dosenHadir ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _dosenHadir,
                        activeColor: AppColors.success,
                        onChanged: (val) {
                          setState(() {
                            _dosenHadir = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Sesi Presensi Mahasiswa:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  Row(
                    children: [
                      Text(
                        isSessionOpen ? 'TERBUKA (Mahasiswa Bisa Absen Mandiri)' : 'TERTUTUP (Dosen Saja)',
                        style: TextStyle(
                          color: isSessionOpen ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: isSessionOpen,
                        activeColor: AppColors.success,
                        onChanged: (val) {
                          setState(() {
                            meeting.statusSesi = val ? 'aktif' : 'tutup';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Students List Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Mahasiswa Peserta (${enrolled.length})',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Kehadiran: ${_studentPresenceStatuses.values.where((v) => v == 'Hadir').length}/${enrolled.length}',
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),

        // Students Attendance List
        Expanded(
          child: enrolled.isEmpty
              ? const Center(
                  child: Text('Belum ada mahasiswa terdaftar di kelas ini.', style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: enrolled.length,
                  itemBuilder: (context, index) {
                    final student = enrolled[index];
                    final currentStatus = _studentPresenceStatuses[student.nim] ?? 'Alfa';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CyberPanel(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.namaLengkap,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    student.nim,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: ['Hadir', 'Izin', 'Sakit', 'Alfa'].map((status) {
                                  final isSelected = currentStatus == status;
                                  Color btnColor = AppColors.grey;
                                  if (isSelected) {
                                    if (status == 'Hadir') btnColor = AppColors.success;
                                    if (status == 'Izin') btnColor = AppColors.primary;
                                    if (status == 'Sakit') btnColor = AppColors.warning;
                                    if (status == 'Alfa') btnColor = AppColors.error;
                                  }

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _studentPresenceStatuses[student.nim] = status;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected ? btnColor.withValues(alpha: 0.15) : Colors.transparent,
                                            border: Border.all(color: isSelected ? btnColor : AppColors.border),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              status[0], // H, I, S, A
                                              style: TextStyle(
                                                color: isSelected ? btnColor : AppColors.textSecondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Action Save Button
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Kehadiran Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MATERIALS TAB
  // ===========================================================================
  Widget _buildMaterialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Input Informasi Materi Kuliah',
            style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _judulController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Judul Bab / Pertemuan',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'e.g. Bab 3: Pemrograman Berorientasi Objek',
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _deskripsiController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Deskripsi / Materi Ringkas',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'Tuliskan rangkuman materi perkuliahan minggu ini...',
            ),
          ),
          const SizedBox(height: 20),

          // Uploaded files section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lampiran File / Link Materi:',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: _showAddFileDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Lampiran'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _tempFilesList.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Belum ada file/link terlampir.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                )
              : Column(
                  children: _tempFilesList.map((file) {
                    IconData icon = Icons.insert_drive_file;
                    if (file.tipe == 'pdf') icon = Icons.picture_as_pdf;
                    if (file.tipe == 'ppt' || file.tipe == 'pptx') icon = Icons.slideshow;
                    if (file.tipe == 'link') icon = Icons.link;

                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(icon, color: AppColors.primary),
                        title: Text(file.nama, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(file.url, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () {
                            setState(() {
                              _tempFilesList.remove(file);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saveMaterial,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('Simpan & Publikasikan Materi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFileDialog() {
    _fileNameController.clear();
    _fileUrlController.clear();
    _selectedFileType = 'pdf';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Tambah Lampiran Materi', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedFileType,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Tipe Lampiran'),
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF Document (.pdf)')),
                    DropdownMenuItem(value: 'ppt', child: Text('PowerPoint Presentation (.ppt)')),
                    DropdownMenuItem(value: 'link', child: Text('External Link (URL)')),
                    DropdownMenuItem(value: 'image', child: Text('Image File (.png/.jpg)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDlgState(() => _selectedFileType = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fileNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Nama File / Judul Link',
                    hintText: 'e.g. Slide Pemrograman Objek.pdf',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fileUrlController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'URL / Lokasi File',
                    hintText: 'e.g. assets/materi.pdf atau https://...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_fileNameController.text.trim().isEmpty || _fileUrlController.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  _tempFilesList.add(MateriFile(
                    nama: _fileNameController.text.trim(),
                    tipe: _selectedFileType,
                    url: _fileUrlController.text.trim(),
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
