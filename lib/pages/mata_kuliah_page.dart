import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/mata_kuliah.dart';
import '../services/mata_kuliah_service.dart';

class MataKuliahPage extends StatefulWidget {
  const MataKuliahPage({super.key});

  @override
  State<MataKuliahPage> createState() => _MataKuliahPageState();
}

class _MataKuliahPageState extends State<MataKuliahPage> {
  final MataKuliahService _mataKuliahService = const MataKuliahService();

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

              final newMk = MataKuliah(
                kodeMataKuliah: kode.text,
                namaMataKuliah: nama.text,
                jumlahSks: int.parse(sks.text),
                kodeProdi: kodeProdi,
              );

              setState(() {
                if (mataKuliah == null) {
                  final error = _mataKuliahService.tambahMataKuliah(newMk);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                } else {
                  final oldKode = AppData.daftarMataKuliah[index!].kodeMataKuliah;
                  _mataKuliahService.updateMataKuliah(oldKode, newMk);
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
    final error = _mataKuliahService.hapusMataKuliah(kodeMataKuliah);
    
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() {});
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
                          onPressed: () => formMataKuliah(mataKuliah: m, index: realIndex),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => formMataKuliah(),
        icon: const Icon(Icons.add),
        label: const Text('+ Tambah'),
      ),
    );
  }
}
