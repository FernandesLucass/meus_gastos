class Lancamento {
  final int? id;
  final double valor;
  final int isSaida; // 1 para saída, 0 para entrada
  final String dataLancamento; // No SQLite salvamos datas como String
  final int contaId;
  final int tipoTransacaoId;
  final int categoriaId;
  final int subCategoriaId; // Pode ser nulo, caso não tenha subcategoria

  Lancamento({
    this.id,
    required this.valor,
    required this.isSaida,
    required this.dataLancamento,
    required this.contaId,
    required this.tipoTransacaoId,
    required this.categoriaId,
    required this.subCategoriaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valor': valor,
      'is_saida': isSaida,
      'data_lancamento': dataLancamento,
      'conta_id': contaId,
      'tipo_transacao_id': tipoTransacaoId,
      'categoria_id': categoriaId,
      'sub_categoria_id': subCategoriaId,
    };
  }

  factory Lancamento.fromMap(Map<String, dynamic> map) {
    return Lancamento(
      id: map['id'],
      valor: map['valor'],
      isSaida: map['is_saida'],
      dataLancamento: map['data_lancamento'],
      contaId: map['conta_id'],
      tipoTransacaoId: map['tipo_transacao_id'],
      categoriaId: map['categoria_id'],
      subCategoriaId: map['sub_categoria_id'],
    );
  }
}
