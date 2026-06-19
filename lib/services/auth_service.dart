import '../data/app_data.dart';
import '../database/db_connection.dart';
import '../models/user.dart';
import 'package:postgres/postgres.dart';

class AuthService {
  const AuthService();

  Future<User?> login(String username, String password) async {
    final conn = await DBConnection.connect();
    try {
      final inputUsername = username.trim().toLowerCase();
      final inputPassword = password.trim();

      final result = await conn.execute(
        Sql.named(
          'SELECT username, password, nama, identifier, role, kode_prodi '
          'FROM users '
          'WHERE (LOWER(username) = @u OR LOWER(identifier) = @u) '
          'AND password = @p',
        ),
        parameters: {'u': inputUsername, 'p': inputPassword},
      );

      if (result.isEmpty) return null;

      final row = result.first;
      final user = User(
        username: row[0] as String,
        password: row[1] as String,
        nama: row[2] as String,
        identifier: row[3] as String,
        role: row[4] as String,
        kodeProdi: row[5] as String?,
      );

      await _setCurrentUser(user, conn);
      return user;
    } finally {
      await conn.close();
    }
  }

  Future<void> _setCurrentUser(User user, dynamic conn) async {
    AppData.currentNim = '';
    AppData.currentDosenNidn = '';
    AppData.currentDosenNama = '';
    AppData.currentDosenProdi = '';
    AppData.currentAdminProdiKode = '';
    AppData.currentAdminProdiNama = '';

    if (user.role == 'mahasiswa') {
      AppData.currentNim = user.identifier;
    }

    if (user.role == 'dosen') {
      final result = await conn.execute(
        Sql.named(
          'SELECT nidn, nama, kode_prodi FROM dosen WHERE nidn = @nidn',
        ),
        parameters: {'nidn': user.identifier},
      );
      if (result.isNotEmpty) {
        final row = result.first;
        AppData.currentDosenNidn = row[0] as String;
        AppData.currentDosenNama = row[1] as String;
        AppData.currentDosenProdi = row[2] as String;
      }
    }

    if (user.role == 'admin_prodi' || user.role == 'pimpinan_prodi') {
      AppData.currentAdminProdiKode = user.kodeProdi ?? '';
      AppData.currentAdminProdiNama = user.nama;
    }
  }

  // Untuk autocomplete di login page
  Future<List<User>> getAllUsers() async {
    final conn = await DBConnection.connect();
    try {
      final result = await conn.execute(
        'SELECT username, password, nama, identifier, role, kode_prodi '
        'FROM users ORDER BY role, username',
      );
      return result
          .map(
            (row) => User(
              username: row[0] as String,
              password: row[1] as String,
              nama: row[2] as String,
              identifier: row[3] as String,
              role: row[4] as String,
              kodeProdi: row[5] as String?,
            ),
          )
          .toList();
    } finally {
      await conn.close();
    }
  }
}
