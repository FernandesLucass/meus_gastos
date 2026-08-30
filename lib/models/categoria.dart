class Categoria {
  final int? id;
  final String nome;
  final int isSaida; // 1 para saída, 0 para entrada

  Categoria({this.id, required this.nome, required this.isSaida});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'is_saida': isSaida};
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
      isSaida: map['is_saida'],
    );
  }
}
