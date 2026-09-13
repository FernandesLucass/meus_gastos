import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../repositories/lancamento_repository.dart';

class SincronizacaoService {
  // COLE A SUA URL /exec AQUI
  static const String _scriptUrl =
      'https://script.google.com/macros/s/AKfycbyaJn6ypA43BTzQaP6oGzwWlC0-1Rvjc1LP8QP3in7ZmfeW8fYcz-JZKNlcebpxxNsa/exec';

  final LancamentoRepository _repo = LancamentoRepository();

  Future<bool> sincronizar() async {
    try {
      // 1. Busca os não sincronizados no SQLite
      final naoSincronizados = await _repo.getLancamentosParaSincronizar();

      if (naoSincronizados.isEmpty) {
        debugPrint('Tudo já está sincronizado!');
        return true;
      }

      // 2. Envia para o Google Sheets via POST
      final response = await http.post(
        Uri.parse(_scriptUrl),
        // Importante: garantir que o JSON vá no formato certo
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(naoSincronizados),
      );

      // O Google Apps Script as vezes retorna 302 (redirect), mas o HTTP resolve.
      // Retornos 200 ou 201 significam sucesso.
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 302) {
        // 3. Deu certo! Extrai os IDs e marca como sincronizado no SQLite
        final idsSincronizados = naoSincronizados
            .map<int>((l) => l['id'] as int)
            .toList();
        await _repo.marcarComoSincronizados(idsSincronizados);

        debugPrint(
          'Sincronizados com sucesso: ${idsSincronizados.length} itens.',
        );
        return true;
      } else {
        debugPrint('Erro na nuvem. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro de conexão ou código: $e');
      return false;
    }
  }
}
