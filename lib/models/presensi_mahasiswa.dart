class PresensiMahasiswa {
  final String id;
  final String idPertemuan;
  final String nim;
  String status; // 'Hadir' | 'Izin' | 'Sakit' | 'Alfa'
  final DateTime? waktuPresensi;
  final String? catatan;

  PresensiMahasiswa({
    required this.id,
    required this.idPertemuan,
    required this.nim,
    required this.status,
    this.waktuPresensi,
    this.catatan,
  });
}
