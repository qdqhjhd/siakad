import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class ValidasiKrsPage extends StatefulWidget {
  const ValidasiKrsPage({super.key});

  @override
  State<ValidasiKrsPage> createState() => _ValidasiKrsPageState();
}

class _ValidasiKrsPageState extends State<ValidasiKrsPage> {
  final akademik = const AkademikService();

  @override
  Widget build(BuildContext context) {
    final mahasiswaBimbingan = akademik.mahasiswaBimbinganDosenAktif();
    final pengajuan = akademik.pengajuanKrsDosenAktif();

    return CyberScaffold(
      appBar: AppBar(title: const Text('Validasi KRS Mahasiswa')),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CyberHeader(
            tag: '// Dosen Pembimbing',
            title: 'Validasi KRS',
            subtitle:
                '${pengajuan.length} pengajuan menunggu persetujuan dari ${mahasiswaBimbingan.length} mahasiswa bimbingan.',
            icon: Icons.fact_check,
          ),
          const SizedBox(height: 16),
          if (pengajuan.isEmpty)
            const CyberPanel(
              child: Text(
                'Belum ada KRS yang perlu divalidasi.',
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            ...pengajuan.map((nilai) {
              final mhs = AppData.daftarMahasiswa.firstWhere(
                (m) => m.nim == nilai.nim,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CyberPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.person, color: AppColors.accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mhs.namaLengkap,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NIM: ${mhs.nim}',
                                  style: const TextStyle(color: AppColors.grey),
                                ),
                                Text(
                                  '${nilai.kodeMataKuliah} - ${nilai.namaMataKuliah} (${nilai.sksMataKuliah} SKS)',
                                  style: const TextStyle(color: AppColors.grey),
                                ),
                                Text(
                                  'Status: ${nilai.statusKrs.toUpperCase()}',
                                  style: const TextStyle(color: AppColors.goldLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  akademik.tolakKrs(nilai);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'KRS ${mhs.namaLengkap} ditolak dan dikembalikan ke draft',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Tolak'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  akademik.validasiKrs(nilai);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'KRS ${mhs.namaLengkap} berhasil divalidasi',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Setujui'),
                            ),
                          ),
                        ],
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
