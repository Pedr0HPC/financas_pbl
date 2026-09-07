// =====================================================================
// ARQUIVO: bin/main.dart
// Executável de demonstração (CLI) do núcleo de domínio do módulo de
// Controle Financeiro e Orçamentário Pessoal.
// =====================================================================

import 'package:financas_pbl/models/models.dart';
import 'package:financas_pbl/services/services.dart';
import 'package:financas_pbl/exceptions/exceptions.dart';

void main() {
  print('Iniciando simulação do módulo financeiro...\n');

  final gerenciador = GerenciadorFinanceiro(saldoInicial: 0);

  // 1) Inserção de receitas (construtor nomeado + construtor factory)
  gerenciador.registrarMovimento(
    Receita.salario(id: 'R001', valor: 3500),
  );

  gerenciador.registrarMovimento(
    Receita.fromMap({
      'id': 'R002',
      'descricao': 'Freelance de desenvolvimento',
      'valor': 800,
      'fonte': 'Cliente externo',
    }),
  );

  // 2) Inserção de despesas (construtor padrão, nomeado e factory)
  gerenciador.registrarMovimento(
    Despesa(
      id: 'D001',
      descricao: 'Supermercado',
      valor: 450.75,
      categoria: CategoriaDespesa.alimentacao,
    ),
  );

  gerenciador.registrarMovimento(
    Despesa.recorrente(id: 'D002', descricao: 'Aluguel', valor: 1200),
  );

  final assinatura = Despesa.fromMap({
    'id': 'D003',
    'descricao': 'Assinatura de streaming',
    'valor': 39.90,
    'categoria': 'lazer',
    'paga': true,
  });
  // Demonstração de atribuição nula (??=): só define a observação
  // se ela ainda não tiver sido preenchida.
  assinatura.observacao ??= 'Cobrança recorrente mensal no cartão.';
  gerenciador.registrarMovimento(assinatura);

  // 3) Simulação de dado inválido, tratada localmente com try-catch.
  try {
    gerenciador.registrarMovimento(
      Despesa.fromMap({
        'id': 'D_ERRO',
        'descricao': 'Item corrompido',
        'valor': -10,
      }),
    );
  } on ValorInvalidoException catch (e) {
    print('[Aviso tratado] $e\n');
  }

  // 4) Simulação proposital de restrição real de negócio: saldo
  //    insuficiente. Demonstra o disparo e o tratamento da exceção
  //    customizada SaldoInsuficienteException.
  try {
    gerenciador.registrarMovimento(
      Despesa(
        id: 'D004',
        descricao: 'Viagem internacional',
        valor: 999999,
        categoria: CategoriaDespesa.lazer,
      ),
    );
  } on SaldoInsuficienteException catch (e) {
    print('[Exceção de negócio capturada] $e\n');
  } finally {
    print('Fluxo de tentativa de débito de alto valor finalizado.\n');
  }

  // 5) Metas de economia + simulação de juros compostos
  final metaViagem = MetaEconomia(
    nome: 'Viagem de fim de ano',
    valorAlvo: 5000,
    prazo: DateTime.now().add(const Duration(days: 300)),
    valorInicial: 500,
  );
  metaViagem.depositar(300);
  gerenciador.adicionarMeta(metaViagem);

  final projecao = metaViagem.simularJurosCompostos(
    taxaMensal: 0.008,
    meses: 12,
  );
  print(
    'Projeção da meta "${metaViagem.nome}" em 12 meses a 0.8% a.m.: '
    'R\$ ${projecao.toStringAsFixed(2)}\n',
  );

  // 6) Filtragem funcional de dados de domínio
  final despesasLazer =
      gerenciador.obterDespesasPorCategoria(CategoriaDespesa.lazer);
  print('Despesas de lazer encontradas: ${despesasLazer.length}');
  for (final despesa in despesasLazer) {
    print('  - $despesa');
  }
  print('');

  print(
      'Todas as despesas estão quitadas? ${gerenciador.todasDespesasQuitadas}');
  print(
    'Existe despesa de moradia? '
    '${gerenciador.existeDespesaNaCategoria(CategoriaDespesa.moradia)}\n',
  );

  // 7) Relatório final consolidado
  print(gerenciador.gerarRelatorioCompleto());
}
