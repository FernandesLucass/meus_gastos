// 1. Flutter & Pacotes
import 'package:flutter/material.dart';

// 2. Core (Tema & Cores)
import '../core/app_colors.dart';
import '../core/app_typography.dart';

// 3. Models
import '../models/conta.dart';
import '../models/tipo_transacao.dart';
import '../models/categoria.dart';
import '../models/sub_categoria.dart';
import '../models/lancamento.dart';

// 4. Repositories
import '../repositories/conta_repository.dart';
import '../repositories/tipo_transacao_repository.dart';
import '../repositories/categoria_repository.dart';
import '../repositories/lancamento_repository.dart';

// 5. Services
import '../services/sincronizacao_service.dart';

// -----------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Controladores
  final TextEditingController _valorController = TextEditingController(
    text: '0,00',
  );

  // 2. Repositórios (Comunicação com SQLite)
  final ContaRepository _contaRepo = ContaRepository();
  final TipoTransacaoRepository _tipoTransacaoRepo = TipoTransacaoRepository();
  final CategoriaRepository _categoriaRepo = CategoriaRepository();
  final LancamentoRepository _lancamentoRepo = LancamentoRepository();

  // 3. Listas carregadas do Banco
  List<Conta> _contas = [];
  List<TipoTransacao> _tiposTransacao = [];
  List<Categoria> _categorias = [];
  List<SubCategoria> _subCategorias = [];

  // 4. Estado da Seleção Atual
  bool _isDespesa = true;
  Conta? _contaSelecionada; // Trocamos de String para o objeto Conta
  TipoTransacao? _tipoTransacaoSelecionada;
  Categoria? _categoriaSelecionada;
  SubCategoria? _subCategoriaSelecionada;

  int _qtdPendentes = 0;

  // Cria essa função para o app saber quantos faltam
  Future<void> _checarPendentes() async {
    final pendentes = await _lancamentoRepo.getLancamentosParaSincronizar();
    setState(() {
      _qtdPendentes = pendentes.length;
    });
  }

  // Métodos:

  @override
  void initState() {
    super.initState();
    _carregarCategorias(); // Puxa os dados logo que a tela abre
    _carregarContas();
    _carregarTiposTransacao();
    _checarPendentes();
  }

  @override
  void dispose() {
    _valorController.dispose(); // Libera a memória do controlador do teclado
    super.dispose();
  }

  Future<void> _carregarContas() async {
    // Supondo que seu repo tenha um método getAll ou similar que traga ordenado por ID
    final contasBanco = await _contaRepo.getAll();
    setState(() {
      _contas = contasBanco;
      if (_contas.isNotEmpty) {
        // Já deixa o Nubank (primeiro da lista) selecionado por padrão!
        _contaSelecionada = _contas.first;
      }
    });
  }

  Future<void> _carregarTiposTransacao() async {
    final tiposBanco = await _tipoTransacaoRepo.getAll();
    setState(() {
      _tiposTransacao = tiposBanco;
      if (_tiposTransacao.isNotEmpty) {
        _tipoTransacaoSelecionada = _tiposTransacao.first;
      }
    });
  }

  Future<void> _carregarCategorias() async {
    // Busca no banco: 1 se for Despesa, 0 se for Receita
    final tipo = _isDespesa ? 1 : 0;
    final categoriasBanco = await _categoriaRepo.getByTipo(tipo);

    setState(() {
      _categorias = categoriasBanco;
      // Limpa as seleções e a lista de subcategorias ao trocar o tipo!
      _categoriaSelecionada = null;
      _subCategoriaSelecionada = null;
      _subCategorias = [];
    });
  }

  Future<void> _carregarSubCategorias(int categoriaId) async {
    final subBanco = await _categoriaRepo.getSubCategorias(categoriaId);
    setState(() {
      _subCategorias = subBanco;
      _subCategoriaSelecionada =
          null; // Reseta a subcategoria ao trocar de categoria
    });
  }

  Future<void> _salvarTransacao() async {
    // 1. Validação de segurança
    if (_categoriaSelecionada == null ||
        _contaSelecionada == null ||
        _tipoTransacaoSelecionada == null ||
        _valorController.text == '0,00') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o valor e selecione as opções obrigatórias!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 2. Converte o valor de texto ("8.000,00") para double (8000.00)
    String valorLimpo = _valorController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    double valorConvertido = double.parse(valorLimpo);

    // 3. Monta o objeto (AJUSTE OS NOMES DOS CAMPOS CONFORME SEU MODEL)
    final novoLancamento = Lancamento(
      valor: valorConvertido,
      isSaida: _isDespesa ? 1 : 0, // Adapte caso seu banco use boolean
      dataLancamento: DateTime.now()
          .toIso8601String(), // Adapte se usar DateTime direto
      contaId: _contaSelecionada!.id!,
      categoriaId: _categoriaSelecionada!.id!,
      subCategoriaId: _subCategoriaSelecionada!.id!,
      tipoTransacaoId: _tipoTransacaoSelecionada!.id!,
    );

    // 4. Salva no banco!
    await _lancamentoRepo.insert(
      novoLancamento,
    ); // Ajuste o nome da função do repo se necessário

    // 5. Mostra o sucesso
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transação salva com sucesso! 🚀'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // 6. Limpa a tela
    _limparFormulario();
    await _checarPendentes();
  }

  void _limparFormulario() {
    setState(() {
      _valorController.text = '0,00';
      _isDespesa = true;
    });
    // Como a função abaixo já limpa a categoria e subcategoria e busca as despesas,
    // basta chamá-la aqui para resetar o resto da tela!
    _carregarCategorias();
    _carregarContas();
    _carregarTiposTransacao();
  }

  void _confirmarSincronizacao() async {
    // 1. Abre o modal e ESPERA a resposta do usuário
    final bool? confirmou = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        // Renomeado para não dar conflito
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sincronizar $_qtdPendentes transações?',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Estes lançamentos serão enviados para a sua planilha de Controle Financeiro no Google Sheets.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // BOTÕES
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // Retorna FALSE ou null
                      onPressed: () => Navigator.pop(modalContext, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      // Retorna TRUE para a tela principal
                      onPressed: () => Navigator.pop(modalContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sincronizar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    // 2. O modal já fechou. Se o usuário clicou em "Sincronizar" (true), fazemos o trabalho aqui!
    if (confirmou == true) {
      if (!mounted) {
        return;
      } // Segurança para saber se a Home Screen ainda existe

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronizando com a planilha...')),
      );

      final sucesso = await SincronizacaoService().sincronizar();

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronização concluída com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Agora sim a tela principal será atualizada corretamente!
        await _checarPendentes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao sincronizar. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. CABEÇALHO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Entrada Rápida', style: AppTypography.title),
                  SizedBox(height: 4),
                  Text(
                    'Registre uma nova transação instantaneamente',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. CARD DO VALOR
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text('VALOR DA TRANSAÇÃO', style: AppTypography.label),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'R\$ ',
                      style: AppTypography.amount.copyWith(
                        fontSize: 28,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _valorController,
                        keyboardType: TextInputType
                            .number, // Chama o teclado numérico do celular
                        style: AppTypography.amount,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          // 1. Remove tudo que não for número
                          String apenasNumeros = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (apenasNumeros.isEmpty) apenasNumeros = '0';

                          // 2. Divide por 100 para criar os centavos reais
                          double valor = double.parse(apenasNumeros) / 100;

                          // 3. Separa os reais dos centavos
                          List<String> partes = valor
                              .toStringAsFixed(2)
                              .split('.');

                          // 4. Adiciona o ponto de milhar na parte dos reais (Regex mágica)
                          String reais = partes[0].replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                          );

                          // 5. Junta tudo formatado: Reais + Vírgula + Centavos
                          String valorFormatado = '$reais,${partes[1]}';

                          // 6. Atualiza o campo mantendo o cursor sempre no final
                          _valorController.value = TextEditingValue(
                            text: valorFormatado,
                            selection: TextSelection.collapsed(
                              offset: valorFormatado.length,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. SELETOR DE DESPESA / RECEITA
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                // A "pílula" verde que desliza
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: _isDespesa
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5, // Ocupa metade do espaço
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // Os textos clicáveis por cima
                Row(
                  children: [
                    // 1. CAIXINHA DA DESPESA
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isDespesa) {
                            setState(() => _isDespesa = true);
                            _carregarCategorias();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Despesa',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: _isDespesa
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _isDespesa
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. CAIXINHA DA RECEITA
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isDespesa) {
                            setState(() => _isDespesa = false);
                            _carregarCategorias();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Receita',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: !_isDespesa
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: !_isDespesa
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 4. SELETOR DE CONTA / BANCO (Estilo Chips)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CONTA / BANCO', style: AppTypography.label),
              const SizedBox(height: 2),
              Wrap(
                spacing: 2.0,
                runSpacing: 2.0,
                children: _contas.map((conta) {
                  // Compara pelo ID para saber qual está selecionada
                  final isSelected = _contaSelecionada?.id == conta.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _contaSelecionada = conta;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        conta.nome, // Mostra o nome vindo do banco
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. SELETOR DE TIPO DE TRANSAÇÃO (Estilo Chips)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TIPO DA TRANSAÇÃO', style: AppTypography.label),
              const SizedBox(height: 2),
              Wrap(
                spacing: 2.0,
                runSpacing: 2.0,
                direction: Axis.horizontal,
                children: _tiposTransacao.map((tipo) {
                  final isSelected = _tipoTransacaoSelecionada?.id == tipo.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tipoTransacaoSelecionada = tipo;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        tipo.nome, // Puxa o nome direto do objeto
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 6. SELETOR DE CATEGORIA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CATEGORIA', style: AppTypography.label),
              const SizedBox(height: 2),
              DropdownButtonFormField<Categoria>(
                initialValue: _categoriaSelecionada,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                hint: const Text('Selecione uma categoria'),
                items: _categorias.map((Categoria cat) {
                  return DropdownMenuItem<Categoria>(
                    value: cat,
                    child: Text(cat.nome, style: AppTypography.input),
                  );
                }).toList(),
                onChanged: (novaCategoria) {
                  setState(() {
                    _categoriaSelecionada = novaCategoria;
                  });
                  if (novaCategoria != null) {
                    _carregarSubCategorias(novaCategoria.id!);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 7. SELETOR DE SUBCATEGORIA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SUBCATEGORIA', style: AppTypography.label),
              const SizedBox(height: 2),
              DropdownButtonFormField<SubCategoria>(
                initialValue: _subCategoriaSelecionada,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                hint: const Text('Selecione uma subcategoria'), // Se não tiver subcategorias, passa null para desabilitar o campo
                items: _subCategorias.isEmpty
                    ? null
                    : _subCategorias.map((SubCategoria sub) {
                        return DropdownMenuItem<SubCategoria>(
                          value: sub,
                          child: Text(sub.nome, style: AppTypography.input),
                        );
                      }).toList(),
                onChanged: _subCategorias.isEmpty
                    ? null
                    : (novaSub) {
                        setState(() {
                          _subCategoriaSelecionada = novaSub;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 8. BOTÃO SALVAR TRANSAÇÃO
          ElevatedButton(
            onPressed: _salvarTransacao, // Chama a função.
            child: const Text('Salvar Transação'),
          ),

          // 9. BOTÃO SINCRONIZAR COM GOOGLE SHEETS
          TextButton.icon(
            // Se tiver pendentes, abre o modal. Se for 0, fica null (desabilitado)
            onPressed: _qtdPendentes > 0 ? _confirmarSincronizacao : null,
            icon: Icon(
              Icons.sync,
              color: _qtdPendentes > 0
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 18,
            ),
            label: Text(
              'Sincronizar com Google Sheets',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
                color: _qtdPendentes > 0
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}
