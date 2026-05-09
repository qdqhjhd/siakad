class Mahasiswa {
  String nim;
  String namaLengkap;
  bool jk; // true = Perempuan, false = Laki-laki
  String kodeProdi;
  DateTime tanggalLahir;
  int angkatan;
  String? dosenPembimbingNidn;

  Mahasiswa({
    required this.nim,
    required this.namaLengkap,
    required this.jk,
    required this.kodeProdi,
    required this.tanggalLahir,
    required this.angkatan,
    this.dosenPembimbingNidn,
  });

  String get strJk {
    return jk == true ? 'Perempuan' : 'Laki-laki';
  }
}
