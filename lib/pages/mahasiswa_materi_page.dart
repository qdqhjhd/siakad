import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../services/materi_service.dart';
import '../models/kelas_kuliah.dart';
import '../models/mata_kuliah.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class MahasiswaMateriPage extends StatefulWidget {
  const MahasiswaMateriPage({super.key});

  @override
  State<MahasiswaMateriPage> createState() => _MahasiswaMateriPageState();
}

class _MahasiswaMateriPageState extends State<MahasiswaMateriPage> {
  final _materiService = const MateriService();
  KelasKuliah? _selectedKelas;

  @override
  Widget build(BuildContext context) {
    final nim = AppData.currentNim;
    
    // Get enrolled classes
    final enrolledClassIds = AppData.daftarNilai
        .where((n) => n.nim == nim && n.statusKrs == 'valid')
        .map((n) => n.idKelasKuliah)
        .toSet();

    final enrolledClasses = AppData.daftarKelas
        .where((k) => enrolledClassIds.contains(k.id))
        .toList();

    if (_selectedKelas != null) {
      return _buildKelasDetailView(_selectedKelas!);
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CyberHeader(
            tag: 'AKADEMIK',
            title: 'Silabus & Materi Kuliah',
            subtitle: 'Pilih mata kuliah Anda untuk melihat rencana silabus semester dan mengunduh materi dari Dosen.',
            icon: Icons.library_books,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: enrolledClasses.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada mata kuliah yang disetujui (KRS Valid) semester ini.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: enrolledClasses.length,
                    itemBuilder: (context, index) {
                      final kelas = enrolledClasses[index];
                      final mk = AppData.daftarMataKuliah.firstWhere(
                        (m) => m.kodeMataKuliah == kelas.kodeMataKuliah,
                        orElse: () => MataKuliah(kodeMataKuliah: '', namaMataKuliah: 'Mata Kuliah', jumlahSks: 0, kodeProdi: ''),
                      );

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedKelas = kelas;
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
                              Text(
                                'Dosen: ${kelas.dosenPengampu}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasDetailView(KelasKuliah kelas) {
    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
    final syllabus = _materiService.rencanaPadaKelas(kelas.id);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _selectedKelas = null;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mk.namaMataKuliah,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Kelas ${kelas.namaKelas} • Dosen: ${kelas.dosenPengampu}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: syllabus.length,
              itemBuilder: (context, index) {
                final item = syllabus[index];
                
                // Get uploaded materials
                final materis = _materiService.materiPadaMinggu(kelas.id, item.minggu);
                final materi = materis.isNotEmpty ? materis.first : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CyberPanel(
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(side: BorderSide.none),
                      leading: CircleAvatar(
                        backgroundColor: (item.sudahDibahas ? AppColors.success : AppColors.grey).withValues(alpha: 0.1),
                        child: Text(
                          '${item.minggu}',
                          style: TextStyle(
                            color: item.sudahDibahas ? AppColors.success : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        materi?.judulBab ?? item.judulBab,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        materi != null ? 'Materi Terlampir' : 'Silabus: ${item.subBab}',
                        style: TextStyle(
                          color: materi != null ? AppColors.primaryLight : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (item.sudahDibahas ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.sudahDibahas ? 'Selesai' : 'Belum Dibahas',
                          style: TextStyle(
                            color: item.sudahDibahas ? AppColors.success : AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Penjelasan Materi:',
                                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                materi?.deskripsiBab ?? (item.subBab.isNotEmpty ? item.subBab : 'Belum ada penjelasan sub bab.'),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                              ),
                              if (materi != null && materi.files.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'File Lampiran:',
                                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ...materi.files.map((file) {
                                  IconData icon = Icons.insert_drive_file;
                                  if (file.tipe == 'pdf') icon = Icons.picture_as_pdf;
                                  if (file.tipe == 'ppt') icon = Icons.slideshow;
                                  if (file.tipe == 'link') icon = Icons.link;

                                  return Card(
                                    color: AppColors.surface,
                                    margin: const EdgeInsets.only(bottom: 6),
                                    child: ListTile(
                                      leading: Icon(icon, color: AppColors.primary, size: 20),
                                      title: Text(
                                        file.nama,
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        file.url,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Mengunduh ${file.nama}...'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 11),
                                        ),
                                        child: const Text('Buka'),
                                      ),
                                    ),
                                  );
                                }),
                              ],
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
      ),
    );
  }
}
