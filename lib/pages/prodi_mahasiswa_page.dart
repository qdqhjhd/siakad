import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/dosen.dart';
import '../theme/app_colors.dart';
import '../services/akademik_service.dart';
import '../widgets/cyber_widgets.dart';
class ProdiMahasiswaPage extends StatefulWidget {
  const ProdiMahasiswaPage({super.key});

  @override
  State<ProdiMahasiswaPage> createState() => _ProdiMahasiswaPageState();
}

class _ProdiMahasiswaPageState extends State<ProdiMahasiswaPage> {
  final akademik = const AkademikService();
  void _pilihDosenPa(int index, String? currentDosenNidn) {
    final mahasiswaProdi = AppData.daftarMahasiswa
        .where((m) => m.kodeProdi == AppData.currentAdminProdiKode)
        .toList();
    final mhs = mahasiswaProdi[index];
    final dosenProdi = AppData.daftarDosen
        .where((d) => d.kodeProdi == AppData.currentAdminProdiKode)
        .toList();

    String? selectedNidn = currentDosenNidn;
    if (selectedNidn != null) {
      if (selectedNidn.startsWith('DSN')) {
        selectedNidn = selectedNidn.replaceFirst('DSN', 'D');
      }
      if (!dosenProdi.any((d) => d.nidn == selectedNidn)) {
        selectedNidn = null;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B132B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Tentukan Dosen PA\n${mhs.namaLengkap}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Dosen Pembimbing Akademik:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedNidn,
                    dropdownColor: const Color(0xFF0B132B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1C2541),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3A506B)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.cyanAccent),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Belum ditentukan (Kosong)', style: TextStyle(color: Colors.redAccent)),
                      ),
                      ...dosenProdi.map((dosen) {
                        return DropdownMenuItem<String?>(
                          value: dosen.nidn,
                          child: Text(dosen.nama, style: const TextStyle(color: Colors.white)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedNidn = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                  // Update advisor using service to ensure synchronization across logic
                  akademik.updateDosenPembimbing(mhs.nim, selectedNidn);
                  // Also update local model for immediate UI reflect
                  mhs.dosenPembimbingNidn = selectedNidn;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dosen PA untuk ${mhs.namaLengkap} berhasil diperbarui'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswaProdi = AppData.daftarMahasiswa
        .where((m) => m.kodeProdi == AppData.currentAdminProdiKode)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: mahasiswaProdi.isEmpty
          ? const Center(
              child: Text(
                'Belum ada mahasiswa di prodi ini',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mahasiswaProdi.length,
              itemBuilder: (context, index) {
                final mhs = mahasiswaProdi[index];
                
                final dosenPa = AppData.daftarDosen.firstWhere(
                  (d) => d.nidn == mhs.dosenPembimbingNidn,
                  orElse: () => Dosen(nidn: '', nama: 'Belum ditentukan', kodeProdi: ''),
                );

                final hasDosenPa = mhs.dosenPembimbingNidn != null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CyberPanel(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: hasDosenPa ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gold.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: hasDosenPa ? AppColors.primary : AppColors.gold,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              mhs.namaLengkap,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: mhs.isAktif ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: mhs.isAktif ? Colors.green : Colors.red,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              mhs.isAktif ? 'Aktif' : 'Tidak Aktif',
                              style: TextStyle(
                                color: mhs.isAktif ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'NIM: ${mhs.nim}  •  Angkatan: ${mhs.angkatan}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Dosen PA: ',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              Expanded(
                                child: Text(
                                  dosenPa.nama,
                                  style: TextStyle(
                                    color: hasDosenPa ? AppColors.primaryLight : AppColors.goldLight,
                                    fontWeight: hasDosenPa ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.assignment_ind_rounded, color: AppColors.primary),
                        tooltip: 'Tentukan Dosen PA',
                        onPressed: () => _pilihDosenPa(index, mhs.dosenPembimbingNidn),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
