import 'package:flutter/material.dart';
import '../models/ruangan.dart';
import '../services/ruangan_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class RuanganPage extends StatefulWidget {
  const RuanganPage({super.key});

  @override
  State<RuanganPage> createState() => _RuanganPageState();
}

class _RuanganPageState extends State<RuanganPage> {
  final _ruanganService = const RuanganService();
  late List<Ruangan> _ruanganList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _ruanganList = List.from(_ruanganService.semuaRuangan());
    });
  }

  void _showFormDialog({Ruangan? ruangan}) {
    final isEdit = ruangan != null;
    final kodeController = TextEditingController(text: ruangan?.kodeRuangan);
    final namaController = TextEditingController(text: ruangan?.namaRuangan);
    final kapasitasController = TextEditingController(text: ruangan?.kapasitasRuangan.toString());
    final lokasiController = TextEditingController(text: ruangan?.lokasi);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isEdit ? 'Edit Ruangan' : 'Tambah Ruangan', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kodeController,
                decoration: const InputDecoration(labelText: 'Kode Ruangan'),
                enabled: !isEdit,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Ruangan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kapasitasController,
                decoration: const InputDecoration(labelText: 'Kapasitas Ruangan'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi/Gedung'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (kodeController.text.isEmpty || namaController.text.isEmpty || kapasitasController.text.isEmpty || lokasiController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
                return;
              }

              final kapasitas = int.tryParse(kapasitasController.text);
              if (kapasitas == null || kapasitas <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kapasitas tidak valid')));
                return;
              }

              final newRuangan = Ruangan(
                kodeRuangan: kodeController.text,
                namaRuangan: namaController.text,
                kapasitasRuangan: kapasitas,
                lokasi: lokasiController.text,
              );

              if (isEdit) {
                _ruanganService.updateRuangan(ruangan.kodeRuangan, newRuangan);
                _loadData();
                Navigator.pop(ctx);
              } else {
                final error = _ruanganService.tambahRuangan(newRuangan);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else {
                  _loadData();
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _hapusRuangan(Ruangan ruangan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Ruangan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin menghapus ruangan ${ruangan.namaRuangan}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final error = _ruanganService.hapusRuangan(ruangan.kodeRuangan);
              Navigator.pop(ctx);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              } else {
                _loadData();
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CyberHeader(
          tag: 'MANAJEMEN',
          title: 'Kelola Ruangan',
          subtitle: 'Tambah, ubah, dan hapus data ruangan perkuliahan',
          icon: Icons.meeting_room_rounded,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daftar Ruangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ElevatedButton.icon(
              onPressed: () => _showFormDialog(),
              icon: const Icon(Icons.add),
              label: const Text('+ Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _ruanganList.length,
            itemBuilder: (context, index) {
              final ruangan = _ruanganList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: CyberPanel(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.door_front_door_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[${ruangan.kodeRuangan}] ${ruangan.namaRuangan}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lokasi: ${ruangan.lokasi}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_rounded, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              '${ruangan.kapasitasRuangan}',
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                        onPressed: () => _showFormDialog(ruangan: ruangan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () => _hapusRuangan(ruangan),
                      ),
                    ],
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
