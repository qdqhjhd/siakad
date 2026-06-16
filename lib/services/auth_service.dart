import '../data/app_data.dart';
import '../models/user.dart';

class AuthService {
  const AuthService();

  User? login(String username, String password) {
    final inputUsername = username.trim().toLowerCase();
    final inputPassword = password.trim();

    for (final user in AppData.users) {
      if ((user.username.toLowerCase() == inputUsername ||
              user.identifier.toLowerCase() == inputUsername) &&
          user.password == inputPassword) {
        _setCurrentUser(user);
        return user;
      }
    }
    return null;
  }

  void _setCurrentUser(User user) {
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
      final dosen = AppData.daftarDosen.firstWhere(
        (d) => d.nidn == user.identifier,
      );
      AppData.currentDosenNidn = dosen.nidn;
      AppData.currentDosenNama = dosen.nama;
      AppData.currentDosenNidn = dosen.nidn;
      AppData.currentDosenProdi = dosen.kodeProdi;
    }

    if (user.role == 'admin_prodi' || user.role == 'pimpinan_prodi') {
      AppData.currentAdminProdiKode = user.kodeProdi ?? '';
      AppData.currentAdminProdiNama = user.nama;
    }
  }
}
