import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/dosen_pengajar.dart';
import '../services/dosen_pengajar_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class DosenPengajarPage extends StatefulWidget {
  const DosenPengajarPage({super.key});

  @override
  State<DosenPengajarPage> createState() => _DosenPengajarPageState();
}

class _DosenPengajarPageState extends State<DosenPengajarPage> {
  final _dosenPengajarService = const DosenPengajarService();
  late List<DosenPengajar> _dosenPengajarList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      final all = _dosenPengajarService.semuaDosenPengajar();
      if (AppData.currentAdminProdiKode.isNotEmpty) {
        _dosenPengajarList = all.where((dp) {
          final dosen = _dosenPengajarService.dosenByNidn(dp.nidnDosen);
          return dosen?.kodeProdi == AppData.currentAdminProdiKode;
        }).toList();
      } else {
        _dosenPengajarList = all;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kita akan group berdasarkan Dosen
    final Map<String, List<DosenPengajar>> groupedByDosen = {};
    for (var dp in _dosenPengajarList) {
      if (!groupedByDosen.containsKey(dp.nidnDosen)) {
        groupedByDosen[dp.nidnDosen] = [];
      }
      groupedByDosen[dp.nidnDosen]!.add(dp);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CyberHeader(
          tag: 'AKADEMIK',
          title: 'Daftar Dosen Pengajar',
          subtitle: 'Lihat daftar dosen dan kelas yang diajar',
          icon: Icons.person_search_rounded,
        ),
        const SizedBox(height: 20),
        const Text('Daftar Dosen & Jadwal Mengajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: groupedByDosen.keys.length,
            itemBuilder: (context, index) {
              final nidn = groupedByDosen.keys.elementAt(index);
              final dosen = _dosenPengajarService.dosenByNidn(nidn);
              final dpList = groupedByDosen[nidn]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: CyberPanel(
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(
                      dosen?.nama ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: Text('Mengajar ${dpList.length} Kelas', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    children: dpList.map((dp) {
                      // Get kelas details
                      final kelas = AppData.daftarKelas.firstWhere((k) => k.id == dp.idKelas);
                      final mataKuliah = AppData.daftarMataKuliah.firstWhere((mk) => mk.kodeMataKuliah == kelas.kodeMataKuliah);
                      final ruangan = AppData.daftarRuangan.firstWhere((r) => r.kodeRuangan == kelas.kodeRuangan, orElse: () => AppData.daftarRuangan.first);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.class_outlined, color: AppColors.textSecondary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mataKuliah.namaMataKuliah,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kelas: ${kelas.namaKelas} | Ruangan: ${ruangan.namaRuangan}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Jadwal: ${kelas.hari}, ${kelas.jamMulai} - ${kelas.jamSelesai}',
                                    style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.surfaceLayer, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                dp.peranMengajar,
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
