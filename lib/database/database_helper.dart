import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static const _databaseName = "meus_gastos.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = '';

    // Se for Desktop (Linux/Windows), usa o FFI e salva na raiz do projeto
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;

      path = join(Directory.current.path, _databaseName);

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
        ),
      );
    } else {
      // Se for Android, usa o caminho padrão isolado do sistema
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    }
  }

  Future _onCreate(Database db, int version) async {
    // 1. Contas (Bancos, Carteira, etc)
    await db.execute('''
      CREATE TABLE contas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');

    // 2. Tipos de Transação (Pix, Crédito, Débito, etc)
    await db.execute('''
      CREATE TABLE tipos_transacao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');

    // 3. Categorias (separando se é para Entrada ou Saída)
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        is_saida INTEGER NOT NULL 
      )
    ''');

    // 4. Sub-categorias (filhas de uma Categoria específica)
    await db.execute('''
      CREATE TABLE sub_categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        categoria_id INTEGER NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON DELETE CASCADE
      )
    ''');

    // 5. Lançamentos (A tabela principal que conecta tudo)
    await db.execute('''
      CREATE TABLE lancamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valor REAL NOT NULL,
        is_saida INTEGER NOT NULL,
        data_lancamento TEXT NOT NULL,
        conta_id INTEGER NOT NULL,
        tipo_transacao_id INTEGER NOT NULL,
        categoria_id INTEGER NOT NULL,
        sub_categoria_id INTEGER NOT NULL,
        FOREIGN KEY (conta_id) REFERENCES contas (id),
        FOREIGN KEY (tipo_transacao_id) REFERENCES tipos_transacao (id),
        FOREIGN KEY (categoria_id) REFERENCES categorias (id),
        FOREIGN KEY (sub_categoria_id) REFERENCES sub_categorias (id)
      )
    ''');

    debugPrint("Banco criado com sucesso!");

    // 1. Inserindo Contas Padrão
    final contasIniciais = [
      'Carteira',
      'Nubank',
      'Caixa',
      'Méliuz',
      'Viacredi',
      'Mercado Pago',
      'Flash',
      'Next',
    ];
    for (var conta in contasIniciais) {
      await db.insert('contas', {'nome': conta});
    }

    // 2. Inserindo Tipos de Transação
    final tiposIniciais = [
      'Pix',
      'Cartão de Crédito',
      'Cartão de Débito',
      'Transferência',
      'Dinheiro',
    ];
    for (var tipo in tiposIniciais) {
      await db.insert('tipos_transacao', {'nome': tipo});
    }

    // --- CARGA INICIAL (SEED) - CATEGORIAS DE SAÍDA ---

    final Map<String, List<String>> categoriasSaida = {
      "Alimentação": [
        "Bebidas",
        "Cafeterias",
        "Delivery",
        "Docerias",
        "Energéticos",
        "Feiras e Hortifrúti",
        "Lanches e Snacks",
        "Restaurantes",
        "Sucos",
        "Supermercado",
      ],
      "Assinaturas e Serviços Recorrentes": [
        "Aplicativos Mobile",
        "Backup e Armazenamento",
        "Internet Móvel",
        "Serviços de Software",
        "Streaming de Música",
        "Streaming de Vídeo",
      ],
      "Compras Diversas": [
        "Brinquedos e Jogos",
        "Compras Online",
        "Decoração",
        "Eletrônicos",
        "Itens para Casa",
        "Livros e Revistas",
        "Pets",
        "Presentes",
        "Serviços",
      ],
      "Educação": [
        "Assinaturas Educacionais",
        "Aulas Particulares",
        "Certificações",
        "Cursos e Treinamentos",
        "Faculdade/Escola",
        "Livros e Materiais Didáticos",
        "Workshops e Palestras",
      ],
      "Impostos e Taxas": [
        "Contribuições Sindicais",
        "Imposto de Renda",
        "IPVA",
        "IRPF",
        "Multas",
        "Taxas Bancárias",
        "Taxas de Cartão de Crédito",
      ],
      "Investimentos": [
        "Ações e Fundos",
        "Aportes Mensais",
        "Criptomoedas",
        "Imóveis",
        "Poupança",
        "Previdência Privada",
        "Seguros de Vida",
        "Tesouro Direto",
      ],
      "Lazer e Entretenimento": [
        "Cinema",
        "Clubes e Associações",
        "Esportes e Atividades ao Ar Livre",
        "Hobbies",
        "Jogos e Diversão",
        "Passeios",
        "Saídas com Amigos",
        "Shows e Concertos",
        "Viagens",
      ],
      "Moradia": [
        "Aluguel",
        "Condomínio",
        "Contas de Água",
        "Contas de Luz",
        "Internet",
        "Manutenção",
        "Mobiliário e Decoração",
        "Reformas",
        "Seguro Residencial",
      ],
      "Outros Gastos": [
        "Adiantamentos",
        "Diversos",
        "Doações Esporádicas",
        "Emergências",
        "Empréstimos",
        "Gastos Inesperados",
      ],
      "Presentes e Doações": [
        "Doações em Dinheiro",
        "Doações para Caridade",
        "Eventos Especiais",
        "Lembranças",
        "Presentes de Aniversário",
        "Presentes de Natal",
        "Presentes Karol",
      ],
      "Saúde e Bem-estar": [
        "Academia",
        "Barbearia",
        "Consultas Médicas",
        "Cuidados Pessoais",
        "Exames",
        "Massagens",
        "Medicamentos",
        "Plano de Saúde",
        "Suplementos",
        "Terapias",
      ],
      "Tecnologia": [
        "Acessórios de Tecnologia",
        "Dispositivos Eletrônicos",
        "Gadgets",
        "Manutenção de Equipamentos",
        "Serviços de Nuvem",
        "Serviços de TI",
        "Softwares e Aplicativos",
      ],
      "Veículos": [
        "Aluguel de Veículo",
        "Combustível",
        "Estacionamento",
        "Manutenção do Veículo",
        "Pedágios",
        "Seguro do Veículo",
        "Táxi/Aplicativos de Transporte",
        "Transporte Público",
      ],
      "Vestuário": [
        "Acessórios",
        "Calçados",
        "Compras Online",
        "Lavanderia",
        "Reparos e Ajustes",
        "Roupas",
        "Uniformes",
      ],
    };

    // Laço para varrer o Map e inserir tudo dinamicamente
    for (var entry in categoriasSaida.entries) {
      String categoriaNome = entry.key;
      List<String> subCategorias = entry.value;

      // 1. Insere a Categoria marcando is_saida = 1 e pega o ID gerado
      int categoriaId = await db.insert('categorias', {
        'nome': categoriaNome,
        'is_saida': 1,
      });

      // 2. Insere todas as Subcategorias vinculando ao ID da categoria pai
      for (var subNome in subCategorias) {
        await db.insert('sub_categorias', {
          'nome': subNome,
          'categoria_id': categoriaId,
        });
      }
    }

    // --- CARGA INICIAL (SEED) - CATEGORIAS DE ENTRADA ---

    final Map<String, List<String>> categoriasEntrada = {
      "Outras Entradas": [
        "Presentes em Dinheiro",
        "Reembolsos",
        "Resgate de Investimentos",
        "Restituição de Imposto de Renda",
      ],
      "Rendas Extras": [
        "Cashbacks e Programas de Pontos",
        "Trabalhos Freelance / Serviços",
        "Venda de Itens Usados",
      ],
      "Rendimentos e Investimentos": [
        "Dividendos de Ações",
        "Juros do Tesouro Direto",
        "Rendimentos de FIIs",
        "Rendimentos de Renda Fixa (CDB, LCI/LCA, Poupança)",
      ],
      "Salário e Remuneração": [
        "Adiantamento",
        "Bônus e PLR",
        "Férias e 13º Salário",
        "Horas Extras",
        "Salário Fixo",
      ],
    };

    // Laço para inserir as entradas dinamicamente
    for (var entry in categoriasEntrada.entries) {
      String categoriaNome = entry.key;
      List<String> subCategorias = entry.value;

      // 1. Insere a Categoria marcando is_saida = 0 (Entrada)
      int categoriaId = await db.insert('categorias', {
        'nome': categoriaNome,
        'is_saida': 0,
      });

      // 2. Insere as Subcategorias vinculadas
      for (var subNome in subCategorias) {
        await db.insert('sub_categorias', {
          'nome': subNome,
          'categoria_id': categoriaId,
        });
      }
    }
  }
}
