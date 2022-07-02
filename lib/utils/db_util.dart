import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DbUtil {
  //operações com o bd SQLite
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
        //executa o ddl para cirar o banco
        return db.execute('''CREATE TABLE places (
                id TEXT PRIMARY KEY, 
                title TEXT, 
                image TEXT, 
                lat REAL, 
                long REAL, 
                address TEXT, 
                phone TEXT,
                create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
              )''');
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DbUtil.database();
    await db.insert(
      table,
      data,
      conflictAlgorithm: sql
          .ConflictAlgorithm.replace, //se inserir algo conlfitante (substitui)
    );
  }

  static Future<List<Map<String, dynamic>>> selectOldestRecord() async {
    final db = await DbUtil.database();
    return db
        .rawQuery('SELECT min(create_at), count(1) amount, id FROM places;');
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DbUtil.database();
    return db.query(table);
  }

  static Future<void> deleteById(String oldestId) async {
    final db = await DbUtil.database();
    print('DELETE from places WHERE id = $oldestId;');
    db.rawQuery("DELETE from places WHERE id = '$oldestId';");
  }
}
