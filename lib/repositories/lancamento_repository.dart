import '../database/database_helper.dart';
import '../models/lancamento.dart';

class LancamentoRepository {
  final dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<int> insert(Lancamento lancamento) async {
    final db = await dbHelper.database;
    return await db.insert('lancamentos', lancamento.toMap());
  }

  // READ - Traz todos os lançamentos ordenados por data (mais recentes primeiro)
  Future<List<Lancamento>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lancamentos',
      orderBy: 'data_lancamento DESC',
    );

    return List.generate(maps.length, (i) {
      return Lancamento.fromMap(maps[i]);
    });
  }

  // UPDATE
  Future<int> update(Lancamento lancamento) async {
    final db = await dbHelper.database;
    return await db.update(
      'lancamentos',
      lancamento.toMap(),
      where: 'id = ?',
      whereArgs: [lancamento.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('lancamentos', where: 'id = ?', whereArgs: [id]);
  }
}
