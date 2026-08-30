# meus_gastos

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

lib/
├── core/          # O "coração" do app: temas importados do Figma, cores, fontes e variáveis globais.
├── database/      # Configuração inicial do SQLite e estruturação das tabelas (o motor do banco).
├── models/        # Os moldes dos seus dados (ex: classes Lancamento, Categoria, Conta).
├── repositories/  # Onde ficam as funções de CRUD (Insert, Select, Update, Delete) que conversam com o banco.
├── screens/       # As telas completas projetadas no Figma (uma por arquivo).
├── widgets/       # Os componentes visuais reaproveitáveis (botões padronizados, cards de transação, inputs).
└── main.dart      # Limpo e enxuto, servindo exclusivamente para iniciar o aplicativo.