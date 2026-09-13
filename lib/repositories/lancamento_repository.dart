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
        l.sincronizado,
        l.valor, 
        l.is_saida, 
        l.data_lancamento, 
        l.conta_id,
        l.tipo_transacao_id,
        l.categoria_id,
        l.sub_categoria_id,
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

  Future<List<Map<String, dynamic>>> getLancamentosPorMes(
    int ano,
    int mes,
  ) async {
    final db = await DatabaseHelper.instance.database;

    // Formata o mês para ficar com dois dígitos (ex: 08)
    String mesFormatado = mes.toString().padLeft(2, '0');
    String dataFiltro = '$ano-$mesFormatado%';

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT 
        l.id, 
        l.sincronizado,
        l.valor, 
        l.is_saida, 
        l.data_lancamento, 
        l.conta_id,
        l.tipo_transacao_id,
        l.categoria_id,
        l.sub_categoria_id,
        c.nome AS categoria_nome,
        co.nome AS conta_nome,
        t.nome AS tipo_transacao_nome
      FROM lancamentos l
      INNER JOIN categorias c ON l.categoria_id = c.id
      INNER JOIN contas co ON l.conta_id = co.id
      INNER JOIN tipos_transacao t ON l.tipo_transacao_id = t.id
      WHERE l.data_lancamento LIKE ?
      ORDER BY l.data_lancamento DESC
    ''',
      [dataFiltro],
    );

    return result;
  }

  Future<int> atualizarLancamentoCompleto(
    int id,
    double valor,
    int isSaida,
    int categoriaId,
    int contaId,
    int tipoTransacaoId,
    int subCategoriaId,
  ) async {
    final db = await DatabaseHelper.instance.database;

    return await db.rawUpdate(
      '''
      UPDATE lancamentos 
      SET valor = ?, is_saida = ?, categoria_id = ?, conta_id = ?, tipo_transacao_id = ?, sub_categoria_id = ?
      WHERE id = ?
    ''',
      [
        valor,
        isSaida,
        categoriaId,
        contaId,
        tipoTransacaoId,
        subCategoriaId,
        id,
      ],
    );
  }

  Future<int> excluirLancamentosEmLote(List<int> ids) async {
    final db = await DatabaseHelper.instance.database;

    // Cria as interrogações de acordo com a quantidade de IDs (ex: "?, ?, ?")
    final placeholders = List.filled(ids.length, '?').join(',');

    return await db.rawDelete(
      'DELETE FROM lancamentos WHERE id IN ($placeholders)',
      ids,
    );
  }

  // 1. Busca quem tem sincronizado == 0
  Future<List<Map<String, dynamic>>> getLancamentosParaSincronizar() async {
    final db = await DatabaseHelper.instance.database;

    return await db.rawQuery('''
      SELECT 
        l.id,
        l.valor, 
        l.is_saida, 
        l.data_lancamento, 
        c.nome AS categoria_nome,
        co.nome AS conta_nome,
        sc.nome AS sub_categoria_nome
      FROM lancamentos l
      LEFT JOIN categorias c ON l.categoria_id = c.id
      LEFT JOIN contas co ON l.conta_id = co.id
      LEFT JOIN sub_categorias sc ON l.sub_categoria_id = sc.id
      WHERE l.sincronizado = 0
    ''');
  }

  // 2. Atualiza a flag para 1 após o sucesso
  Future<int> marcarComoSincronizados(List<int> ids) async {
    final db = await DatabaseHelper.instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');

    return await db.rawUpdate(
      'UPDATE lancamentos SET sincronizado = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }
}
