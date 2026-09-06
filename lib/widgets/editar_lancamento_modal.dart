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

// 4. Repositories
import '../repositories/categoria_repository.dart';
import '../repositories/conta_repository.dart';
import '../repositories/tipo_transacao_repository.dart';
import '../repositories/lancamento_repository.dart';

class EditarLancamentoModal extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAtualizado;

  const EditarLancamentoModal({
    super.key,
    required this.item,
    required this.onAtualizado,
  });

  @override
  State<EditarLancamentoModal> createState() => _EditarLancamentoModalState();
}

class _EditarLancamentoModalState extends State<EditarLancamentoModal> {
  // ==========================================
  // ESTADO DO FORMULÁRIO
  // ==========================================
  late TextEditingController _valorController;
  late bool _isSincronizado;

  // 2. Repositórios (Comunicação com SQLite)
  final CategoriaRepository _categoriaRepo = CategoriaRepository();
  final ContaRepository _contaRepo = ContaRepository();
  final TipoTransacaoRepository _tipoTransacaoRepo = TipoTransacaoRepository();
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

  @override
  void initState() {
    super.initState();
    // 1. Inicializa com os dados do item clicado
    _isSincronizado = widget.item['sincronizado'] == 1;
    _isDespesa = widget.item['is_saida'] == 1;
    _valorController = TextEditingController(
      text: widget.item['valor'].toStringAsFixed(2).replaceAll('.', ','),
    );
    _carregarContas();
    _carregarTiposTransacao();
    _carregarCategorias();
  }

  Future<void> _carregarContas() async {
    final contasBanco = await _contaRepo.getAll();
    if (!mounted) return;

    setState(() {
      _contas = contasBanco;
      _contaSelecionada = contasBanco
          .where((conta) => conta.id == widget.item['conta_id'])
          .firstOrNull;
    });
  }

  Future<void> _carregarTiposTransacao() async {
    final tiposBanco = await _tipoTransacaoRepo.getAll();
    if (!mounted) return;

    setState(() {
      _tiposTransacao = tiposBanco;
      _tipoTransacaoSelecionada = tiposBanco
          .where((tipo) => tipo.id == widget.item['tipo_transacao_id'])
          .firstOrNull;
    });
  }

  Future<void> _carregarCategorias() async {
    // Busca no banco: 1 se for Despesa, 0 se for Receita
    final tipo = _isDespesa ? 1 : 0;
    final categoriasBanco = await _categoriaRepo.getByTipo(tipo);
    final categoriaSelecionada = categoriasBanco
        .where((categoria) => categoria.id == widget.item['categoria_id'])
        .firstOrNull;

    if (!mounted) return;
    setState(() {
      _categorias = categoriasBanco;
      _categoriaSelecionada = categoriaSelecionada;
      _subCategoriaSelecionada = null;
      _subCategorias = [];
    });

    if (categoriaSelecionada != null) {
      await _carregarSubCategorias(categoriaSelecionada.id!);
    }
  }

  Future<void> _carregarSubCategorias(int categoriaId) async {
    final subBanco = await _categoriaRepo.getSubCategorias(categoriaId);
    final subCategoriaId = widget.item['sub_categoria_id'];

    if (!mounted) return;
    setState(() {
      _subCategorias = subBanco;
      _subCategoriaSelecionada = subBanco
          .where((sub) => sub.id == subCategoriaId)
          .firstOrNull;
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Esse padding faz o modal subir junto com o teclado do celular
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          // Para permitir rolagem caso o formulário fique grande
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tracinho superior
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Text(
                'Editar Transação',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // ALERTA DE SINCRONIZAÇÃO
              if (_isSincronizado)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Esta transação já foi enviada para a planilha. Alterações feitas aqui serão salvas apenas localmente no celular.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: Colors.orange[200],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // 3. CAMPO DO VALOR
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VALOR DA TRANSAÇÃO',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 4),
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
                            keyboardType: TextInputType.number,
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
                              var apenasNumeros = value.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              if (apenasNumeros.isEmpty) apenasNumeros = '0';

                              final valor = double.parse(apenasNumeros) / 100;
                              final partes = valor
                                  .toStringAsFixed(2)
                                  .split('.');
                              final reais = partes[0].replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (match) => '${match[1]}.',
                              );
                              final valorFormatado = '$reais,${partes[1]}';

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
                      final isSelected =
                          _tipoTransacaoSelecionada?.id == tipo.id;
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

              // BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_categoriaSelecionada == null ||
                        _contaSelecionada == null ||
                        _tipoTransacaoSelecionada == null ||
                        _subCategoriaSelecionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecione todas as opções antes de salvar.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Trata o valor digitado
                    final novoValorTexto = _valorController.text
                        .replaceAll('.', '')
                        .replaceAll(',', '.');
                    final novoValor =
                        double.tryParse(novoValorTexto) ?? widget.item['valor'];
                    final int isSaida = _isDespesa ? 1 : 0;

                    await _lancamentoRepo.atualizarLancamentoCompleto(
                      widget.item['id'],
                      novoValor,
                      isSaida,
                      _categoriaSelecionada!.id!,
                      _contaSelecionada!.id!,
                      _tipoTransacaoSelecionada!.id!,
                      _subCategoriaSelecionada!.id!,
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Fecha o modal
                    }
                    widget.onAtualizado(); // Manda a tela de histórico recarregar a lista
                  },
                  child: const Text(
                    'Salvar Alterações',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
