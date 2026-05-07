class Mahasiswa {
  String nim;
  String namaLengkap;
  bool jk; // true = Perempuan, false = Laki-laki
  String kodeProdi;
  DateTime tanggalLahir;
  int angkatan;

  Mahasiswa({
    required this.nim,
    required this.namaLengkap,
    required this.jk,
    required this.kodeProdi,
    required this.tanggalLahir,
    required this.angkatan,
  });

  String get strJk {
    return jk == true ? 'Perempuan' : 'Laki-laki';
  }
}
