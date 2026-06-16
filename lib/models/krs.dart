class KRS {
  final String nim;
  final String idKelasKuliah;
  final String statusKrs; // 'draft' | 'pending' | 'valid'
  final String? catatan;

  KRS({
    required this.nim,
    required this.idKelasKuliah,
    required this.statusKrs,
    this.catatan,
  });
}
