import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/dosen.dart';
import '../theme/app_colors.dart';

class AdminDosenPage extends StatefulWidget {
  const AdminDosenPage({super.key});

  @override
  State<AdminDosenPage> createState() => _AdminDosenPageState();
}

class _AdminDosenPageState extends State<AdminDosenPage> {
  void formDosen({Dosen? dosen, int? index}) {
    final nidnController = TextEditingController(text: dosen?.nidn ?? '');
    final namaController = TextEditingController(text: dosen?.nama ?? '');

    String kodeProdi = dosen?.kodeProdi ?? AppData.daftarProdi.first.kodeProdi;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          dosen == null ? 'Tambah Dosen' : 'Edit Dosen',
          style: const TextStyle(color: AppColors.primaryLight),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nidnController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'NIDN',
                    labelStyle: TextStyle(color: AppColors.primaryLight),
                  ),
                ),
                TextField(
                  controller: namaController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Nama Dosen',
                    labelStyle: TextStyle(color: AppColors.primaryLight),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: kodeProdi,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Prodi',
                    labelStyle: TextStyle(color: AppColors.primaryLight),
                  ),
                  items: AppData.daftarProdi.map((prodi) {
                    return DropdownMenuItem(
                      value: prodi.kodeProdi,
                      child: Text(prodi.namaProdi),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      kodeProdi = value!;
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
            child: const Text('Batal', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (nidnController.text.isEmpty || namaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data wajib diisi')),
                );
                return;
              }

              setState(() {
                if (dosen == null) {
                  AppData.daftarDosen.add(
                    Dosen(
                      nidn: nidnController.text,
                      nama: namaController.text,
                      kodeProdi: kodeProdi,
                    ),
                  );
                } else {
                  AppData.daftarDosen[index!].nidn = nidnController.text;
                  AppData.daftarDosen[index].nama = namaController.text;
                  AppData.daftarDosen[index].kodeProdi = kodeProdi;
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void hapusDosen(int index) {
    final dosen = AppData.daftarDosen[index];

    final sedangMengajar = AppData.daftarDosenPengajar.any(
      (dp) => dp.nidnDosen == dosen.nidn,
    );

    if (sedangMengajar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dosen tidak bisa dihapus karena sedang mengajar kelas',
          ),
        ),
      );
      return;
    }

    setState(() {
      AppData.daftarDosen.removeAt(index);
    });
  }

  List<Dosen> getDosenMengajar() {
    // Return list of dosen who are assigned to teach classes
    return AppData.daftarDosen.where((dosen) {
      return AppData.daftarDosenPengajar.any((dp) => dp.nidnDosen == dosen.nidn);
    }).toList();
  }

  // Helper to get program name from kodeProdi
  String getNamaProdi(String kodeProdi) {
    final prodi = AppData.daftarProdi.firstWhere(
      (p) => p.kodeProdi == kodeProdi,
      orElse: () => AppData.daftarProdi.first,
    );
    return prodi.namaProdi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: getDosenMengajar().isEmpty
          ? const Center(
              child: Text(
                'Belum ada data dosen',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: getDosenMengajar().length,
              itemBuilder: (context, index) {
                final dosen = getDosenMengajar()[index];

                return Card(
                  color: AppColors.surface,
                  elevation: 10,
                  shadowColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.primaryLight, width: 0.8),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    title: Text(
                      dosen.nama,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'NIDN: ${dosen.nidn}\nProdi: ${getNamaProdi(dosen.kodeProdi)}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              formDosen(dosen: dosen, index: index),
                          icon: const Icon(Icons.edit, color: AppColors.primaryLight),
                        ),
                        IconButton(
                          onPressed: () => hapusDosen(index),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryLight,
        onPressed: () => formDosen(),
        icon: const Icon(Icons.add),
        label: const Text('+ Tambah'),
      ),
    );
  }
}
