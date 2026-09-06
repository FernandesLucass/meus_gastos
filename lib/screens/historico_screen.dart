// 1. Flutter & Pacotes
import 'package:flutter/material.dart';

import '../widgets/editar_lancamento_modal.dart'; // <-- IMPORT DO MODAL DE EDIÇÃO
// 2. Core (Tema & Cores)
import '../core/app_colors.dart';
import '../core/app_typography.dart';
import '../core/category_icons.dart';

// 3. Repositories
import '../repositories/lancamento_repository.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  // 1. Controladores e Estado
  final LancamentoRepository _lancamentoRepo = LancamentoRepository();
  List<Map<String, dynamic>> _lancamentos = [];
  bool _isLoading = true;

  // NOVAS VARIÁVEIS PARA O SELETOR DE MÊS
  final DateTime _dataAtual = DateTime.now();
  late DateTime _mesSelecionado;

  final List<String> _nomesMeses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  // Métodos:
  @override
  void initState() {
    super.initState();
    // Começa no mês atual (Ano, Mês, Dia 1 para evitar bugs de virada de mês)
    _mesSelecionado = DateTime(_dataAtual.year, _dataAtual.month, 1);
    _carregarLancamentos();
  }

  // --- Adicione junto das suas outras variáveis ---
  double _totalReceitas = 0.0;
  double _totalDespesas = 0.0;
  double _saldo = 0.0;

  // --- Substitua o método _carregarLancamentos ---
  Future<void> _carregarLancamentos() async {
    // Agora enviamos o ano e o mês para o banco!
    final dados = await _lancamentoRepo.getLancamentosPorMes(
      _mesSelecionado.year,
      _mesSelecionado.month,
    );

    double receitas = 0.0;
    double despesas = 0.0;

    // Calcula os totais
    for (var item in dados) {
      if (item['is_saida'] == 1) {
        despesas += item['valor'];
      } else {
        receitas += item['valor'];
      }
    }

    setState(() {
      _lancamentos = dados;
      _totalReceitas = receitas;
      _totalDespesas = despesas;
      _saldo = receitas - despesas;
      _isLoading = false;
    });
  }

  String _formatarMoeda(double valor) {
    // Separa a parte inteira dos centavos
    final partes = valor.abs().toStringAsFixed(2).split('.');

    // Adiciona o ponto a cada 3 casas (milhar)
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );

    // Junta tudo com a vírgula
    return '$inteiro,${partes[1]}';
  }

  void _abrirModalEdicao(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditarLancamentoModal(
        item: item,
        onAtualizado: _carregarLancamentos, // Atualiza a tela ao fechar
      ),
    );
  }

  // 2. Build
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCabecalho(),
          _buildSeletorMes(),
          _buildResumoMes(),
          const SizedBox(height: 10),
          _buildListaTransacoes(),
        ],
      ),
    );
  }

  // 3. Widgets

  // 1. CABEÇALHO
  Widget _buildCabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seus eventos financeiros recentes',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeletorMes() {
    // Verifica se o mês selecionado é anterior ao mês/ano atual para habilitar o botão de avançar
    bool podeAvancar = _mesSelecionado.isBefore(
      DateTime(_dataAtual.year, _dataAtual.month, 1),
    );
    String nomeMes = _nomesMeses[_mesSelecionado.month - 1];
    String ano = _mesSelecionado.year.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão Voltar (Sempre ativo)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _mesSelecionado = DateTime(
                    _mesSelecionado.year,
                    _mesSelecionado.month - 1,
                    1,
                  );
                  _isLoading = true;
                });
                _carregarLancamentos(); // Recarrega os dados do novo mês
              },
            ),

            // Texto do Mês/Ano
            Text(
              '$nomeMes $ano',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            // Botão Avançar (Ativo apenas se puder avançar)
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: podeAvancar
                    ? Colors.white
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                size: 18,
              ),
              onPressed: podeAvancar
                  ? () {
                      setState(() {
                        _mesSelecionado = DateTime(
                          _mesSelecionado.year,
                          _mesSelecionado.month + 1,
                          1,
                        );
                        _isLoading = true;
                      });
                      _carregarLancamentos(); // Recarrega os dados do novo mês
                    }
                  : null, // null desabilita o botão nativamente
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoMes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // RECEITAS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECEITAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+ R\$ ${_formatarMoeda(_totalReceitas)}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            Container(width: 1, height: 30, color: AppColors.border),
            const SizedBox(width: 12),

            // DESPESAS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESPESAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- R\$ ${_formatarMoeda(_totalDespesas)}',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            Container(width: 1, height: 30, color: AppColors.border),
            const SizedBox(width: 12),

            // SALDO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SALDO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${_formatarMoeda(_saldo)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. LISTA DE TRANSAÇÕES
  Widget _buildListaTransacoes() {
    return Expanded(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lancamentos.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma transação recente.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _lancamentos.length,
              itemBuilder: (context, index) {
                final item = _lancamentos[index];

                // Pega a data do item atual
                final dataDateTime = DateTime.parse(item['data_lancamento']);
                final dataAtualFormatada =
                    "${dataDateTime.day.toString().padLeft(2, '0')}/${dataDateTime.month.toString().padLeft(2, '0')}";

                bool mostrarCabecalho = false;

                // Se for o primeiro item, sempre mostra o cabeçalho
                if (index == 0) {
                  mostrarCabecalho = true;
                } else {
                  // Compara com a data do item anterior
                  final dataAnterior = DateTime.parse(
                    _lancamentos[index - 1]['data_lancamento'],
                  );
                  final dataAnteriorFormatada =
                      "${dataAnterior.day.toString().padLeft(2, '0')}/${dataAnterior.month.toString().padLeft(2, '0')}";

                  if (dataAtualFormatada != dataAnteriorFormatada) {
                    mostrarCabecalho = true;
                  }
                }

                // Se mudou o dia, retorna o título da data + o seu card perfeito
                if (mostrarCabecalho) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 2),
                        child: Text(
                          dataAtualFormatada,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _buildCardTransacao(item),
                    ],
                  );
                }

                // Se for o mesmo dia, retorna só o card
                return _buildCardTransacao(item);
              },
            ),
    );
  }

  // 3. CARD DE TRANSAÇÃO
  // 3. CARD DE TRANSAÇÃO
  Widget _buildCardTransacao(Map<String, dynamic> item) {
    // 1. Extração de dados (SEMPRE VEM PRIMEIRO)
    final isSaida = item['is_saida'] == 1;
    final valor = item['valor'] as double;
    final categoriaNome = item['categoria_nome'] as String;
    final contaNome = item['conta_nome'] as String;
    final tipoTransacaoNome = item['tipo_transacao_nome'] as String;

    // 2. Formatação da Data
    final dataDateTime = DateTime.parse(item['data_lancamento']);
    final dataFormatada =
        "${dataDateTime.day.toString().padLeft(2, '0')}/${dataDateTime.month.toString().padLeft(2, '0')}";

    // 3. Ícone
    final icone =
        CategoryIcons.icones[categoriaNome] ??
        (isSaida
            ? CategoryIcons.icones['GENERIC_SAIDA']
            : CategoryIcons.icones['GENERIC_ENTRADA']);

    // 4. Desenho do Card (O RETURN VEM POR ÚLTIMO)
    return GestureDetector(
      onTap: () => _abrirModalEdicao(item), // <-- ADICIONAMOS O CLIQUE AQUI
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),

            // Resto do Card (Textos e Valor)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Categoria
                  Text(
                    categoriaNome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 2. Linha Inferior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Textos secundários
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataFormatada,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$contaNome | $tipoTransacaoNome",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Valor
                      Text(
                        "${isSaida ? '- ' : '+ '}R\$ ${_formatarMoeda(valor)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSaida ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
