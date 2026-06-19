/// Rencana materi satu pertemuan (per minggu) dalam 1 semester
class RencanaMateri {
  int? id;
  String? idKelasKuliah;
  int minggu;
  String judulBab;
  String subBab;
  bool sudahDibahas;

  RencanaMateri({
    this.id,
    this.idKelasKuliah,
    required this.minggu,
    required this.judulBab,
    required this.subBab,
    this.sudahDibahas = false,
  });
}

/// Materi/file yang diunggah dosen pada pertemuan tertentu
class MateriKuliah {
  final String id;
  final String idKelasKuliah;
  final int minggu;
  String judulBab;
  String deskripsiBab;
  final List<MateriFile> files;
  final DateTime createdAt;

  MateriKuliah({
    required this.id,
    required this.idKelasKuliah,
    required this.minggu,
    required this.judulBab,
    required this.deskripsiBab,
    List<MateriFile>? files,
    DateTime? createdAt,
  })  : files = files ?? [],
        createdAt = createdAt ?? DateTime.now();
}

/// File/lampiran materi
class MateriFile {
  int? id;
  String? idMateri;
  final String nama;
  final String tipe; // 'pdf' | 'ppt' | 'docx' | 'link' | 'image'
  final String url;

  MateriFile({
    this.id,
    this.idMateri,
    required this.nama,
    required this.tipe,
    required this.url,
  });
}
