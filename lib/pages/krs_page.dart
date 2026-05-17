import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class KrsPage extends StatefulWidget {
  const KrsPage({super.key});

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> {
  final akademik = const AkademikService();

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
    final valid = akademik.krsValidMahasiswaAktif();
    final pending = akademik.krsPendingMahasiswaAktif();
    
    String status = 'Sedang Mengisi Draft';
    if (valid.isNotEmpty) {
      status = 'Telah Divalidasi';
    } else if (pending.isNotEmpty) {
      status = 'Diajukan (Menunggu Validasi)';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Pengisian KRS', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
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
    int totalSks = valid.fold(0, (sum, n) => sum + n.sksMataKuliah);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusHeader(),
        const CyberPanel(
          child: Text(
            'KRS Anda telah divalidasi oleh Dosen Pembimbing Akademik dan tidak dapat diubah lagi.',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
        const SizedBox(height: 16),
        CyberPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Mata Kuliah', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                      child: Text('$totalSks SKS', style: const TextStyle(color: AppColors.bg, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  dataTextStyle: const TextStyle(color: AppColors.textPrimary),
                  columns: const [
                    DataColumn(label: Text('Kode')),
                    DataColumn(label: Text('Mata Kuliah')),
                    DataColumn(label: Text('SKS')),
                    DataColumn(label: Text('Jadwal')),
                  ],
                  rows: valid.map((nilai) {
                    final mk = akademik.mataKuliahByKode(nilai.kodeMataKuliah);
                    final kls = AppData.daftarKelas.firstWhere((k) => k.id == nilai.idKelasKuliah);
                    return DataRow(
                      cells: [
                        DataCell(Text(mk.kodeMataKuliah)),
                        DataCell(Text('${mk.namaMataKuliah} (${kls.namaKelas})')),
                        DataCell(Text('${mk.jumlahSks}')),
                        DataCell(Text(kls.jadwal)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPilihKelasView() {
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
                        Text('SKS: ${mataKuliah.jumlahSks} | Dosen: ${kelas.dosenPengampu}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Jadwal: ${kelas.jadwal}', style: const TextStyle(color: AppColors.primaryLight, fontSize: 12)),
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
    int totalSks = gabungan.fold(0, (sum, n) => sum + n.sksMataKuliah);

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
                              Text('${mk.jumlahSks} SKS | ${kls.jadwal}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('Status: ${nilai.statusKrs.toUpperCase()}', style: TextStyle(color: isDraft ? AppColors.white : AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.bold)),
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

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (!isDivalidasi)
            TabBar(
              tabs: const [
                Tab(text: 'Pilih Kelas'),
                Tab(text: 'Draft KRS'),
              ],
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
            ),
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
