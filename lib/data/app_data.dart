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
import '../models/materi_kuliah.dart';
import 'materi_data.dart';
import 'package:postgres/postgres.dart';
import '../database/db_connection.dart';

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

  static List<Prodi> daftarProdi = [];
  static List<MataKuliah> daftarMataKuliah = [];
  static List<Mahasiswa> daftarMahasiswa = [];
  static List<User> users = [];
  static List<Dosen> daftarDosen = [];
  static List<KelasKuliah> daftarKelas = [];
  static List<Nilai> daftarNilai = [];
  static List<Ruangan> daftarRuangan = [];
  static List<DosenPengajar> daftarDosenPengajar = [];
  static List<JadwalKrs> daftarJadwalKrs = [];
  static List<JadwalKuliah> daftarJadwalKuliah = [];
  static List<KRS> daftarKrs = [];
  static List<PertemuanKuliah> daftarPertemuanKuliah = [];
  static List<PresensiMahasiswa> daftarPresensiMahasiswa = [];
  static List<PresensiDosen> daftarPresensiDosen = [];

  static Future<void> loadFromDatabase() async {
    final conn = await DBConnection.connect();
    try {
      // 1. Prodi
      final resProdi = await conn.execute('SELECT kode_prodi, nama_prodi, alias_prodi FROM prodi');
      daftarProdi = resProdi.map((row) => Prodi(
        kodeProdi: row[0] as String,
        namaProdi: row[1] as String,
        aliasProdi: row[2] as String,
      )).toList();

      // 2. MataKuliah
      final resMk = await conn.execute('SELECT kode_mata_kuliah, nama_mata_kuliah, jumlah_sks, kode_prodi FROM mata_kuliah');
      daftarMataKuliah = resMk.map((row) => MataKuliah(
        kodeMataKuliah: row[0] as String,
        namaMataKuliah: row[1] as String,
        jumlahSks: row[2] as int,
        kodeProdi: row[3] as String,
      )).toList();

      // 3. Dosen
      final resDosen = await conn.execute('SELECT nidn, nama, kode_prodi FROM dosen');
      daftarDosen = resDosen.map((row) => Dosen(
        nidn: row[0] as String,
        nama: row[1] as String,
        kodeProdi: row[2] as String,
      )).toList();

      // 4. Mahasiswa
      final resMhs = await conn.execute('SELECT nim, nama_lengkap, jk, kode_prodi, tanggal_lahir, angkatan, is_aktif, dosen_pembimbing_nidn FROM mahasiswa');
      daftarMahasiswa = resMhs.map((row) => Mahasiswa(
        nim: row[0] as String,
        namaLengkap: row[1] as String,
        jk: row[2] as bool,
        kodeProdi: row[3] as String,
        tanggalLahir: row[4] as DateTime,
        angkatan: row[5] as int,
        isAktif: row[6] as bool? ?? true,
        dosenPembimbingNidn: row[7] as String?,
      )).toList();

      // 5. Users
      final resUsers = await conn.execute('SELECT identifier, username, password, nama, role, kode_prodi FROM users');
      users = resUsers.map((row) => User(
        identifier: row[0] as String,
        username: row[1] as String,
        password: row[2] as String,
        nama: row[3] as String,
        role: row[4] as String,
        kodeProdi: row[5] as String?,
      )).toList();

      // 6. KelasKuliah
      final resKelas = await conn.execute('SELECT id, kode_semester, kode_prodi, kode_mata_kuliah, nama_kelas, kapasitas, jumlah_peserta, dosen_pengampu, jadwal, hari, jam_mulai, jam_selesai, ruangan, kode_ruangan FROM kelas_kuliah');
      daftarKelas = resKelas.map((row) => KelasKuliah(
        id: row[0] as String,
        kodeSemester: row[1] as String,
        kodeProdi: row[2] as String,
        kodeMataKuliah: row[3] as String,
        namaKelas: row[4] as String,
        kapasitas: row[5] as int,
        jumlahPeserta: row[6] as int? ?? 0,
        dosenPengampu: row[7] as String? ?? '',
        jadwal: row[8] as String? ?? '',
        hari: row[9] as String? ?? '',
        jamMulai: row[10] as String? ?? '',
        jamSelesai: row[11] as String? ?? '',
        ruangan: row[12] as String? ?? '',
        kodeRuangan: row[13] as String? ?? '',
      )).toList();

      // 7. Nilai
      final resNilai = await conn.execute(
        'SELECT n.nim, n.id_kelas_kuliah, n.kode_mata_kuliah, n.nama_mata_kuliah, '
        'n.sks_mata_kuliah, n.nilai_angka, n.nilai_huruf, COALESCE(k.status_krs, \'draft\') '
        'FROM nilai n '
        'LEFT JOIN krs k ON n.nim = k.nim AND n.id_kelas_kuliah = k.id_kelas_kuliah'
      );
      daftarNilai = resNilai.map((row) => Nilai(
        nim: row[0] as String,
        idKelasKuliah: row[1] as String,
        kodeMataKuliah: row[2] as String,
        namaMataKuliah: row[3] as String,
        sksMataKuliah: row[4] as int,
        nilaiAngka: row[5] != null ? (row[5] as int).toDouble() : null,
        nilaiHuruf: row[6] as String?,
        statusKrs: row[7] as String? ?? 'draft',
      )).toList();

      // 8. Ruangan
      final resRuangan = await conn.execute('SELECT kode_ruangan, nama_ruangan, kapasitas_ruangan, lokasi FROM ruangan');
      daftarRuangan = resRuangan.map((row) => Ruangan(
        kodeRuangan: row[0] as String,
        namaRuangan: row[1] as String,
        kapasitasRuangan: row[2] as int,
        lokasi: row[3] as String? ?? '',
      )).toList();

      // 9. DosenPengajar
      final resDp = await conn.execute('SELECT id, id_kelas, nidn_dosen, peran_mengajar FROM dosen_pengajar');
      daftarDosenPengajar = resDp.map((row) => DosenPengajar(
        id: row[0] as String,
        idKelas: row[1] as String,
        nidnDosen: row[2] as String,
        peranMengajar: row[3] as String,
      )).toList();

      // 10. JadwalKrs
      final resJkrs = await conn.execute('SELECT tahun_akademik, semester, status, tanggal_mulai, tanggal_selesai FROM jadwal_krs');
      daftarJadwalKrs = resJkrs.map((row) => JadwalKrs(
        tahunAkademik: row[0] as String,
        semester: row[1] as String,
        status: row[2] as String,
        tanggalMulai: row[3] as DateTime,
        tanggalSelesai: row[4] as DateTime,
      )).toList();

      // 11. JadwalKuliah
      final resJkul = await conn.execute('SELECT id, id_kelas_kuliah, hari, jam_mulai, jam_selesai, kode_ruangan FROM jadwal_kuliah');
      daftarJadwalKuliah = resJkul.map((row) => JadwalKuliah(
        id: row[0] as String,
        idKelasKuliah: row[1] as String,
        hari: row[2] as String,
        jamMulai: row[3] as String,
        jamSelesai: row[4] as String,
        kodeRuangan: row[5] as String,
      )).toList();

      // 12. KRS
      final resKrs = await conn.execute('SELECT nim, id_kelas_kuliah, status_krs FROM krs');
      daftarKrs = resKrs.map((row) => KRS(
        nim: row[0] as String,
        idKelasKuliah: row[1] as String,
        statusKrs: row[2] as String? ?? 'draft',
      )).toList();

      // 13. PertemuanKuliah
      final resPertemuan = await conn.execute('SELECT id, nomor_pertemuan, tanggal, id_kelas_kuliah, status_sesi, catatan, tahun_akademik, semester, kode_ruangan, nama_ruangan, hari, jam_mulai, jam_selesai FROM pertemuan_kuliah');
      daftarPertemuanKuliah = resPertemuan.map((row) => PertemuanKuliah(
        id: row[0] as String,
        nomorPertemuan: row[1] as int,
        tanggal: row[2] as DateTime,
        idKelasKuliah: row[3] as String,
        statusSesi: row[4] as String? ?? 'tutup',
        catatan: row[5] as String?,
        tahunAkademik: row[6] as String? ?? '2024/2025',
        semester: row[7] as String? ?? 'Ganjil',
        kodeRuangan: row[8] as String? ?? '',
        namaRuangan: row[9] as String? ?? '',
        hari: row[10] as String? ?? '',
        jamMulai: row[11] as String? ?? '',
        jamSelesai: row[12] as String? ?? '',
      )).toList();

      // 14. PresensiMahasiswa
      final resPm = await conn.execute('SELECT id, id_pertemuan, nim, status, waktu_presensi, catatan FROM presensi_mahasiswa');
      daftarPresensiMahasiswa = resPm.map((row) => PresensiMahasiswa(
        id: row[0] as String,
        idPertemuan: row[1] as String,
        nim: row[2] as String,
        status: row[3] as String,
        waktuPresensi: row[4] as DateTime?,
        catatan: row[5] as String?,
      )).toList();

      // 15. PresensiDosen
      final resPd = await conn.execute('SELECT id, id_pertemuan, nidn, status, waktu_presensi FROM presensi_dosen');
      daftarPresensiDosen = resPd.map((row) => PresensiDosen(
        id: row[0] as String,
        idPertemuan: row[1] as String,
        nidn: row[2] as String,
        status: row[3] as String,
        waktuPresensi: row[4] as DateTime?,
      )).toList();
      // 16. Materi Kuliah
      final resMateri = await conn.execute('SELECT id, id_kelas_kuliah, minggu, judul_bab, deskripsi_bab, created_at FROM materi_kuliah');
      
      // 17. Materi File
      final resFiles = await conn.execute('SELECT id, id_materi, nama, tipe, url FROM materi_file');
      
      // Map files by materi_id
      final Map<String, List<MateriFile>> filesByMateri = {};
      for (final row in resFiles) {
        final file = MateriFile(
          id: row[0] as int,
          idMateri: row[1] as String,
          nama: row[2] as String,
          tipe: row[3] as String,
          url: row[4] as String,
        );
        if (!filesByMateri.containsKey(file.idMateri)) {
          filesByMateri[file.idMateri!] = [];
        }
        filesByMateri[file.idMateri!]!.add(file);
      }

      final List<MateriKuliah> loadedMateri = resMateri.map((row) {
        final id = row[0] as String;
        return MateriKuliah(
          id: id,
          idKelasKuliah: row[1] as String,
          minggu: row[2] as int,
          judulBab: row[3] as String,
          deskripsiBab: row[4] as String? ?? '',
          createdAt: row[5] as DateTime? ?? DateTime.now(),
          files: filesByMateri[id] ?? [],
        );
      }).toList();

      // 18. Rencana Materi
      final resRencana = await conn.execute('SELECT id, id_kelas_kuliah, minggu, judul_bab, sub_bab, sudah_dibahas FROM rencana_materi');
      final List<RencanaMateri> loadedRencana = resRencana.map((row) => RencanaMateri(
        id: row[0] as int,
        idKelasKuliah: row[1] as String,
        minggu: row[2] as int,
        judulBab: row[3] as String,
        subBab: row[4] as String? ?? '',
        sudahDibahas: row[5] as bool? ?? false,
      )).toList();

      // Populate MateriData
      MateriData.daftarMateri.clear();
      MateriData.daftarMateri.addAll(loadedMateri);
      
      MateriData.rencanaPerKelas.clear();
      for (final r in loadedRencana) {
        if (!MateriData.rencanaPerKelas.containsKey(r.idKelasKuliah)) {
          MateriData.rencanaPerKelas[r.idKelasKuliah!] = [];
        }
        MateriData.rencanaPerKelas[r.idKelasKuliah!]!.add(r);
      }
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveKelas(KelasKuliah k) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO kelas_kuliah (id, kode_semester, kode_prodi, kode_mata_kuliah, '
            'nama_kelas, kapasitas, jumlah_peserta, dosen_pengampu, jadwal, hari, jam_mulai, '
            'jam_selesai, ruangan, kode_ruangan) VALUES (@id, @sem, @prodi, @mk, @nama, @kap, '
            '@peserta, @dosen, @jadwal, @hari, @mulai, @selesai, @ruangan, @kruangan)'),
        parameters: {
          'id': k.id,
          'sem': k.kodeSemester,
          'prodi': k.kodeProdi,
          'mk': k.kodeMataKuliah,
          'nama': k.namaKelas,
          'kap': k.kapasitas,
          'peserta': k.jumlahPeserta,
          'dosen': k.dosenPengampu,
          'jadwal': k.jadwal,
          'hari': k.hari,
          'mulai': k.jamMulai,
          'selesai': k.jamSelesai,
          'ruangan': k.ruangan,
          'kruangan': k.kodeRuangan,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteKelas(String id) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM kelas_kuliah WHERE id = @id'),
        parameters: {'id': id},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateKelas(String oldId, KelasKuliah k) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE kelas_kuliah SET id = @id, kode_semester = @sem, kode_prodi = @prodi, '
            'kode_mata_kuliah = @mk, nama_kelas = @nama, kapasitas = @kap, jumlah_peserta = @peserta, '
            'dosen_pengampu = @dosen, jadwal = @jadwal, hari = @hari, jam_mulai = @mulai, '
            'jam_selesai = @selesai, ruangan = @ruangan, kode_ruangan = @kruangan WHERE id = @oldId'),
        parameters: {
          'oldId': oldId,
          'id': k.id,
          'sem': k.kodeSemester,
          'prodi': k.kodeProdi,
          'mk': k.kodeMataKuliah,
          'nama': k.namaKelas,
          'kap': k.kapasitas,
          'peserta': k.jumlahPeserta,
          'dosen': k.dosenPengampu,
          'jadwal': k.jadwal,
          'hari': k.hari,
          'mulai': k.jamMulai,
          'selesai': k.jamSelesai,
          'ruangan': k.ruangan,
          'kruangan': k.kodeRuangan,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveDosenPengajar(DosenPengajar dp) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO dosen_pengajar (id, id_kelas, nidn_dosen, peran_mengajar) '
            'VALUES (@id, @idKelas, @nidn, @peran)'),
        parameters: {
          'id': dp.id,
          'idKelas': dp.idKelas,
          'nidn': dp.nidnDosen,
          'peran': dp.peranMengajar,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteDosenPengajar(String id) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM dosen_pengajar WHERE id = @id'),
        parameters: {'id': id},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteDosenPengajarByKelas(String idKelas) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM dosen_pengajar WHERE id_kelas = @id'),
        parameters: {'id': idKelas},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveNilai(Nilai n) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO nilai (nim, id_kelas_kuliah, kode_mata_kuliah, nama_mata_kuliah, '
            'sks_mata_kuliah, nilai_angka, nilai_huruf) VALUES (@nim, @idKelas, @mk, '
            '@nama, @sks, @angka, @huruf)'),
        parameters: {
          'nim': n.nim,
          'idKelas': n.idKelasKuliah,
          'mk': n.kodeMataKuliah,
          'nama': n.namaMataKuliah,
          'sks': n.sksMataKuliah,
          'angka': n.nilaiAngka?.toInt(),
          'huruf': n.nilaiHuruf,
        },
      );
      final resKrs = await conn.execute(
        Sql.named('SELECT 1 FROM krs WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
        parameters: {'nim': n.nim, 'idKelas': n.idKelasKuliah},
      );
      if (resKrs.isEmpty) {
        await conn.execute(
          Sql.named('INSERT INTO krs (nim, id_kelas_kuliah, status_krs) VALUES (@nim, @idKelas, @status)'),
          parameters: {
            'nim': n.nim,
            'idKelas': n.idKelasKuliah,
            'status': n.statusKrs,
          },
        );
      } else {
        await conn.execute(
          Sql.named('UPDATE krs SET status_krs = @status WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
          parameters: {
            'nim': n.nim,
            'idKelas': n.idKelasKuliah,
            'status': n.statusKrs,
          },
        );
      }
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateNilai(Nilai n) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE nilai SET nilai_angka = @angka, nilai_huruf = @huruf '
            'WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
        parameters: {
          'nim': n.nim,
          'idKelas': n.idKelasKuliah,
          'angka': n.nilaiAngka?.toInt(),
          'huruf': n.nilaiHuruf,
        },
      );
      final resKrs = await conn.execute(
        Sql.named('SELECT 1 FROM krs WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
        parameters: {'nim': n.nim, 'idKelas': n.idKelasKuliah},
      );
      if (resKrs.isEmpty) {
        await conn.execute(
          Sql.named('INSERT INTO krs (nim, id_kelas_kuliah, status_krs) VALUES (@nim, @idKelas, @status)'),
          parameters: {
            'nim': n.nim,
            'idKelas': n.idKelasKuliah,
            'status': n.statusKrs,
          },
        );
      } else {
        await conn.execute(
          Sql.named('UPDATE krs SET status_krs = @status WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
          parameters: {
            'nim': n.nim,
            'idKelas': n.idKelasKuliah,
            'status': n.statusKrs,
          },
        );
      }
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteNilai(String nim, String idKelas) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM nilai WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
        parameters: {'nim': nim, 'idKelas': idKelas},
      );
      await conn.execute(
        Sql.named('DELETE FROM krs WHERE nim = @nim AND id_kelas_kuliah = @idKelas'),
        parameters: {'nim': nim, 'idKelas': idKelas},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveRuangan(Ruangan r) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO ruangan (kode_ruangan, nama_ruangan, kapasitas_ruangan, lokasi) '
            'VALUES (@kode, @nama, @kap, @lokasi)'),
        parameters: {
          'kode': r.kodeRuangan,
          'nama': r.namaRuangan,
          'kap': r.kapasitasRuangan,
          'lokasi': r.lokasi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateRuangan(String oldKode, Ruangan r) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE ruangan SET kode_ruangan = @newKode, nama_ruangan = @nama, '
            'kapasitas_ruangan = @kap, lokasi = @lokasi WHERE kode_ruangan = @oldKode'),
        parameters: {
          'oldKode': oldKode,
          'newKode': r.kodeRuangan,
          'nama': r.namaRuangan,
          'kap': r.kapasitasRuangan,
          'lokasi': r.lokasi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteRuangan(String kode) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM ruangan WHERE kode_ruangan = @kode'),
        parameters: {'kode': kode},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> savePertemuan(PertemuanKuliah p) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO pertemuan_kuliah (id, nomor_pertemuan, tanggal, id_kelas_kuliah, '
            'status_sesi, catatan, tahun_akademik, semester, kode_ruangan, nama_ruangan, hari, '
            'jam_mulai, jam_selesai) VALUES (@id, @nomor, @tanggal, @idKelas, @status, @catatan, '
            '@tahun, @sem, @kruangan, @ruangan, @hari, @mulai, @selesai)'),
        parameters: {
          'id': p.id,
          'nomor': p.nomorPertemuan,
          'tanggal': p.tanggal,
          'idKelas': p.idKelasKuliah,
          'status': p.statusSesi,
          'catatan': p.catatan,
          'tahun': p.tahunAkademik,
          'sem': p.semester,
          'kruangan': p.kodeRuangan,
          'ruangan': p.namaRuangan,
          'hari': p.hari,
          'mulai': p.jamMulai,
          'selesai': p.jamSelesai,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updatePertemuan(PertemuanKuliah p) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE pertemuan_kuliah SET status_sesi = @status, catatan = @catatan '
            'WHERE id = @id'),
        parameters: {
          'id': p.id,
          'status': p.statusSesi,
          'catatan': p.catatan,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> savePresensiMahasiswa(PresensiMahasiswa pm) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO presensi_mahasiswa (id, id_pertemuan, nim, status, waktu_presensi, catatan) '
            'VALUES (@id, @idPertemuan, @nim, @status, @waktu, @catatan) '
            'ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status, waktu_presensi = EXCLUDED.waktu_presensi, '
            'catatan = EXCLUDED.catatan'),
        parameters: {
          'id': pm.id,
          'idPertemuan': pm.idPertemuan,
          'nim': pm.nim,
          'status': pm.status,
          'waktu': pm.waktuPresensi,
          'catatan': pm.catatan,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> savePresensiDosen(PresensiDosen pd) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO presensi_dosen (id, id_pertemuan, nidn, status, waktu_presensi) '
            'VALUES (@id, @idPertemuan, @nidn, @status, @waktu) '
            'ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status, waktu_presensi = EXCLUDED.waktu_presensi'),
        parameters: {
          'id': pd.id,
          'idPertemuan': pd.idPertemuan,
          'nidn': pd.nidn,
          'status': pd.status,
          'waktu': pd.waktuPresensi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveProdi(Prodi p) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO prodi (kode_prodi, nama_prodi, alias_prodi) VALUES (@kode, @nama, @alias)'),
        parameters: {
          'kode': p.kodeProdi,
          'nama': p.namaProdi,
          'alias': p.aliasProdi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateProdi(String oldKode, Prodi p) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE prodi SET kode_prodi = @newKode, nama_prodi = @nama, alias_prodi = @alias '
            'WHERE kode_prodi = @oldKode'),
        parameters: {
          'oldKode': oldKode,
          'newKode': p.kodeProdi,
          'nama': p.namaProdi,
          'alias': p.aliasProdi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteProdi(String kode) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM prodi WHERE kode_prodi = @kode'),
        parameters: {'kode': kode},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveMataKuliah(MataKuliah mk) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO mata_kuliah (kode_mata_kuliah, nama_mata_kuliah, jumlah_sks, kode_prodi) '
            'VALUES (@kode, @nama, @sks, @prodi)'),
        parameters: {
          'kode': mk.kodeMataKuliah,
          'nama': mk.namaMataKuliah,
          'sks': mk.jumlahSks,
          'prodi': mk.kodeProdi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateMataKuliah(String oldKode, MataKuliah mk) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE mata_kuliah SET kode_mata_kuliah = @newKode, nama_mata_kuliah = @nama, '
            'jumlah_sks = @sks, kode_prodi = @prodi WHERE kode_mata_kuliah = @oldKode'),
        parameters: {
          'oldKode': oldKode,
          'newKode': mk.kodeMataKuliah,
          'nama': mk.namaMataKuliah,
          'sks': mk.jumlahSks,
          'prodi': mk.kodeProdi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteMataKuliah(String kode) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM mata_kuliah WHERE kode_mata_kuliah = @kode'),
        parameters: {'kode': kode},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveDosen(Dosen d) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO dosen (nidn, nama, kode_prodi) VALUES (@nidn, @nama, @prodi)'),
        parameters: {
          'nidn': d.nidn,
          'nama': d.nama,
          'prodi': d.kodeProdi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateDosen(String oldNidn, Dosen d) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE dosen SET nidn = @newNidn, nama = @nama, kode_prodi = @prodi '
            'WHERE nidn = @oldNidn'),
        parameters: {
          'oldNidn': oldNidn,
          'newNidn': d.nidn,
          'nama': d.nama,
          'prodi': d.kodeProdi,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteDosen(String nidn) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM dosen WHERE nidn = @nidn'),
        parameters: {'nidn': nidn},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveMahasiswa(Mahasiswa m) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO mahasiswa (nim, nama_lengkap, jk, kode_prodi, tanggal_lahir, '
            'angkatan, is_aktif, dosen_pembimbing_nidn) VALUES (@nim, @nama, @jk, @prodi, @tgl, '
            '@angkatan, @aktif, @dosen)'),
        parameters: {
          'nim': m.nim,
          'nama': m.namaLengkap,
          'jk': m.jk,
          'prodi': m.kodeProdi,
          'tgl': m.tanggalLahir,
          'angkatan': m.angkatan,
          'aktif': m.isAktif,
          'dosen': m.dosenPembimbingNidn,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateMahasiswa(String oldNim, Mahasiswa m) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE mahasiswa SET nim = @newNim, nama_lengkap = @nama, jk = @jk, '
            'kode_prodi = @prodi, tanggal_lahir = @tgl, angkatan = @angkatan, is_aktif = @aktif, '
            'dosen_pembimbing_nidn = @dosen WHERE nim = @oldNim'),
        parameters: {
          'oldNim': oldNim,
          'newNim': m.nim,
          'nama': m.namaLengkap,
          'jk': m.jk,
          'prodi': m.kodeProdi,
          'tgl': m.tanggalLahir,
          'angkatan': m.angkatan,
          'aktif': m.isAktif,
          'dosen': m.dosenPembimbingNidn,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteMahasiswa(String nim) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM mahasiswa WHERE nim = @nim'),
        parameters: {'nim': nim},
      );
    } finally {
      await conn.close();
    }
  }
  static Future<void> saveMateriKuliah(MateriKuliah m) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('INSERT INTO materi_kuliah (id, id_kelas_kuliah, minggu, judul_bab, deskripsi_bab, created_at) '
            'VALUES (@id, @idKelas, @minggu, @judul, @deskripsi, @createdAt)'),
        parameters: {
          'id': m.id,
          'idKelas': m.idKelasKuliah,
          'minggu': m.minggu,
          'judul': m.judulBab,
          'deskripsi': m.deskripsiBab,
          'createdAt': m.createdAt,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateMateriKuliah(MateriKuliah m) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE materi_kuliah SET minggu = @minggu, judul_bab = @judul, deskripsi_bab = @deskripsi '
            'WHERE id = @id'),
        parameters: {
          'id': m.id,
          'minggu': m.minggu,
          'judul': m.judulBab,
          'deskripsi': m.deskripsiBab,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteMateriKuliah(String id) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM materi_kuliah WHERE id = @id'),
        parameters: {'id': id},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveMateriFile(MateriFile mf) async {
    final conn = await DBConnection.connect();
    try {
      final res = await conn.execute(
        Sql.named('INSERT INTO materi_file (id_materi, nama, tipe, url) '
            'VALUES (@idMateri, @nama, @tipe, @url) RETURNING id'),
        parameters: {
          'idMateri': mf.idMateri,
          'nama': mf.nama,
          'tipe': mf.tipe,
          'url': mf.url,
        },
      );
      if (res.isNotEmpty) {
        mf.id = res[0][0] as int;
      }
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteMateriFile(int id) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM materi_file WHERE id = @id'),
        parameters: {'id': id},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> saveRencanaMateri(RencanaMateri rm) async {
    final conn = await DBConnection.connect();
    try {
      final res = await conn.execute(
        Sql.named('INSERT INTO rencana_materi (id_kelas_kuliah, minggu, judul_bab, sub_bab, sudah_dibahas) '
            'VALUES (@idKelas, @minggu, @judul, @subBab, @dibahas) RETURNING id'),
        parameters: {
          'idKelas': rm.idKelasKuliah,
          'minggu': rm.minggu,
          'judul': rm.judulBab,
          'subBab': rm.subBab,
          'dibahas': rm.sudahDibahas,
        },
      );
      if (res.isNotEmpty) {
        rm.id = res[0][0] as int;
      }
    } finally {
      await conn.close();
    }
  }

  static Future<void> updateRencanaMateri(RencanaMateri rm) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('UPDATE rencana_materi SET minggu = @minggu, judul_bab = @judul, '
            'sub_bab = @subBab, sudah_dibahas = @dibahas WHERE id = @id'),
        parameters: {
          'id': rm.id,
          'minggu': rm.minggu,
          'judul': rm.judulBab,
          'subBab': rm.subBab,
          'dibahas': rm.sudahDibahas,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<void> deleteRencanaMateri(int id) async {
    final conn = await DBConnection.connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM rencana_materi WHERE id = @id'),
        parameters: {'id': id},
      );
    } finally {
      await conn.close();
    }
  }
}
