import '../database/database_helper.dart';
import '../models/categoria.dart';
import '../models/sub_categoria.dart'; // Importamos a subcategoria também

class CategoriaRepository {
  final dbHelper = DatabaseHelper.instance;

  // CREATE (Insere Categoria)
  Future<int> insert(Categoria categoria) async {
    final db = await dbHelper.database;
    return await db.insert('categorias', categoria.toMap());
  }

  // READ - Busca TODAS as categorias (geral)
  Future<List<Categoria>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categorias');

    return List.generate(maps.length, (i) {
      return Categoria.fromMap(maps[i]);
    });
  }

  // READ FILTRADO - Busca só Entrada (0) ou só Saída (1)
  Future<List<Categoria>> getByTipo(int isSaida) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categorias',
      where: 'is_saida = ?',
      whereArgs: [isSaida],
    );

    return List.generate(maps.length, (i) {
      return Categoria.fromMap(maps[i]);
    });
  }

  // Busca todas as subcategorias pertencentes a uma Categoria específica
  Future<List<SubCategoria>> getSubCategorias(int categoriaId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_categorias',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
    );

    return List.generate(maps.length, (i) {
      return SubCategoria.fromMap(maps[i]);
    });
  }

  // UPDATE
  Future<int> update(Categoria categoria) async {
    final db = await dbHelper.database;
    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }
}
