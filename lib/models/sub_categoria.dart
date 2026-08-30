class SubCategoria {
  final int? id;
  final String nome;
  final int categoriaId; // O elo de ligação com a tabela Categorias

  SubCategoria({this.id, required this.nome, required this.categoriaId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'categoria_id': categoriaId};
  }

  factory SubCategoria.fromMap(Map<String, dynamic> map) {
    return SubCategoria(
      id: map['id'],
      nome: map['nome'],
      categoriaId: map['categoria_id'],
    );
  }
}
