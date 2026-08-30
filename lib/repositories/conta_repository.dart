import '../database/database_helper.dart';
import '../models/conta.dart';

class ContaRepository {
  final dbHelper = DatabaseHelper.instance;

  // CREATE (Inserir nova conta)
  Future<int> insert(Conta conta) async {
    final db = await dbHelper.database;
    return await db.insert('contas', conta.toMap());
  }

  // READ (Buscar todas as contas)
  Future<List<Conta>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('contas');

    // Converte a lista de Maps que vem do banco para uma lista de objetos Conta
    return List.generate(maps.length, (i) {
      return Conta.fromMap(maps[i]);
    });
  }

  // UPDATE (Atualizar uma conta existente)
  Future<int> update(Conta conta) async {
    final db = await dbHelper.database;
    return await db.update(
      'contas',
      conta.toMap(),
      where: 'id = ?',
      whereArgs: [conta.id], // Substitui a interrogação pelo ID correto
    );
  }

  // DELETE (Excluir uma conta)
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('contas', where: 'id = ?', whereArgs: [id]);
  }
}
