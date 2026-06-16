import '../models/dosen.dart';
import '../models/kelas_kuliah.dart';
import '../models/mahasiswa.dart';
import '../models/mata_kuliah.dart';
import '../models/nilai.dart';
import '../models/prodi.dart';
import '../models/user.dart';
import '../models/ruangan.dart';
import '../models/dosen_pengajar.dart';
import '../models/jadwal_kuliah.dart';
import '../models/krs.dart';
import '../models/pertemuan_kuliah.dart';
import '../models/presensi_mahasiswa.dart';
import '../models/presensi_dosen.dart';
import '../models/jadwal_krs.dart';

class AppData {
  static String currentNim = '2024010001';

  static String currentDosenNama = '';
  static String currentDosenNidn = '';
  static String currentDosenProdi = '';
  static String currentAdminProdiKode = '';
  static String currentAdminProdiNama = '';
  static String semesterAktif = '20241';
  
  static int hitungPesertaKelas(String idKelas) {
  return daftarNilai.where(
    (nilai) =>
        nilai.idKelasKuliah == idKelas &&
        nilai.statusKrs == 'valid',
  ).length;
}

static int hitungPesertaKelasValid(String idKelas) {
  return daftarNilai.where(
    (nilai) =>
        nilai.idKelasKuliah == idKelas &&
        nilai.statusKrs == 'valid',
  ).length;
}

  static List<Prodi> daftarProdi = [
    Prodi(
      kodeProdi: 'ILKOM-01',
      namaProdi: 'Ilmu Komputer',
      aliasProdi: 'ILKOM',
    ),
    Prodi(kodeProdi: 'FK-02', namaProdi: 'Kedokteran', aliasProdi: 'FK'),
    Prodi(kodeProdi: 'BIO-03', namaProdi: 'Biologi', aliasProdi: 'BIO'),
    Prodi(
      kodeProdi: 'DKV-04',
      namaProdi: 'Desain Komunikasi Visual',
      aliasProdi: 'DKV',
    ),
  ];

  static List<MataKuliah> daftarMataKuliah = [
    MataKuliah(
      kodeMataKuliah: 'ILKOM101',
      namaMataKuliah: 'Pemrograman Dasar',
      jumlahSks: 3,
      kodeProdi: 'ILKOM-01',
    ),
    MataKuliah(
      kodeMataKuliah: 'ILKOM102',
      namaMataKuliah: 'Struktur Data',
      jumlahSks: 3,
      kodeProdi: 'ILKOM-01',
    ),
    MataKuliah(
      kodeMataKuliah: 'ILKOM103',
      namaMataKuliah: 'Basis Data',
      jumlahSks: 3,
      kodeProdi: 'ILKOM-01',
    ),
    MataKuliah(
      kodeMataKuliah: 'ILKOM204',
      namaMataKuliah: 'Pemrograman Mobile',
      jumlahSks: 3,
      kodeProdi: 'ILKOM-01',
    ),
    MataKuliah(
      kodeMataKuliah: 'ILKOM305',
      namaMataKuliah: 'Keamanan Siber',
      jumlahSks: 3,
      kodeProdi: 'ILKOM-01',
    ),
    MataKuliah(
      kodeMataKuliah: 'FK101',
      namaMataKuliah: 'Anatomi',
      jumlahSks: 4,
      kodeProdi: 'FK-02',
    ),
    MataKuliah(
      kodeMataKuliah: 'FK102',
      namaMataKuliah: 'Fisiologi',
      jumlahSks: 4,
      kodeProdi: 'FK-02',
    ),
    MataKuliah(
      kodeMataKuliah: 'FK103',
      namaMataKuliah: 'Histologi',
      jumlahSks: 3,
      kodeProdi: 'FK-02',
    ),
    MataKuliah(
      kodeMataKuliah: 'FK204',
      namaMataKuliah: 'Farmakologi Dasar',
      jumlahSks: 3,
      kodeProdi: 'FK-02',
    ),
    MataKuliah(
      kodeMataKuliah: 'BIO101',
      namaMataKuliah: 'Biologi Sel',
      jumlahSks: 3,
      kodeProdi: 'BIO-03',
    ),
    MataKuliah(
      kodeMataKuliah: 'BIO102',
      namaMataKuliah: 'Genetika',
      jumlahSks: 3,
      kodeProdi: 'BIO-03',
    ),
    MataKuliah(
      kodeMataKuliah: 'BIO103',
      namaMataKuliah: 'Ekologi',
      jumlahSks: 3,
      kodeProdi: 'BIO-03',
    ),
    MataKuliah(
      kodeMataKuliah: 'BIO204',
      namaMataKuliah: 'Mikrobiologi',
      jumlahSks: 3,
      kodeProdi: 'BIO-03',
    ),
    MataKuliah(
      kodeMataKuliah: 'DKV101',
      namaMataKuliah: 'Rupa Dasar',
      jumlahSks: 3,
      kodeProdi: 'DKV-04',
    ),
    MataKuliah(
      kodeMataKuliah: 'DKV102',
      namaMataKuliah: 'Tipografi',
      jumlahSks: 3,
      kodeProdi: 'DKV-04',
    ),
  ];

  static List<Mahasiswa> daftarMahasiswa = [
  Mahasiswa(
    nim: '2024010001',
    namaLengkap: 'David Purnomo',
    kodeProdi: 'ILKOM-01',
    angkatan: 2024,
    jk: false,
    tanggalLahir: DateTime(2005, 5, 20),
    dosenPembimbingNidn: 'D001',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010002',
    namaLengkap: 'Vidi Lapa',
    kodeProdi: 'FK-02',
    angkatan: 2025,
    jk: true,
    tanggalLahir: DateTime(2005, 7, 12),
    dosenPembimbingNidn: 'D004',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010003',
    namaLengkap: 'Zhao Yufan',
    kodeProdi: 'BIO-03',
    angkatan: 2023,
    jk: false,
    tanggalLahir: DateTime(2004, 11, 8),
    dosenPembimbingNidn: 'D007',
    isAktif: false,
  ),
  Mahasiswa(
    nim: '2024010004',
    namaLengkap: 'Salsa Kirana',
    kodeProdi: 'ILKOM-01',
    angkatan: 2024,
    jk: true,
    tanggalLahir: DateTime(2005, 2, 9),
    dosenPembimbingNidn: 'D001',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010005',
    namaLengkap: 'Raka Mahendra',
    kodeProdi: 'ILKOM-01',
    angkatan: 2023,
    jk: false,
    tanggalLahir: DateTime(2004, 9, 3),
    dosenPembimbingNidn: 'D001',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010006',
    namaLengkap: 'Nadia Aulia',
    kodeProdi: 'FK-02',
    angkatan: 2024,
    jk: true,
    tanggalLahir: DateTime(2005, 1, 18),
    dosenPembimbingNidn: 'D004',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010007',
    namaLengkap: 'Bagas Pratama',
    kodeProdi: 'FK-02',
    angkatan: 2023,
    jk: false,
    tanggalLahir: DateTime(2004, 6, 21),
    dosenPembimbingNidn: 'D004',
    isAktif: false,
  ),
  Mahasiswa(
    nim: '2024010008',
    namaLengkap: 'Maya Saraswati',
    kodeProdi: 'BIO-03',
    angkatan: 2024,
    jk: true,
    tanggalLahir: DateTime(2005, 10, 14),
    dosenPembimbingNidn: 'D007',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010009',
    namaLengkap: 'Adit Wijaya',
    kodeProdi: 'BIO-03',
    angkatan: 2022,
    jk: false,
    tanggalLahir: DateTime(2003, 4, 4),
    dosenPembimbingNidn: 'D007',
    isAktif: true,
  ),
  Mahasiswa(
    nim: '2024010010',
    namaLengkap: 'Keisha Putri',
    kodeProdi: 'DKV-04',
    angkatan: 2024,
    jk: true,
    tanggalLahir: DateTime(2005, 8, 30),
    dosenPembimbingNidn: 'D010',
    isAktif: true,
  ),
];

  static List<User> users = [
    User(
      username: 'david',
      password: '123',
      nama: 'David Purnomo',
      identifier: '2024010001',
      role: 'mahasiswa',
    ),
    User(
      username: 'vidi',
      password: '123',
      nama: 'Vidi Lapa',
      identifier: '2024010002',
      role: 'mahasiswa',
    ),
    User(
      username: 'zhao',
      password: '123',
      nama: 'Zhao Yufan',
      identifier: '2024010003',
      role: 'mahasiswa',
    ),
    User(
      username: 'salsa',
      password: '123',
      nama: 'Salsa Kirana',
      identifier: '2024010004',
      role: 'mahasiswa',
    ),
    User(
      username: 'raka',
      password: '123',
      nama: 'Raka Mahendra',
      identifier: '2024010005',
      role: 'mahasiswa',
    ),
    User(
      username: 'nadia',
      password: '123',
      nama: 'Nadia Aulia',
      identifier: '2024010006',
      role: 'mahasiswa',
    ),
    User(
      username: 'bagas',
      password: '123',
      nama: 'Bagas Pratama',
      identifier: '2024010007',
      role: 'mahasiswa',
    ),
    User(
      username: 'maya',
      password: '123',
      nama: 'Maya Saraswati',
      identifier: '2024010008',
      role: 'mahasiswa',
    ),
    User(
      username: 'adit',
      password: '123',
      nama: 'Adit Wijaya',
      identifier: '2024010009',
      role: 'mahasiswa',
    ),
    User(
      username: 'keisha',
      password: '123',
      nama: 'Keisha Putri',
      identifier: '2024010010',
      role: 'mahasiswa',
    ),
    User(
      username: 'irfan',
      password: '123',
      nama: 'Ir. Arfan',
      identifier: 'D001',
      role: 'dosen',
    ),
    User(
      username: 'megumi',
      password: '123',
      nama: 'Dr. Megumi Fushiguro',
      identifier: 'D002',
      role: 'dosen',
    ),
    User(
      username: 'toji',
      password: '123',
      nama: 'Ir. Toji Fushiguro',
      identifier: 'D003',
      role: 'dosen',
    ),
    User(
      username: 'yuji',
      password: '123',
      nama: 'dr. yuji',
      identifier: 'D004',
      role: 'dosen',
    ),
    User(
      username: 'frieren',
      password: '123',
      nama: 'dr. Frieren',
      identifier: 'D005',
      role: 'dosen',
    ),
    User(
      username: 'lawliet',
      password: '123',
      nama: 'dr. Lawliet',
      identifier: 'D006',
      role: 'dosen',
    ),
    User(
      username: 'raynata',
      password: '123',
      nama: 'Dr. Raynata Bien',
      identifier: 'D007',
      role: 'dosen',
    ),
    User(
      username: 'izumi',
      password: '123',
      nama: 'Dr. izumi',
      identifier: 'D008',
      role: 'dosen',
    ),
    User(
      username: 'nanami',
      password: '123',
      nama: 'Dr. Nanami',
      identifier: 'D009',
      role: 'dosen',
    ),
    User(
      username: 'rina',
      password: '123',
      nama: 'Dr. Rina Wulandari',
      identifier: 'D010',
      role: 'dosen',
    ),
    User(
      username: 'admin',
      password: '456',
      nama: 'Administrator Universitas',
      identifier: 'A001',
      role: 'admin_univ',
    ),
    User(
      username: 'adminilkom',
      password: '789',
      nama: 'Administrator Program Studi Ilmu Komputer',
      identifier: 'AP001',
      role: 'admin_prodi',
      kodeProdi: 'ILKOM-01',
    ),
    User(
      username: 'adminbio',
      password: '789',
      nama: 'Administrator Program Studi Biologi',
      identifier: 'AP002',
      role: 'admin_prodi',
      kodeProdi: 'BIO-03',
    ),
    User(
      username: 'adminFK',
      password: '789',
      nama: 'Administrator Program Studi Ilmu Kedokteran',
      identifier: 'AP003',
      role: 'admin_prodi',
      kodeProdi: 'FK-02',
    ),
    User(
      username: 'admindkv',
      password: '789',
      nama: 'Administrator Program Studi DKV',
      identifier: 'AP004',
      role: 'admin_prodi',
      kodeProdi: 'DKV-04',
    ),
    User(
      username: 'rektor',
      password: '123',
      nama: 'Prof. Dr. Ir. Rektor, M.Si.',
      identifier: 'P001',
      role: 'pimpinan_univ',
    ),
    User(
      username: 'kaprodiilkom',
      password: '123',
      nama: 'Kaprodi Ilmu Komputer',
      identifier: 'PP001',
      role: 'pimpinan_prodi',
      kodeProdi: 'ILKOM-01',
    ),
    User(
      username: 'kaprodibio',
      password: '123',
      nama: 'Kaprodi Biologi',
      identifier: 'PP002',
      role: 'pimpinan_prodi',
      kodeProdi: 'BIO-03',
    ),
    User(
      username: 'kaprodifk',
      password: '123',
      nama: 'Kaprodi Kedokteran',
      identifier: 'PP003',
      role: 'pimpinan_prodi',
      kodeProdi: 'FK-02',
    ),
    User(
      username: 'kaprodidkv',
      password: '123',
      nama: 'Kaprodi DKV',
      identifier: 'PP004',
      role: 'pimpinan_prodi',
      kodeProdi: 'DKV-04',
    ),
  ];

  static List<Dosen> daftarDosen = [
    Dosen(nidn: 'D001', nama: 'Ir. Arfan', kodeProdi: 'ILKOM-01'),
    Dosen(nidn: 'D002', nama: 'Dr. Megumi Fushiguro', kodeProdi: 'ILKOM-01'),
    Dosen(nidn: 'D003', nama: 'Ir. Toji Fushiguro', kodeProdi: 'ILKOM-01'),
    Dosen(nidn: 'D004', nama: 'dr. yuji', kodeProdi: 'FK-02'),
    Dosen(nidn: 'D005', nama: 'dr. Frieren', kodeProdi: 'FK-02'),
    Dosen(nidn: 'D006', nama: 'dr. Lawliet', kodeProdi: 'FK-02'),
    Dosen(nidn: 'D007', nama: 'Dr. Raynata Bien', kodeProdi: 'BIO-03'),
    Dosen(nidn: 'D008', nama: 'Dr. izumi', kodeProdi: 'BIO-03'),
    Dosen(nidn: 'D009', nama: 'Dr. Nanami', kodeProdi: 'BIO-03'),
    Dosen(nidn: 'D010', nama: 'Dr. Rina Wulandari', kodeProdi: 'DKV-04'),
  ];

  static List<KelasKuliah> daftarKelas = [
    // ── ILKOM ──────────────────────────────────────────────────────────────
    KelasKuliah(
      id: 'IF-01', kodeSemester: '20241', kodeProdi: 'ILKOM-01',
      kodeMataKuliah: 'ILKOM101', namaKelas: 'A',
      dosenPengampu: 'Ir. Arfan', kapasitas: 4, jumlahPeserta: 4,
      jadwal: 'Senin, 08:00 - 10:30',
      hari: 'Senin', jamMulai: '08:00', jamSelesai: '10:30',
      kodeRuangan: 'R103', ruangan: 'Lab Komputer',
    ),
    KelasKuliah(
      id: 'IF-02', kodeSemester: '20241', kodeProdi: 'ILKOM-01',
      kodeMataKuliah: 'ILKOM102', namaKelas: 'B',
      dosenPengampu: 'Dr. Megumi Fushiguro', kapasitas: 5, jumlahPeserta: 3,
      jadwal: 'Selasa, 10:00 - 12:30',
      hari: 'Selasa', jamMulai: '10:00', jamSelesai: '12:30',
      kodeRuangan: 'R101', ruangan: 'Ruang 101',
    ),
    KelasKuliah(
      id: 'IF-03', kodeSemester: '20241', kodeProdi: 'ILKOM-01',
      kodeMataKuliah: 'ILKOM103', namaKelas: 'C',
      dosenPengampu: 'Ir. Toji Fushiguro', kapasitas: 3, jumlahPeserta: 2,
      jadwal: 'Rabu, 13:00 - 15:30',
      hari: 'Rabu', jamMulai: '13:00', jamSelesai: '15:30',
      kodeRuangan: 'R103', ruangan: 'Lab Komputer',
    ),
    KelasKuliah(
      id: 'IF-04', kodeSemester: '20241', kodeProdi: 'ILKOM-01',
      kodeMataKuliah: 'ILKOM204', namaKelas: 'A',
      dosenPengampu: 'Ir. Arfan', kapasitas: 6, jumlahPeserta: 2,
      jadwal: 'Kamis, 08:00 - 10:30',
      hari: 'Kamis', jamMulai: '08:00', jamSelesai: '10:30',
      kodeRuangan: 'R103', ruangan: 'Lab Komputer',
    ),
    KelasKuliah(
      id: 'IF-05', kodeSemester: '20241', kodeProdi: 'ILKOM-01',
      kodeMataKuliah: 'ILKOM305', namaKelas: 'A',
      dosenPengampu: 'Dr. Megumi Fushiguro', kapasitas: 2, jumlahPeserta: 0,
      jadwal: 'Jumat, 13:00 - 15:30',
      hari: 'Jumat', jamMulai: '13:00', jamSelesai: '15:30',
      kodeRuangan: 'R101', ruangan: 'Ruang 101',
    ),

    // ── KEDOKTERAN ─────────────────────────────────────────────────────────
    KelasKuliah(
      id: 'KD-01', kodeSemester: '20241', kodeProdi: 'FK-02',
      kodeMataKuliah: 'FK101', namaKelas: 'A',
      dosenPengampu: 'dr. yuji', kapasitas: 3, jumlahPeserta: 3,
      jadwal: 'Senin, 08:00 - 11:20',
      hari: 'Senin', jamMulai: '08:00', jamSelesai: '11:20',
      kodeRuangan: 'R102', ruangan: 'Ruang 102',
    ),
    KelasKuliah(
      id: 'KD-02', kodeSemester: '20241', kodeProdi: 'FK-02',
      kodeMataKuliah: 'FK102', namaKelas: 'B',
      dosenPengampu: 'dr. Frieren', kapasitas: 4, jumlahPeserta: 2,
      jadwal: 'Selasa, 13:00 - 16:20',
      hari: 'Selasa', jamMulai: '13:00', jamSelesai: '16:20',
      kodeRuangan: 'R102', ruangan: 'Ruang 102',
    ),
    KelasKuliah(
      id: 'KD-03', kodeSemester: '20241', kodeProdi: 'FK-02',
      kodeMataKuliah: 'FK103', namaKelas: 'C',
      dosenPengampu: 'dr. Lawliet', kapasitas: 5, jumlahPeserta: 1,
      jadwal: 'Rabu, 08:00 - 10:30',
      hari: 'Rabu', jamMulai: '08:00', jamSelesai: '10:30',
      kodeRuangan: 'R102', ruangan: 'Ruang 102',
    ),
    KelasKuliah(
      id: 'KD-04', kodeSemester: '20241', kodeProdi: 'FK-02',
      kodeMataKuliah: 'FK204', namaKelas: 'A',
      dosenPengampu: 'dr. yuji', kapasitas: 4, jumlahPeserta: 1,
      jadwal: 'Kamis, 13:00 - 15:30',
      hari: 'Kamis', jamMulai: '13:00', jamSelesai: '15:30',
      kodeRuangan: 'R102', ruangan: 'Ruang 102',
    ),

    // ── BIOLOGI ────────────────────────────────────────────────────────────
    KelasKuliah(
      id: 'BI-01', kodeSemester: '20241', kodeProdi: 'BIO-03',
      kodeMataKuliah: 'BIO101', namaKelas: 'A',
      dosenPengampu: 'Dr. Raynata Bien', kapasitas: 4, jumlahPeserta: 3,
      jadwal: 'Senin, 10:00 - 12:30',
      hari: 'Senin', jamMulai: '10:00', jamSelesai: '12:30',
      kodeRuangan: 'R101', ruangan: 'Ruang 101',
    ),
    KelasKuliah(
      id: 'BI-02', kodeSemester: '20241', kodeProdi: 'BIO-03',
      kodeMataKuliah: 'BIO102', namaKelas: 'B',
      dosenPengampu: 'Dr. izumi', kapasitas: 3, jumlahPeserta: 3,
      jadwal: 'Selasa, 08:00 - 10:30',
      hari: 'Selasa', jamMulai: '08:00', jamSelesai: '10:30',
      kodeRuangan: 'R101', ruangan: 'Ruang 101',
    ),
    KelasKuliah(
      id: 'BI-03', kodeSemester: '20241', kodeProdi: 'BIO-03',
      kodeMataKuliah: 'BIO103', namaKelas: 'C',
      dosenPengampu: 'Dr. Nanami', kapasitas: 5, jumlahPeserta: 2,
      jadwal: 'Rabu, 13:00 - 15:30',
      hari: 'Rabu', jamMulai: '13:00', jamSelesai: '15:30',
      kodeRuangan: 'R101', ruangan: 'Ruang 101',
    ),
    KelasKuliah(
      id: 'BI-04', kodeSemester: '20241', kodeProdi: 'BIO-03',
      kodeMataKuliah: 'BIO204', namaKelas: 'A',
      dosenPengampu: 'Dr. Raynata Bien', kapasitas: 4, jumlahPeserta: 0,
      jadwal: 'Jumat, 08:00 - 10:30',
      hari: 'Jumat', jamMulai: '08:00', jamSelesai: '10:30',
      kodeRuangan: 'R101', ruangan: 'Ruang 101',
    ),

    // ── DKV ────────────────────────────────────────────────────────────────
    KelasKuliah(
      id: 'DKV-01', kodeSemester: '20241', kodeProdi: 'DKV-04',
      kodeMataKuliah: 'DKV101', namaKelas: 'A',
      dosenPengampu: 'Dr. Rina Wulandari', kapasitas: 3, jumlahPeserta: 1,
      jadwal: 'Senin, 13:00 - 15:30',
      hari: 'Senin', jamMulai: '13:00', jamSelesai: '15:30',
      kodeRuangan: 'R102', ruangan: 'Ruang 102',
    ),
    KelasKuliah(
      id: 'DKV-02', kodeSemester: '20241', kodeProdi: 'DKV-04',
      kodeMataKuliah: 'DKV102', namaKelas: 'B',
      dosenPengampu: 'Dr. Rina Wulandari', kapasitas: 2, jumlahPeserta: 0,
      jadwal: 'Kamis, 10:00 - 12:30',
      hari: 'Kamis', jamMulai: '10:00', jamSelesai: '12:30',
      kodeRuangan: 'R102', ruangan: 'Ruang 102',
    ),
  ];

  static List<Nilai> daftarNilai = [
    Nilai(
      nim: '2024010001',
      idKelasKuliah: 'IF-01',
      kodeMataKuliah: 'ILKOM101',
      namaMataKuliah: 'Pemrograman Dasar',
      sksMataKuliah: 3,
      nilaiAngka: 88,
      nilaiHuruf: 'A',
    ),
    Nilai(
      nim: '2024010001',
      idKelasKuliah: 'IF-02',
      kodeMataKuliah: 'ILKOM102',
      namaMataKuliah: 'Struktur Data',
      sksMataKuliah: 3,
      nilaiAngka: 76,
      nilaiHuruf: 'B',
    ),
    Nilai(
      nim: '2024010001',
      idKelasKuliah: 'IF-04',
      kodeMataKuliah: 'ILKOM204',
      namaMataKuliah: 'Pemrograman Mobile',
      sksMataKuliah: 3,
    ),
    Nilai(
      nim: '2024010004',
      idKelasKuliah: 'IF-01',
      kodeMataKuliah: 'ILKOM101',
      namaMataKuliah: 'Pemrograman Dasar',
      sksMataKuliah: 3,
      nilaiAngka: 91,
      nilaiHuruf: 'A',
    ),
    Nilai(
      nim: '2024010004',
      idKelasKuliah: 'IF-02',
      kodeMataKuliah: 'ILKOM102',
      namaMataKuliah: 'Struktur Data',
      sksMataKuliah: 3,
    ),
    Nilai(
      nim: '2024010004',
      idKelasKuliah: 'IF-03',
      kodeMataKuliah: 'ILKOM103',
      namaMataKuliah: 'Basis Data',
      sksMataKuliah: 3,
      nilaiAngka: 68,
      nilaiHuruf: 'C',
    ),
    Nilai(
      nim: '2024010005',
      idKelasKuliah: 'IF-01',
      kodeMataKuliah: 'ILKOM101',
      namaMataKuliah: 'Pemrograman Dasar',
      sksMataKuliah: 3,
      nilaiAngka: 73,
      nilaiHuruf: 'C',
    ),
    Nilai(
      nim: '2024010005',
      idKelasKuliah: 'IF-03',
      kodeMataKuliah: 'ILKOM103',
      namaMataKuliah: 'Basis Data',
      sksMataKuliah: 3,
    ),
    Nilai(
      nim: '2024010002',
      idKelasKuliah: 'KD-01',
      kodeMataKuliah: 'FK101',
      namaMataKuliah: 'Anatomi',
      sksMataKuliah: 4,
      nilaiAngka: 82,
      nilaiHuruf: 'B',
    ),
    Nilai(
      nim: '2024010002',
      idKelasKuliah: 'KD-02',
      kodeMataKuliah: 'FK102',
      namaMataKuliah: 'Fisiologi',
      sksMataKuliah: 4,
    ),
    Nilai(
      nim: '2024010002',
      idKelasKuliah: 'KD-04',
      kodeMataKuliah: 'FK204',
      namaMataKuliah: 'Farmakologi Dasar',
      sksMataKuliah: 3,
      nilaiAngka: 90,
      nilaiHuruf: 'A',
    ),
    Nilai(
      nim: '2024010006',
      idKelasKuliah: 'KD-01',
      kodeMataKuliah: 'FK101',
      namaMataKuliah: 'Anatomi',
      sksMataKuliah: 4,
      nilaiAngka: 95,
      nilaiHuruf: 'A',
    ),
    Nilai(
      nim: '2024010006',
      idKelasKuliah: 'KD-02',
      kodeMataKuliah: 'FK102',
      namaMataKuliah: 'Fisiologi',
      sksMataKuliah: 4,
      nilaiAngka: 79,
      nilaiHuruf: 'B',
    ),
    Nilai(
      nim: '2024010007',
      idKelasKuliah: 'KD-01',
      kodeMataKuliah: 'FK101',
      namaMataKuliah: 'Anatomi',
      sksMataKuliah: 4,
    ),
    Nilai(
      nim: '2024010007',
      idKelasKuliah: 'KD-03',
      kodeMataKuliah: 'FK103',
      namaMataKuliah: 'Histologi',
      sksMataKuliah: 3,
      nilaiAngka: 62,
      nilaiHuruf: 'D',
    ),
    Nilai(
      nim: '2024010003',
      idKelasKuliah: 'BI-01',
      kodeMataKuliah: 'BIO101',
      namaMataKuliah: 'Biologi Sel',
      sksMataKuliah: 3,
      nilaiAngka: 85,
      nilaiHuruf: 'A',
    ),
    Nilai(
      nim: '2024010003',
      idKelasKuliah: 'BI-02',
      kodeMataKuliah: 'BIO102',
      namaMataKuliah: 'Genetika',
      sksMataKuliah: 3,
      nilaiAngka: 78,
      nilaiHuruf: 'B',
    ),
    Nilai(
      nim: '2024010008',
      idKelasKuliah: 'BI-01',
      kodeMataKuliah: 'BIO101',
      namaMataKuliah: 'Biologi Sel',
      sksMataKuliah: 3,
    ),
    Nilai(
      nim: '2024010008',
      idKelasKuliah: 'BI-02',
      kodeMataKuliah: 'BIO102',
      namaMataKuliah: 'Genetika',
      sksMataKuliah: 3,
      nilaiAngka: 93,
      nilaiHuruf: 'A',
    ),
    Nilai(
      nim: '2024010009',
      idKelasKuliah: 'BI-02',
      kodeMataKuliah: 'BIO102',
      namaMataKuliah: 'Genetika',
      sksMataKuliah: 3,
      nilaiAngka: 55,
      nilaiHuruf: 'D',
    ),
    Nilai(
      nim: '2024010009',
      idKelasKuliah: 'BI-03',
      kodeMataKuliah: 'BIO103',
      namaMataKuliah: 'Ekologi',
      sksMataKuliah: 3,
    ),
    Nilai(
      nim: '2024010010',
      idKelasKuliah: 'DKV-01',
      kodeMataKuliah: 'DKV101',
      namaMataKuliah: 'Rupa Dasar',
      sksMataKuliah: 3,
      nilaiAngka: 87,
      nilaiHuruf: 'A',
    ),
  ];

  static List<Ruangan> daftarRuangan = [
    Ruangan(kodeRuangan: 'R101', namaRuangan: 'Ruang 101', kapasitasRuangan: 40, lokasi: 'Gedung A'),
    Ruangan(kodeRuangan: 'R102', namaRuangan: 'Ruang 102', kapasitasRuangan: 50, lokasi: 'Gedung A'),
    Ruangan(kodeRuangan: 'R103', namaRuangan: 'Lab Komputer', kapasitasRuangan: 30, lokasi: 'Gedung B'),
  ];

  static List<DosenPengajar> daftarDosenPengajar = [
    DosenPengajar(id: 'DP-01', idKelas: 'IF-01', nidnDosen: 'D001', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-02', idKelas: 'IF-02', nidnDosen: 'D002', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-03', idKelas: 'IF-03', nidnDosen: 'D003', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-04', idKelas: 'IF-04', nidnDosen: 'D001', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-05', idKelas: 'IF-05', nidnDosen: 'D002', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-06', idKelas: 'KD-01', nidnDosen: 'D004', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-07', idKelas: 'KD-02', nidnDosen: 'D005', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-08', idKelas: 'KD-03', nidnDosen: 'D006', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-09', idKelas: 'KD-04', nidnDosen: 'D004', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-10', idKelas: 'BI-01', nidnDosen: 'D007', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-11', idKelas: 'BI-02', nidnDosen: 'D008', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-12', idKelas: 'BI-03', nidnDosen: 'D009', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-13', idKelas: 'BI-04', nidnDosen: 'D007', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-14', idKelas: 'DKV-01', nidnDosen: 'D010', peranMengajar: 'Dosen Utama'),
    DosenPengajar(id: 'DP-15', idKelas: 'DKV-02', nidnDosen: 'D010', peranMengajar: 'Dosen Utama'),
  ];

  static List<JadwalKrs> daftarJadwalKrs = [
    JadwalKrs(
      tahunAkademik: '2024/2025',
      semester: 'Ganjil',
      status: 'Aktif',
      tanggalMulai: DateTime(2026, 6, 1),
      tanggalSelesai: DateTime(2026, 6, 30),
    ),
  ];

  static List<JadwalKuliah> daftarJadwalKuliah = [
    JadwalKuliah(id: 'JK-01', idKelasKuliah: 'IF-01', hari: 'Senin', jamMulai: '08:00', jamSelesai: '10:30', kodeRuangan: 'R103'),
    JadwalKuliah(id: 'JK-02', idKelasKuliah: 'IF-02', hari: 'Selasa', jamMulai: '10:00', jamSelesai: '12:30', kodeRuangan: 'R101'),
    JadwalKuliah(id: 'JK-03', idKelasKuliah: 'IF-03', hari: 'Rabu', jamMulai: '13:00', jamSelesai: '15:30', kodeRuangan: 'R103'),
    JadwalKuliah(id: 'JK-04', idKelasKuliah: 'IF-04', hari: 'Kamis', jamMulai: '08:00', jamSelesai: '10:30', kodeRuangan: 'R103'),
    JadwalKuliah(id: 'JK-05', idKelasKuliah: 'IF-05', hari: 'Jumat', jamMulai: '13:00', jamSelesai: '15:30', kodeRuangan: 'R101'),
    JadwalKuliah(id: 'JK-06', idKelasKuliah: 'KD-01', hari: 'Senin', jamMulai: '08:00', jamSelesai: '11:20', kodeRuangan: 'R102'),
    JadwalKuliah(id: 'JK-07', idKelasKuliah: 'KD-02', hari: 'Selasa', jamMulai: '13:00', jamSelesai: '16:20', kodeRuangan: 'R102'),
    JadwalKuliah(id: 'JK-08', idKelasKuliah: 'KD-03', hari: 'Rabu', jamMulai: '08:00', jamSelesai: '10:30', kodeRuangan: 'R102'),
    JadwalKuliah(id: 'JK-09', idKelasKuliah: 'KD-04', hari: 'Kamis', jamMulai: '13:00', jamSelesai: '15:30', kodeRuangan: 'R102'),
    JadwalKuliah(id: 'JK-10', idKelasKuliah: 'BI-01', hari: 'Senin', jamMulai: '10:00', jamSelesai: '12:30', kodeRuangan: 'R101'),
    JadwalKuliah(id: 'JK-11', idKelasKuliah: 'BI-02', hari: 'Selasa', jamMulai: '08:00', jamSelesai: '10:30', kodeRuangan: 'R101'),
    JadwalKuliah(id: 'JK-12', idKelasKuliah: 'BI-03', hari: 'Rabu', jamMulai: '13:00', jamSelesai: '15:30', kodeRuangan: 'R101'),
    JadwalKuliah(id: 'JK-13', idKelasKuliah: 'BI-04', hari: 'Jumat', jamMulai: '08:00', jamSelesai: '10:30', kodeRuangan: 'R101'),
    JadwalKuliah(id: 'JK-14', idKelasKuliah: 'DKV-01', hari: 'Senin', jamMulai: '13:00', jamSelesai: '15:30', kodeRuangan: 'R102'),
    JadwalKuliah(id: 'JK-15', idKelasKuliah: 'DKV-02', hari: 'Kamis', jamMulai: '10:00', jamSelesai: '12:30', kodeRuangan: 'R102'),
  ];

  static List<KRS> daftarKrs = [
    KRS(nim: '2024010001', idKelasKuliah: 'IF-01', statusKrs: 'valid'),
    KRS(nim: '2024010001', idKelasKuliah: 'IF-02', statusKrs: 'valid'),
    KRS(nim: '2024010001', idKelasKuliah: 'IF-04', statusKrs: 'pending'),
    KRS(nim: '2024010004', idKelasKuliah: 'IF-01', statusKrs: 'valid'),
    KRS(nim: '2024010004', idKelasKuliah: 'IF-02', statusKrs: 'pending'),
    KRS(nim: '2024010004', idKelasKuliah: 'IF-03', statusKrs: 'valid'),
    KRS(nim: '2024010005', idKelasKuliah: 'IF-01', statusKrs: 'valid'),
    KRS(nim: '2024010005', idKelasKuliah: 'IF-03', statusKrs: 'pending'),
    KRS(nim: '2024010002', idKelasKuliah: 'KD-01', statusKrs: 'valid'),
    KRS(nim: '2024010002', idKelasKuliah: 'KD-02', statusKrs: 'pending'),
    KRS(nim: '2024010002', idKelasKuliah: 'KD-04', statusKrs: 'valid'),
    KRS(nim: '2024010006', idKelasKuliah: 'KD-01', statusKrs: 'valid'),
    KRS(nim: '2024010006', idKelasKuliah: 'KD-02', statusKrs: 'valid'),
    KRS(nim: '2024010007', idKelasKuliah: 'KD-01', statusKrs: 'pending'),
    KRS(nim: '2024010007', idKelasKuliah: 'KD-03', statusKrs: 'valid'),
    KRS(nim: '2024010003', idKelasKuliah: 'BI-01', statusKrs: 'valid'),
    KRS(nim: '2024010003', idKelasKuliah: 'BI-02', statusKrs: 'valid'),
    KRS(nim: '2024010008', idKelasKuliah: 'BI-01', statusKrs: 'pending'),
    KRS(nim: '2024010008', idKelasKuliah: 'BI-02', statusKrs: 'valid'),
    KRS(nim: '2024010009', idKelasKuliah: 'BI-02', statusKrs: 'valid'),
    KRS(nim: '2024010009', idKelasKuliah: 'BI-03', statusKrs: 'pending'),
    KRS(nim: '2024010010', idKelasKuliah: 'DKV-01', statusKrs: 'valid'),
  ];

  static List<PertemuanKuliah> daftarPertemuanKuliah = [
    PertemuanKuliah(id: 'P-01', nomorPertemuan: 1, tanggal: DateTime(2026, 6, 8), idKelasKuliah: 'IF-01', statusSesi: 'tutup', catatan: 'Pengenalan Pemrograman'),
    PertemuanKuliah(id: 'P-02', nomorPertemuan: 2, tanggal: DateTime(2026, 6, 15), idKelasKuliah: 'IF-01', statusSesi: 'aktif', catatan: 'Variable dan Tipe Data'),
    PertemuanKuliah(id: 'P-03', nomorPertemuan: 1, tanggal: DateTime(2026, 6, 9), idKelasKuliah: 'IF-02', statusSesi: 'tutup', catatan: 'Pengenalan Pointer'),
    PertemuanKuliah(id: 'P-04', nomorPertemuan: 1, tanggal: DateTime(2026, 6, 8), idKelasKuliah: 'KD-01', statusSesi: 'tutup', catatan: 'Terminologi Anatomi'),
    PertemuanKuliah(id: 'P-05', nomorPertemuan: 2, tanggal: DateTime(2026, 6, 15), idKelasKuliah: 'KD-01', statusSesi: 'aktif', catatan: 'Sistem Skeletal'),
    PertemuanKuliah(id: 'P-06', nomorPertemuan: 1, tanggal: DateTime(2026, 6, 8), idKelasKuliah: 'BI-01', statusSesi: 'tutup', catatan: 'Pengenalan Sel'),
  ];

  static List<PresensiMahasiswa> daftarPresensiMahasiswa = [
    PresensiMahasiswa(id: 'PM-01', idPertemuan: 'P-01', nim: '2024010001', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 8, 5), catatan: 'Hadir Tepat Waktu'),
    PresensiMahasiswa(id: 'PM-02', idPertemuan: 'P-01', nim: '2024010004', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 8, 10)),
    PresensiMahasiswa(id: 'PM-03', idPertemuan: 'P-01', nim: '2024010005', status: 'Izin', waktuPresensi: DateTime(2026, 6, 8, 8, 0), catatan: 'Ada acara keluarga'),
    PresensiMahasiswa(id: 'PM-04', idPertemuan: 'P-02', nim: '2024010001', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 15, 8, 7)),
    PresensiMahasiswa(id: 'PM-05', idPertemuan: 'P-03', nim: '2024010001', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 9, 10, 2)),
    PresensiMahasiswa(id: 'PM-06', idPertemuan: 'P-03', nim: '2024010004', status: 'Sakit', waktuPresensi: null, catatan: 'Surat sakit terlampir'),
    PresensiMahasiswa(id: 'PM-07', idPertemuan: 'P-04', nim: '2024010002', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 8, 3)),
    PresensiMahasiswa(id: 'PM-08', idPertemuan: 'P-04', nim: '2024010006', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 8, 5)),
    PresensiMahasiswa(id: 'PM-09', idPertemuan: 'P-04', nim: '2024010007', status: 'Alfa', waktuPresensi: null),
    PresensiMahasiswa(id: 'PM-10', idPertemuan: 'P-05', nim: '2024010002', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 15, 8, 2)),
    PresensiMahasiswa(id: 'PM-11', idPertemuan: 'P-06', nim: '2024010003', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 10, 4)),
    PresensiMahasiswa(id: 'PM-12', idPertemuan: 'P-06', nim: '2024010008', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 10, 12)),
  ];

  static List<PresensiDosen> daftarPresensiDosen = [
    PresensiDosen(id: 'PD-01', idPertemuan: 'P-01', nidn: 'D001', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 7, 55)),
    PresensiDosen(id: 'PD-02', idPertemuan: 'P-02', nidn: 'D001', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 15, 7, 58)),
    PresensiDosen(id: 'PD-03', idPertemuan: 'P-03', nidn: 'D002', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 9, 9, 50)),
    PresensiDosen(id: 'PD-04', idPertemuan: 'P-04', nidn: 'D004', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 7, 50)),
    PresensiDosen(id: 'PD-05', idPertemuan: 'P-05', nidn: 'D004', status: 'Belum Presensi'),
    PresensiDosen(id: 'PD-06', idPertemuan: 'P-06', nidn: 'D007', status: 'Hadir', waktuPresensi: DateTime(2026, 6, 8, 9, 55)),
  ];
}

