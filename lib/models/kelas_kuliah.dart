class KelasKuliah {
  String id;
  String kodeSemester;
  String kodeProdi;
  String kodeMataKuliah;
  String namaKelas;
  int kapasitas;
  int jumlahPeserta;
  String dosenPengampu;
  String jadwal;

  // Jadwal terstruktur
  String hari;        // 'Senin' | 'Selasa' | 'Rabu' | 'Kamis' | 'Jumat'
  String jamMulai;    // e.g. '08:00'
  String jamSelesai;  // e.g. '10:30'
  String ruangan;     // e.g. 'R101'
  String kodeRuangan; // Relasi ke model Ruangan

  KelasKuliah({
    required this.id,
    required this.kodeSemester,
    required this.kodeProdi,
    required this.kodeMataKuliah,
    required this.namaKelas,
    required this.kapasitas,
    this.jumlahPeserta = 0,
    required this.dosenPengampu,
    required this.jadwal,
    this.hari = '',
    this.jamMulai = '',
    this.jamSelesai = '',
    this.ruangan = '',
    this.kodeRuangan = '',
  });
}