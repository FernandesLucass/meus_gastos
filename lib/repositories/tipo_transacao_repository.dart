import '../database/database_helper.dart';
import '../models/tipo_transacao.dart';

class TipoTransacaoRepository {
  final dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<int> insert(TipoTransacao tipo) async {
    final db = await dbHelper.database;
    return await db.insert('tipos_transacao', tipo.toMap());
  }

  // READ
  Future<List<TipoTransacao>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tipos_transacao');

    return List.generate(maps.length, (i) {
      return TipoTransacao.fromMap(maps[i]);
    });
  }

  // UPDATE
  Future<int> update(TipoTransacao tipo) async {
    final db = await dbHelper.database;
    return await db.update(
      'tipos_transacao',
      tipo.toMap(),
      where: 'id = ?',
      whereArgs: [tipo.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('tipos_transacao', where: 'id = ?', whereArgs: [id]);
  }
}
