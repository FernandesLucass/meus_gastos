// 1. Flutter & Pacotes
import 'package:flutter/material.dart';

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
  // 1. Controladores
  final LancamentoRepository _lancamentoRepo = LancamentoRepository();
  List<Map<String, dynamic>> _lancamentos = [];
  bool _isLoading = true;

  // Métodos:
  @override
  void initState() {
    super.initState();
    _carregarLancamentos();
  }

  Future<void> _carregarLancamentos() async {
    final dados = await _lancamentoRepo.getLancamentosSemana();
    setState(() {
      _lancamentos = dados;
      _isLoading = false;
    });
  }

  // 2. Build
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCabecalho(),
          _buildListaTransacoes(),
          _buildBotaoHistoricoCompleto(),
        ],
      ),
    );
  }

  // 3. Widgets

  // 1. CABEÇALHO
  Widget _buildCabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _lancamentos.length,
              itemBuilder: (context, index) {
                final item = _lancamentos[index];
                return _buildCardTransacao(item);
              },
            ),
    );
  }

  // 3. CARD DE TRANSAÇÃO
  Widget _buildCardTransacao(Map<String, dynamic> item) {
    // 1. Extração de dados
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

    // 4. Desenho do Card
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
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

          // Textos Centrais
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoriaNome,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dataFormatada,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$contaNome | $tipoTransacaoNome",
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Valor
          Text(
            "${isSaida ? '- ' : '+ '}R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}",
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isSaida ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // 4. BOTÃO "VER HISTÓRICO COMPLETO"
  Widget _buildBotaoHistoricoCompleto() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Futuramente: Navigator.push para a tela do Mês Inteiro
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ver Histórico Completo',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
