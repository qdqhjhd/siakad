import 'package:postgres/postgres.dart';

class DBConnection {
  static Future<Connection> connect() async {
    final conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'vidi_db', // 
        username: 'postgres',
        password: 'flocka',      // 
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
    return conn;
  }
}