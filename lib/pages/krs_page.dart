import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class KrsPage extends StatefulWidget {
  const KrsPage({super.key});

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> {
  final akademik = const AkademikService();

  void ambilDraft(String idKelas) {
    final kelas = AppData.daftarKelas.firstWhere((k) => k.id == idKelas);

    if (akademik.sudahAmbilKelas(kelas.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas ini sudah ada di KRS kamu')),
      );
      return;
    }

    if (akademik.kelasPenuh(kelas)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas penuh')),
      );
      return;
    }

    setState(() => akademik.ambilDraft(kelas.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kelas berhasil masuk draft KRS')),
    );
  }

  void kirimKrs() {
    final draft = akademik.krsDraftMahasiswaAktif();

    if (draft.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada draft KRS yang bisa dikirim')),
      );
      return;
    }

    setState(() => akademik.kirimKrs());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KRS dikirim ke dosen pembimbing')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswa = akademik.mahasiswaAktif();
    final kelasSesuaiProdi = akademik.kelasUntukMahasiswaAktif();
    final draft = akademik.krsDraftMahasiswaAktif();
    final pending = akademik.krsPendingMahasiswaAktif();
    final valid = akademik.krsValidMahasiswaAktif();
    final pembimbing = akademik.namaPembimbingMahasiswaAktif();

    return CyberScaffold(
      appBar: AppBar(title: const Text('Kartu Rencana Studi')),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CyberHeader(
            tag: '// KRS Mahasiswa',
            title: mahasiswa.namaLengkap,
            subtitle: 'Dosen Pembimbing: ${pembimbing.isEmpty ? '-' : pembimbing}',
            icon: Icons.fact_check,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatTile(value: '${draft.length}', label: 'Draft')),
              const SizedBox(width: 10),
              Expanded(child: StatTile(value: '${pending.length}', label: 'Pending')),
              const SizedBox(width: 10),
              Expanded(child: StatTile(value: '${valid.length}', label: 'Valid')),
            ],
          ),
          const SizedBox(height: 16),
          if (draft.isNotEmpty)
            CyberPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Draft KRS siap dikirim ke pembimbing.',
                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: kirimKrs,
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim ke Dosen Pembimbing'),
                    ),
                  ),
                ],
              ),
            ),
          if (draft.isNotEmpty) const SizedBox(height: 16),
          if (kelasSesuaiProdi.isEmpty)
            const CyberPanel(
              child: Text(
                'Belum ada kelas kuliah di prodi kamu',
                style: TextStyle(color: AppColors.text),
              ),
            )
          else
            ...kelasSesuaiProdi.map((kelas) {
              final mataKuliah = akademik.mataKuliahByKode(kelas.kodeMataKuliah);
              final peserta = AppData.hitungPesertaKelas(kelas.id);
              final nilaiKrs = akademik.nilaiKrsMahasiswaAktif(kelas.id);
              final sudahAmbil = nilaiKrs != null;
              final penuh = peserta >= kelas.kapasitas;
              final status = nilaiKrs?.statusKrs ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CyberPanel(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.accent),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mataKuliah.namaMataKuliah,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${mataKuliah.kodeMataKuliah} - ${mataKuliah.jumlahSks} SKS - Kelas ${kelas.namaKelas}',
                              style: const TextStyle(color: AppColors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dosen: ${kelas.dosenPengampu}',
                              style: const TextStyle(color: AppColors.grey),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: peserta / kelas.kapasitas,
                              minHeight: 5,
                              color: penuh ? AppColors.gold : AppColors.accent,
                              backgroundColor: AppColors.cyan.withValues(alpha: 0.12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Kapasitas valid: $peserta/${kelas.kapasitas}',
                              style: const TextStyle(color: AppColors.grey, fontSize: 12),
                            ),
                            if (sudahAmbil) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Status KRS: ${status.toUpperCase()}',
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: sudahAmbil || penuh ? null : () => ambilDraft(kelas.id),
                        child: Text(
                          sudahAmbil
                              ? status.toUpperCase()
                              : penuh
                                  ? 'Penuh'
                                  : 'Ambil',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
