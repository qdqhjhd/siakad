import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/prodi.dart';
import '../services/prodi_service.dart';

class ProdiPage extends StatefulWidget {
  const ProdiPage({super.key});

  @override
  State<ProdiPage> createState() => _ProdiPageState();
}

class _ProdiPageState extends State<ProdiPage> {
  final ProdiService _prodiService = const ProdiService();

  void formProdi({Prodi? prodi, int? index}) {
    final kodeController = TextEditingController(text: prodi?.kodeProdi ?? '');
    final namaController = TextEditingController(text: prodi?.namaProdi ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(prodi == null ? 'Tambah Prodi' : 'Edit Prodi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeController,
              decoration: const InputDecoration(labelText: 'Kode Prodi'),
            ),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Prodi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newProdi = Prodi(
                kodeProdi: kodeController.text,
                namaProdi: namaController.text,
                aliasProdi: kodeController.text,
              );
              setState(() {
                if (prodi == null) {
                  final error = _prodiService.tambahProdi(newProdi);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                } else {
                  final oldKode = AppData.daftarProdi[index!].kodeProdi;
                  _prodiService.updateProdi(oldKode, newProdi);
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

  void hapusProdi(int index) {
    final prodi = AppData.daftarProdi[index];
    final error = _prodiService.hapusProdi(prodi.kodeProdi);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppData.daftarProdi.isEmpty
          ? const Center(child: Text('Belum ada data prodi'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: AppData.daftarProdi.length,
              itemBuilder: (context, index) {
                final prodi = AppData.daftarProdi[index];

                return Card(
                  child: ListTile(
                    title: Text(prodi.namaProdi),
                    subtitle: Text('Kode Prodi: ${prodi.kodeProdi}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              formProdi(prodi: prodi, index: index),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => hapusProdi(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => formProdi(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
