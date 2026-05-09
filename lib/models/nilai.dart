class Nilai {
  String nim;
  String idKelasKuliah;
  String kodeMataKuliah;
  String namaMataKuliah;
  int sksMataKuliah;
  double? nilaiAngka;
  String? nilaiHuruf;

  // draft | pending | valid
  String statusKrs;

  Nilai({
    required this.nim,
    required this.idKelasKuliah,
    required this.kodeMataKuliah,
    required this.namaMataKuliah,
    required this.sksMataKuliah,
    this.nilaiAngka,
    this.nilaiHuruf,
    this.statusKrs = 'draft',
  });
}