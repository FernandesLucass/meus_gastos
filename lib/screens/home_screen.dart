import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variáveis para controlar os estados da tela
  bool _isDespesa = true;
  String _contaSelecionada = 'Nubank';
  final List<String> _contas = [
    'Nubank',
    'Caixa',
    'Carteira',
    'Flash',
    'Méliuz',
    'Mercado Pago',
    'Next',
    'Viacredi',
  ];
  String _transacaoSelecionada = 'Cartão de Crédito';
  final List<String> _transacoes = [
    'Cartão de Crédito',
    'Cartão de Débito',
    'Pix',
    'Transferência',
    'Dinheiro',
  ];
  String? _categoriaSelecionada = 'Supermercado & Alimentação';
  String? _subCategoriaSelecionada = 'Padaria';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // 1. CABEÇALHO (Manteve igual)
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

          // 2. CARD DO VALOR (Manteve igual)
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
                      '\$ ',
                      style: AppTypography.amount.copyWith(
                        fontSize: 28,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text('0.00', style: AppTypography.amount),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. SELETOR DE DESPESA / RECEITA COM ANIMAÇÃO
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDespesa = true),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDespesa = false),
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
              const SizedBox(height: 1),
              Wrap(
                spacing: 2.0, // Espaçamento horizontal
                runSpacing: 2.0, // Espaçamento vertical
                direction: Axis.horizontal,
                children: _contas.map((conta) {
                  final isSelected = _contaSelecionada == conta;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _contaSelecionada = conta;
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
                        conta,
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
              const SizedBox(height: 1),
              Wrap(
                spacing: 2.0, // Espaçamento horizontal
                runSpacing: 2.0, // Espaçamento vertical
                direction: Axis.horizontal,
                children: _transacoes.map((transacao) {
                  final isSelected = _transacaoSelecionada == transacao;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _transacaoSelecionada = transacao;
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
                        transacao,
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
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                items:
                    [
                      'Supermercado & Alimentação',
                      'Transporte',
                      'Restaurantes',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: AppTypography.input),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _categoriaSelecionada = newValue;
                  });
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
              DropdownButtonFormField<String>(
                initialValue: _subCategoriaSelecionada,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                items: ['Padaria', 'Açougue', 'Feira'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTypography.input),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _subCategoriaSelecionada = newValue;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 8. BOTÃO SALVAR TRANSAÇÃO
          ElevatedButton(
            onPressed: () {
              // A lógica de salvar no banco vem na próxima etapa!
            },
            child: const Text('Salvar Transação'),
          ),

          // 8. BOTÃO SINCRONIZAR COM GOOGLE SHEETS
          TextButton.icon(
            onPressed: () {
              // Projeto para o futuro! rs
            },
            icon: const Icon(Icons.sync, color: AppColors.primary, size: 18),
            label: const Text(
              'Sincronizar com Google Sheets',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600, // SemiBold
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                48,
              ), // Deixa o botão largo e clicável
            ),
          ),

          const SizedBox(height: 10), // Um respiro no final da rolagem da tela
        ],
      ),
    );
  }
}
