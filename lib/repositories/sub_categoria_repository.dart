import '../database/database_helper.dart';
import '../models/sub_categoria.dart';

class SubCategoriaRepository {
  final dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<int> insert(SubCategoria subCategoria) async {
    final db = await dbHelper.database;
    return await db.insert('sub_categorias', subCategoria.toMap());
  }

  // READ
  Future<List<SubCategoria>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sub_categorias');

    return List.generate(maps.length, (i) {
      return SubCategoria.fromMap(maps[i]);
    });
  }

  // UPDATE
  Future<int> update(SubCategoria subCategoria) async {
    final db = await dbHelper.database;
    return await db.update(
      'sub_categorias',
      subCategoria.toMap(),
      where: 'id = ?',
      whereArgs: [subCategoria.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('sub_categorias', where: 'id = ?', whereArgs: [id]);
  }
}
