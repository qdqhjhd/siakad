class Mahasiswa {
  String nim;
  String namaLengkap;
  bool jk; // true = Perempuan, false = Laki-laki
  String kodeProdi;
  DateTime tanggalLahir;
  int angkatan;
  bool isAktif; // true = Aktif, false = Tidak Aktif
  String? dosenPembimbingNidn;
  String? catatanKrs;

  Mahasiswa({
    required this.nim,
    required this.namaLengkap,
    required this.jk,
    required this.kodeProdi,
    required this.tanggalLahir,
    required this.angkatan,
    this.isAktif = true,
    this.dosenPembimbingNidn,
    this.catatanKrs,
  });

  String get strJk {
    return jk == true ? 'Perempuan' : 'Laki-laki';
  }

  String get strStatus {
    return isAktif ? 'Aktif' : 'Tidak Aktif';
  }
}
