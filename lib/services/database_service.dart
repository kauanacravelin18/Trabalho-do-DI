import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('obra_tech.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    /// ================== OBRAS ==================
    await db.execute('''
      CREATE TABLE obras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        endereco TEXT,
        responsavel TEXT
      )
    ''');

    /// ================== ALERTAS ==================
    await db.execute('''
      CREATE TABLE alertas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mensagem TEXT,
        data TEXT
      )
    ''');

    /// ================== USUÁRIOS ==================
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');
  }

  // =====================================================
  // OBRAS
  // =====================================================

  Future<int> inserirObra(Map<String, dynamic> obra) async {
    final db = await instance.database;
    return await db.insert('obras', obra);
  }

  Future<List<Map<String, dynamic>>> buscarObras() async {
    final db = await instance.database;
    return await db.query('obras');
  }

  Future<int> deletarObra(int id) async {
    final db = await instance.database;

    return await db.delete('obras', where: 'id = ?', whereArgs: [id]);
  }

  // =====================================================
  // ALERTAS
  // =====================================================

  Future<int> inserirAlerta(Map<String, dynamic> alerta) async {
    final db = await instance.database;

    return await db.insert('alertas', alerta);
  }

  Future<List<Map<String, dynamic>>> buscarAlertas() async {
    final db = await instance.database;

    return await db.query('alertas', orderBy: 'id DESC');
  }

  Future<void> limparAlertasDB() async {
    final db = await instance.database;

    await db.delete('alertas');
  }

  // =====================================================
  // USUÁRIOS
  // =====================================================

  Future<int> inserirUsuario(Map<String, dynamic> usuario) async {
    final db = await instance.database;

    return await db.insert(
      'usuarios',
      usuario,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> buscarUsuarioPorEmail(String email) async {
    final db = await instance.database;

    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<bool> atualizarSenha(String email, String novaSenha) async {
    final db = await instance.database;

    final linhas = await db.update(
      'usuarios',
      {'senha': novaSenha},
      where: 'email = ?',
      whereArgs: [email],
    );

    return linhas > 0;
  }

  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final db = await instance.database;

    return await db.query('usuarios', orderBy: 'nome');
  }

  Future<int> excluirUsuario(int id) async {
    final db = await instance.database;

    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
