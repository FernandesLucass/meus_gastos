import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart'
    as path; // Apelido adicionado para evitar conflito de Context
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({
    super.key,
  }); // Atualizado para o formato moderno super.key

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _temaEscuro = true;
  bool _notificacoes = false;

  Future<void> _exportarBancoDados() async {
    try {
      final dbPath = path.join(await getDatabasesPath(), 'meus_gastos.db');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        // 1. Cria uma cópia na pasta temporária do sistema (livre de bloqueios)
        final tempPath = path.join(
          Directory.systemTemp.path,
          'meus_gastos_backup.db',
        );
        final tempFile = await dbFile.copy(tempPath);

        // 2. Compartilha a cópia usando o tempFile.path e o mimeType genérico
        // ignore: deprecated_member_use
        await Share.shareXFiles([
          XFile(tempFile.path, mimeType: '*/*'),
        ], text: 'Backup do banco de dados - Meus Gastos');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo de banco de dados não encontrado.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            const Text(
              'Configurações',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gerencie preferências e dados',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('PREFERÊNCIAS'),
            _buildSettingsItem(
              title: 'Gerenciar Categorias',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            _buildSettingsItem(
              title: 'Tema Claro/Escuro',
              trailing: Switch(
                value: _temaEscuro,
                onChanged: (val) => setState(() => _temaEscuro = val),
                activeThumbColor: Colors
                    .white, // Atualizado de activeColor para activeThumbColor
                activeTrackColor: const Color(0xFF00C853),
              ),
              onTap: () => setState(() => _temaEscuro = !_temaEscuro),
            ),
            _buildSettingsItem(
              title: 'Notificações',
              trailing: Switch(
                value: _notificacoes,
                onChanged: (val) => setState(() => _notificacoes = val),
                activeThumbColor: Colors
                    .white, // Atualizado de activeColor para activeThumbColor
                activeTrackColor: const Color(0xFF00C853),
              ),
              onTap: () => setState(() => _notificacoes = !_notificacoes),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('BACKUP E DADOS'),
            _buildSettingsItem(
              title: 'Exportar Dados',
              trailing: const Icon(Icons.download_outlined, color: Colors.grey),
              onTap: _exportarBancoDados,
            ),
            _buildSettingsItem(
              title: 'Conexão com Google Sheets',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Atualizado de withOpacity para withValues para evitar perda de precisão
                  color: const Color(0xFF00C853).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('SOBRE'),
            _buildSettingsItem(
              title: 'Termos de Serviço e Privacidade',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            _buildSettingsItem(
              title: 'Resetar Banco de Dados Local',
              titleColor: Colors.redAccent,
              trailing: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    Color titleColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
