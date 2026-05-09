class KelasKuliah {
  String id;
  String kodeSemester;
  String kodeProdi;
  String kodeMataKuliah;
  String namaKelas;
  int kapasitas;
  int jumlahPeserta;
  String dosenPengampu;

  KelasKuliah({
    required this.id,
    required this.kodeSemester,
    required this.kodeProdi,
    required this.kodeMataKuliah,
    required this.namaKelas,
    required this.kapasitas,
    this.jumlahPeserta = 0,
    required this.dosenPengampu,
  });
}