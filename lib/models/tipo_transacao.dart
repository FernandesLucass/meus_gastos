class TipoTransacao {
  final int? id;
  final String nome;

  TipoTransacao({this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  factory TipoTransacao.fromMap(Map<String, dynamic> map) {
    return TipoTransacao(id: map['id'], nome: map['nome']);
  }
}
