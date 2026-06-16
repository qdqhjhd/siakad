import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../services/dosen_pengajar_service.dart';
import '../services/ruangan_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class KrsPage extends StatefulWidget {
  const KrsPage({super.key});

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> {
  final akademik = const AkademikService();
  final _dosenPengajarService = const DosenPengajarService();
  final _ruanganService = const RuanganService();

  void _ambilDraft(String idKelas) {
    if (akademik.ambilDraft(idKelas)) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas berhasil masuk draft KRS')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas sudah diambil atau penuh')),
      );
    }
  }

  void _batalDraft(String idKelas) {
    setState(() => akademik.batalDraft(idKelas));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kelas dihapus dari draft KRS')),
    );
  }

  void _ajukanKrs() {
    final draft = akademik.krsDraftMahasiswaAktif();
    if (draft.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada draft KRS yang bisa diajukan')),
      );
      return;
    }
    setState(() => akademik.kirimKrs());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KRS berhasil diajukan untuk divalidasi')),
    );
  }

  Widget _buildStatusHeader() {
    final mhs = akademik.mahasiswaAktif();
    final valid = akademik.krsValidMahasiswaAktif();
    final pending = akademik.krsPendingMahasiswaAktif();
    
    String status = 'Sedang Mengisi Draft';
    Color statusColor = AppColors.primaryLight;
    IconData icon = Icons.info_outline;

    if (valid.isNotEmpty) {
      status = 'Telah Divalidasi';
      statusColor = AppColors.success;
      icon = Icons.check_circle_outline;
    } else if (pending.isNotEmpty) {
      status = 'Diajukan (Menunggu Validasi)';
      statusColor = AppColors.primary;
      icon = Icons.access_time;
    } else if (mhs.catatanKrs != null) {
      status = 'Ditolak (Perlu Perbaikan)';
      statusColor = AppColors.error;
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Pengisian KRS', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivalidasiView() {
    final valid = akademik.krsValidMahasiswaAktif();
    final mhs = akademik.mahasiswaAktif();
    final dosenNama = akademik.namaPembimbingMahasiswaAktif();
    final prodi = AppData.daftarProdi.firstWhere((p) => p.kodeProdi == mhs.kodeProdi);
    int totalSks = valid.fold(0, (sum, n) => sum + n.sksMataKuliah);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Header
        _buildStatusHeader(),
        
        // Premium Kontrak Studi Document
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Document
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'KONTRAK STUDI MAHASISWA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'KARTU RENCANA STUDI YANG SAH DAN DIVALIDASI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Student & PA Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDocField('Nama Mahasiswa', mhs.namaLengkap),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildDocField('NIM', mhs.nim)),
                        Expanded(child: _buildDocField('Angkatan', '${mhs.angkatan}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDocField('Program Studi', prodi.namaProdi),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildDocField('Semester', 'Ganjil 2024/2025')),
                        Expanded(child: _buildDocField('Dosen PA', dosenNama.isNotEmpty ? dosenNama : '-')),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Table header
              Container(
                color: AppColors.bg,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('KODE & MATA KULIAH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                    Expanded(flex: 1, child: Text('SKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('KELAS & RUANGAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                  ],
                ),
              ),

              // Courses list
              ...valid.map((nilai) {
                final mk = akademik.mataKuliahByKode(nilai.kodeMataKuliah);
                final kls = AppData.daftarKelas.firstWhere((k) => k.id == nilai.idKelasKuliah);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mk.namaMataKuliah, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                            Text(mk.kodeMataKuliah, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${mk.jumlahSks}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kelas ${kls.namaKelas}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                            Text(kls.ruangan, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // SKS Summary
              Container(
                color: AppColors.bg,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL BEBAN STUDI',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    Text(
                      '$totalSks SKS',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Digital Stamp Sign
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VALIDASI DIGITAL DOSEN WALI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Disetujui secara digital oleh ${dosenNama.isNotEmpty ? dosenNama : 'Dosen Pembimbing'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kontrak studi ini merupakan dokumen resmi akademik yang sah sebagai bukti pengambilan beban studi mahasiswa pada semester berjalan.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPilihKelasView() {
  // If KRS already submitted (pending), do not allow adding more classes
  final pending = akademik.krsPendingMahasiswaAktif();
  if (pending.isNotEmpty) {
    return Center(
      child: Text(
        'KRS sudah diajukan, tidak dapat menambah mata kuliah lagi',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  final semuaKelasProdi = akademik.kelasUntukMahasiswaAktif();
  // Jangan munculkan kelas yang sudah lulus, valid, atau sedang diambil (draft/pending)
  final kelasSesuaiProdi = semuaKelasProdi.where((kelas) {
    final riwayat = akademik.riwayatMataKuliah(kelas.kodeMataKuliah);
    if (riwayat != null && (riwayat.nilaiAngka != null || riwayat.statusKrs == 'valid' || riwayat.statusKrs == 'draft' || riwayat.statusKrs == 'pending')) {
      return false;
    }
    return true;
  }).toList();

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _buildStatusHeader(),
      ...kelasSesuaiProdi.map((kelas) {
        final mataKuliah = akademik.mataKuliahByKode(kelas.kodeMataKuliah);
        final ruangan = _ruanganService.ruanganByKode(kelas.kodeRuangan);
        final namaRuangan = ruangan?.namaRuangan ?? 'Belum ditentukan';
        final dosenUtama = _dosenPengajarService.dosenUtamaKelas(kelas.id);

        final peserta = AppData.hitungPesertaKelas(kelas.id);
        final penuh = peserta >= kelas.kapasitas;

        Widget actionButton;
        if (penuh) {
          actionButton = const Text('Penuh', style: TextStyle(color: AppColors.gold));
        } else {
          actionButton = ElevatedButton(
            onPressed: () => _ambilDraft(kelas.id),
            child: const Text('Ambil'),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CyberPanel(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mataKuliah.kodeMataKuliah} - ${mataKuliah.namaMataKuliah} (Kelas ${kelas.namaKelas})',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text('SKS: ${mataKuliah.jumlahSks} | Dosen: $dosenUtama', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Ruangan: $namaRuangan', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text('Jadwal: ${kelas.hari}, ${kelas.jamMulai} - ${kelas.jamSelesai}', style: const TextStyle(color: AppColors.primaryLight, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                actionButton,
              ],
            ),
          ),
        );
      }),
    ],
  );
}

  Widget _buildDraftView() {
    final drafts = akademik.krsDraftMahasiswaAktif();
    final pending = akademik.krsPendingMahasiswaAktif();
    final gabungan = [...drafts, ...pending];
    int totalSks = gabungan.fold<int>(0, (sum, n) => sum + n.sksMataKuliah);

    if (gabungan.isEmpty) {
      return const Center(
        child: Text('Belum ada kelas yang disimpan ke KRS', style: TextStyle(color: AppColors.grey)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusHeader(),
              ...gabungan.map((nilai) {
                final kls = AppData.daftarKelas.firstWhere((k) => k.id == nilai.idKelasKuliah);
                final mk = akademik.mataKuliahByKode(nilai.kodeMataKuliah);
                final ruangan = _ruanganService.ruanganByKode(kls.kodeRuangan);
                final isDraft = nilai.statusKrs == 'draft';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CyberPanel(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${mk.namaMataKuliah} (${kls.namaKelas})', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${mk.jumlahSks} SKS | Ruangan: ${ruangan?.namaRuangan ?? '-'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('${kls.hari}, ${kls.jamMulai} - ${kls.jamSelesai}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('Status: ${nilai.statusKrs.toUpperCase()}', style: TextStyle(color: isDraft ? AppColors.primary : const Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (isDraft)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _batalDraft(kls.id),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(top: BorderSide(color: AppColors.primaryLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total SKS: $totalSks', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              if (drafts.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _ajukanKrs,
                  icon: const Icon(Icons.send),
                  label: const Text('Ajukan KRS'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final valid = akademik.krsValidMahasiswaAktif();
    final isDivalidasi = valid.isNotEmpty;
    final mhs = akademik.mahasiswaAktif();

    if (!mhs.isAktif) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_bad_rounded, size: 72, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Akses KRS Ditutup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Status kemahasiswaan Anda saat ini dinonaktifkan. Anda tidak diizinkan untuk melakukan pengisian KRS atau berkonsultasi rencana studi secara online. Silakan hubungi bagian administrasi akademik.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (!isDivalidasi) ...[
            if (mhs.catatanKrs != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Catatan Penolakan Dosen Pembimbing',
                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mhs.catatanKrs!,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Silakan perbaiki kelas pilihan Anda di bawah ini dan ajukan ulang.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            TabBar(
              tabs: const [
                Tab(text: 'Pilih Kelas'),
                Tab(text: 'Draft KRS'),
              ],
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
            ),
          ],
          Expanded(
            child: isDivalidasi
                ? _buildDivalidasiView()
                : TabBarView(
                    children: [
                      _buildPilihKelasView(),
                      _buildDraftView(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
