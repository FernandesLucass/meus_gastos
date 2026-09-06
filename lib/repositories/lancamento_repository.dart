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

  Future<List<Map<String, dynamic>>> getLancamentosSemana() async {
    final db = await DatabaseHelper.instance.database; 
    
    // Adicionamos os JOINs da conta e do tipo de transação
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        l.id, 
        l.valor, 
        l.is_saida, 
        l.data_lancamento, 
        c.nome AS categoria_nome,
        co.nome AS conta_nome,
        t.nome AS tipo_transacao_nome
      FROM lancamentos l
      INNER JOIN categorias c ON l.categoria_id = c.id
      INNER JOIN contas co ON l.conta_id = co.id
      INNER JOIN tipos_transacao t ON l.tipo_transacao_id = t.id
      ORDER BY l.data_lancamento DESC
      LIMIT 15
    ''');
    
    return result;
  }
}
