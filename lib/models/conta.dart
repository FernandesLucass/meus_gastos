class Conta {
  final int? id; // Pode ser nulo, porque o ID é gerado automaticamente pelo banco de dados.
  final String nome;

  Conta({this.id, required this.nome});

  // Transforma o Objeto Dart em um Map para o SQLite (INSERT/UPDATE)
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  // Constrói o Objeto Dart a partir do Map que vem do SQLite (SELECT)
  factory Conta.fromMap(Map<String, dynamic> map) {
    return Conta(id: map['id'], nome: map['nome']);
  }
}
