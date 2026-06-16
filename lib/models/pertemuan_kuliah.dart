class PertemuanKuliah {
  final String id;
  final int nomorPertemuan; // 1 - 16
  final DateTime tanggal;
  final String idKelasKuliah;
  String statusSesi; // 'aktif' | 'tutup'
  final String? catatan;

  PertemuanKuliah({
    required this.id,
    required this.nomorPertemuan,
    required this.tanggal,
    required this.idKelasKuliah,
    required this.statusSesi,
    this.catatan,
  });
}
