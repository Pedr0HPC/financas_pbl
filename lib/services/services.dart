// =====================================================================
// ARQUIVO: lib/services/services.dart
// Camada de serviço: orquestra os movimentos financeiros e metas,
// delegando às próprias entidades a lógica de negócio (polimorfismo).
// =====================================================================

import '../models/models.dart';
import '../exceptions/exceptions.dart';

/// Serviço central do módulo, responsável por manter o estado financeiro
/// (saldo, movimentos, metas) e expor operações de alto nível ao CLI.
class GerenciadorFinanceiro with AuditoriaMixin, FormatadorMoedaMixin {
  final List<MovimentoFinanceiro> _movimentos = [];
  final List<MetaEconomia> _metas = [];
  double _saldoAtual;

  GerenciadorFinanceiro({double saldoInicial = 0}) : _saldoAtual = saldoInicial;

  double get saldoAtual => _saldoAtual;

  List<MovimentoFinanceiro> get movimentos => List.unmodifiable(_movimentos);

  List<MetaEconomia> get metas => List.unmodifiable(_metas);

  /// Registra um movimento (Receita ou Despesa), delegando à própria
  /// entidade o cálculo do novo saldo. Propaga SaldoInsuficienteException
  /// para quem chamou, após auditar a tentativa.
  void registrarMovimento(MovimentoFinanceiro movimento) {
    try {
      final novoSaldo = movimento.impactarSaldo(_saldoAtual);
      _saldoAtual = novoSaldo;
      _movimentos.add(movimento);
      registrarLog(
        'Movimento registrado: ${movimento.descricao} '
        '(${formatarMoeda(movimento.valor)}). '
        'Novo saldo: ${formatarMoeda(_saldoAtual)}',
      );
    } on SaldoInsuficienteException catch (e) {
      registrarLog('Falha ao registrar movimento: $e');
      rethrow;
    } finally {
      registrarLog(
        'Tentativa de registro finalizada para "${movimento.descricao}".',
      );
    }
  }

  void adicionarMeta(MetaEconomia meta) {
    _metas.add(meta);
    registrarLog('Meta cadastrada: ${meta.nome}');
  }

  /// Filtra despesas por categoria usando `whereType` + `.where()`.
  List<Despesa> obterDespesasPorCategoria(CategoriaDespesa categoria) {
    return _movimentos
        .whereType<Despesa>()
        .where((despesa) => despesa.categoria == categoria)
        .toList();
  }

  /// Agrega o total gasto por categoria usando `.fold()` com Spread Operator
  /// para reconstruir o Map de forma imutável a cada iteração.
  Map<CategoriaDespesa, double> calcularGastosPorCategoria() {
    final despesas = _movimentos.whereType<Despesa>().toList();
    return despesas.fold<Map<CategoriaDespesa, double>>(
      {},
      (mapa, despesa) => {
        ...mapa,
        despesa.categoria: (mapa[despesa.categoria] ?? 0) + despesa.valor,
      },
    );
  }

  /// Soma receitas usando `.whereType()` + `.fold()`.
  double calcularTotalReceitas() => _movimentos
      .whereType<Receita>()
      .fold<double>(0, (soma, receita) => soma + receita.valor);

  /// Soma despesas pendentes usando `.where()`, `.map()` e `.fold()`.
  double calcularTotalDespesasPendentes() => _movimentos
      .whereType<Despesa>()
      .where((d) => !d.paga)
      .map((d) => d.valor)
      .fold<double>(0, (soma, valor) => soma + valor);

  /// Indica, via `.every()`, se todas as despesas registradas já foram pagas.
  bool get todasDespesasQuitadas =>
      _movimentos.whereType<Despesa>().every((d) => d.paga);

  /// Indica, via `.any()`, se existe ao menos uma despesa de uma categoria.
  bool existeDespesaNaCategoria(CategoriaDespesa categoria) =>
      _movimentos.whereType<Despesa>().any((d) => d.categoria == categoria);

  /// Gera um relatório textual formatado, combinando Spread Operators,
  /// Collection-If e Collection-For na montagem das linhas.
  String gerarRelatorioCompleto() {
    final despesas = _movimentos.whereType<Despesa>().toList();
    final receitas = _movimentos.whereType<Receita>().toList();
    final gastosPorCategoria = calcularGastosPorCategoria();
    final separador = ''.padRight(60, '=');

    final linhas = <String>[
      separador,
      'RELATÓRIO FINANCEIRO PESSOAL',
      separador,
      'Saldo atual: ${formatarMoeda(_saldoAtual)}',
      'Total de receitas: ${formatarMoeda(calcularTotalReceitas())}',
      'Total de despesas pendentes: '
          '${formatarMoeda(calcularTotalDespesasPendentes())}',
      '',
      '--- Receitas (${receitas.length}) ---',
      if (receitas.isEmpty)
        '  Nenhuma receita registrada.'
      else ...[
        for (final receita in receitas) '  • $receita',
      ],
      '',
      '--- Despesas (${despesas.length}) ---',
      if (despesas.isEmpty)
        '  Nenhuma despesa registrada.'
      else ...[
        for (final despesa in despesas) '  • $despesa',
      ],
      '',
      '--- Gastos por categoria ---',
      if (gastosPorCategoria.isEmpty)
        '  Sem dados de categoria.'
      else ...[
        for (final entrada in gastosPorCategoria.entries)
          '  ${entrada.key.name}: ${formatarMoeda(entrada.value)}',
      ],
      '',
      '--- Metas de economia (${_metas.length}) ---',
      if (_metas.isEmpty)
        '  Nenhuma meta cadastrada.'
      else ...[
        for (final meta in _metas) '  • $meta',
      ],
      separador,
    ];

    return linhas.join('\n');
  }
}
