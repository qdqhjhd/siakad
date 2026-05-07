import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/mata_kuliah.dart';

class MataKuliahPage extends StatefulWidget {
  const MataKuliahPage({super.key});

  @override
  State<MataKuliahPage> createState() => _MataKuliahPageState();
}

class _MataKuliahPageState extends State<MataKuliahPage> {
  void formMataKuliah({MataKuliah? mataKuliah, int? index}) {
    final kode = TextEditingController(text: mataKuliah?.kodeMataKuliah ?? '');
    final nama = TextEditingController(text: mataKuliah?.namaMataKuliah ?? '');
    final sks = TextEditingController(
      text: mataKuliah?.jumlahSks.toString() ?? '',
    );
    String kodeProdi = mataKuliah?.kodeProdi ??
        (AppData.currentAdminProdiKode.isEmpty
            ? ''
            : AppData.currentAdminProdiKode);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          mataKuliah == null ? 'Tambah Mata Kuliah' : 'Edit Mata Kuliah',
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (AppData.currentAdminProdiKode.isEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: kodeProdi.isEmpty ? null : kodeProdi,
                    decoration: const InputDecoration(labelText: 'Prodi'),
                    items: AppData.daftarProdi.map((prodi) {
                      return DropdownMenuItem(
                        value: prodi.kodeProdi,
                        child: Text(prodi.namaProdi),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        kodeProdi = value ?? '';
                      });
                    },
                  ),
                TextField(
                  controller: kode,
                  decoration: const InputDecoration(labelText: 'Kode Mata Kuliah'),
                ),
                TextField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
                ),
                TextField(
                  controller: sks,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah SKS'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (kodeProdi.isEmpty ||
                  kode.text.isEmpty ||
                  nama.text.isEmpty ||
                  sks.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data wajib diisi')),
                );
                return;
              }

              setState(() {
                if (mataKuliah == null) {
                  AppData.daftarMataKuliah.add(
                    MataKuliah(
                      kodeMataKuliah: kode.text,
                      namaMataKuliah: nama.text,
                      jumlahSks: int.parse(sks.text),
                      kodeProdi: kodeProdi,
                    ),
                  );
                } else {
                  AppData.daftarMataKuliah[index!].kodeMataKuliah = kode.text;
                  AppData.daftarMataKuliah[index].namaMataKuliah = nama.text;
                  AppData.daftarMataKuliah[index].jumlahSks = int.parse(
                    sks.text,
                  );
                  AppData.daftarMataKuliah[index].kodeProdi = kodeProdi;
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

  void hapusMataKuliah(String kodeMataKuliah) {
    final sudahAdaKelas = AppData.daftarKelas.any(
      (kelas) => kelas.kodeMataKuliah == kodeMataKuliah,
    );

    if (sudahAdaKelas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mata kuliah tidak bisa dihapus karena sudah dipakai di kelas',
          ),
        ),
      );
      return;
    }

    setState(() {
      AppData.daftarMataKuliah.removeWhere(
        (mk) => mk.kodeMataKuliah == kodeMataKuliah,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.currentAdminProdiKode.isEmpty
        ? AppData.daftarMataKuliah
        : AppData.daftarMataKuliah
            .where((m) => m.kodeProdi == AppData.currentAdminProdiKode)
            .toList();

    return Scaffold(
      body: data.isEmpty
          ? const Center(child: Text('Belum ada mata kuliah'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final m = data[i];
                final realIndex = AppData.daftarMataKuliah.indexWhere(
                  (mk) => mk.kodeMataKuliah == m.kodeMataKuliah,
                );

                return Card(
                  child: ListTile(
                    title: Text(m.namaMataKuliah),
                    subtitle: Text(
                      'Kode: ${m.kodeMataKuliah}\n'
                      'SKS: ${m.jumlahSks}\n'
                      'Prodi: ${m.kodeProdi}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              formMataKuliah(mataKuliah: m, index: realIndex),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => hapusMataKuliah(m.kodeMataKuliah),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => formMataKuliah(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
