// =====================================================================
// ARQUIVO: lib/models/models.dart
// Camada de domínio: entidades, mixins e regras de negócio do módulo
// de Controle Financeiro e Orçamentário Pessoal.
// =====================================================================

import '../exceptions/exceptions.dart';

/// Categorias possíveis para uma despesa.
enum CategoriaDespesa {
  alimentacao,
  transporte,
  lazer,
  saude,
  educacao,
  moradia,
  outros,
}

/// Mixin utilitário para auditoria/log de operações sensíveis.
/// Aplicado via `with` nas classes que precisam registrar um histórico
/// de eventos, sem que essa capacidade venha de uma hierarquia de herança
/// (composição de comportamento transversal, não é "é-um", é "tem-a-capacidade-de").
mixin AuditoriaMixin {
  final List<String> _logs = [];

  void registrarLog(String mensagem) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.add('[$timestamp] $mensagem');
  }

  /// Retorna uma cópia imutável do histórico de logs.
  List<String> get logs => List.unmodifiable(_logs);
}

/// Mixin utilitário puro de formatação monetária — reaproveitado tanto
/// por entidades de domínio (Despesa, MetaEconomia) quanto pelo serviço
/// (GerenciadorFinanceiro), sem relação de herança entre eles.
mixin FormatadorMoedaMixin {
  String formatarMoeda(double valor) {
    final sinal = valor < 0 ? '-' : '';
    return '${sinal}R\$ ${valor.abs().toStringAsFixed(2)}';
  }
}

/// Contrato abstrato de qualquer lançamento financeiro do sistema.
/// Define a operação de negócio obrigatória que toda especialização
/// concreta (Receita, Despesa, ...) deve implementar: como o lançamento
/// impacta o saldo corrente.
abstract class MovimentoFinanceiro {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;

  MovimentoFinanceiro({
    required this.id,
    required this.descricao,
    required this.valor,
    DateTime? data,
  }) : data = data ?? DateTime.now() {
    if (valor <= 0) {
      throw ValorInvalidoException(
        'O valor de um movimento financeiro deve ser positivo.',
        valor,
      );
    }
  }

  /// Contrato de negócio: cada tipo de movimento decide como afeta o saldo.
  /// Receita soma; Despesa subtrai (podendo lançar SaldoInsuficienteException).
  double impactarSaldo(double saldoAtual);

  @override
  String toString() {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return 'Movimento[id: $id, descricao: $descricao, valor: $valor, '
        'data: $dia/$mes/${data.year}]';
  }
}

/// Especialização concreta representando entrada de dinheiro.
class Receita extends MovimentoFinanceiro {
  final String fonte;

  /// Construtor padrão gerativo, reaproveitando os parâmetros da
  /// superclasse via `super.<parametro>` (açúcar sintático do Dart 3).
  Receita({
    required super.id,
    required super.descricao,
    required super.valor,
    super.data,
    required this.fonte,
  });

  /// Construtor nomeado especializado para o caso de uso mais comum.
  Receita.salario({
    required String id,
    required double valor,
    DateTime? data,
  })  : fonte = 'Salário',
        super(id: id, descricao: 'Salário mensal', valor: valor, data: data);

  /// Construtor factory com validação/parse condicional a partir de um Map
  /// (ex.: dado vindo de uma API externa ou de um cache local offline-first).
  factory Receita.fromMap(Map<String, dynamic> map) {
    final valor = map['valor'] as num?;
    if (valor == null || valor <= 0) {
      throw ValorInvalidoException(
        'Mapa de Receita inválido: campo "valor" ausente ou não positivo.',
        map['valor'],
      );
    }
    return Receita(
      id: map['id'] as String? ??
          'REC-${DateTime.now().microsecondsSinceEpoch}',
      descricao: map['descricao'] as String? ?? 'Receita sem descrição',
      valor: valor.toDouble(),
      fonte: map['fonte'] as String? ?? 'Não informada',
    );
  }

  @override
  double impactarSaldo(double saldoAtual) => saldoAtual + valor;

  @override
  String toString() => '${super.toString()} | Tipo: Receita | Fonte: $fonte';
}

/// Especialização concreta representando saída de dinheiro.
/// Compõe comportamento transversal via `with` (mixins) em vez de herança
/// múltipla, mantendo a hierarquia de herança enxuta e coesa.
class Despesa extends MovimentoFinanceiro
    with AuditoriaMixin, FormatadorMoedaMixin {
  final CategoriaDespesa categoria;
  bool _paga;
  String? observacao;

  Despesa({
    required super.id,
    required super.descricao,
    required super.valor,
    super.data,
    required this.categoria,
    bool paga = false,
    this.observacao,
  }) : _paga = paga;

  /// Construtor nomeado para despesas fixas/recorrentes (ex.: aluguel),
  /// já assumindo categoria "moradia" e estado inicial "não paga".
  Despesa.recorrente({
    required String id,
    required String descricao,
    required double valor,
  })  : categoria = CategoriaDespesa.moradia,
        _paga = false,
        super(id: id, descricao: descricao, valor: valor);

  /// Construtor factory com validação rigorosa a partir de um Map dinâmico
  /// — o candidato clássico para dados vindos de JSON/cache local.
  factory Despesa.fromMap(Map<String, dynamic> map) {
    final valorBruto = map['valor'] as num?;
    if (valorBruto == null || valorBruto <= 0) {
      throw ValorInvalidoException(
        'Mapa de Despesa inválido: campo "valor" ausente ou não positivo.',
        map['valor'],
      );
    }

    // Acesso seguro (?.) + coalescente (??) para resolver a categoria a
    // partir de uma string livre, com fallback seguro em "outros" via
    // firstWhere/orElse — nenhuma desreferenciação forçada é usada.
    final categoriaTexto = (map['categoria'] as String?)?.toLowerCase();
    final categoria = CategoriaDespesa.values.firstWhere(
      (c) => c.name == categoriaTexto,
      orElse: () => CategoriaDespesa.outros,
    );

    return Despesa(
      id: map['id'] as String? ??
          'DESP-${DateTime.now().microsecondsSinceEpoch}',
      descricao: map['descricao'] as String? ?? 'Despesa sem descrição',
      valor: valorBruto.toDouble(),
      categoria: categoria,
      paga: map['paga'] as bool? ?? false,
      observacao: map['observacao'] as String?,
    );
  }

  bool get paga => _paga;

  /// Setter customizado com regra de validação: uma despesa já paga não
  /// pode ser revertida para "não paga" (evita inconsistência no histórico).
  set paga(bool valor) {
    if (_paga && !valor) {
      throw ValorInvalidoException(
        'Uma despesa já paga não pode ser revertida para "não paga".',
      );
    }
    _paga = valor;
  }

  @override
  double impactarSaldo(double saldoAtual) {
    if (saldoAtual - valor < 0) {
      registrarLog(
        'Tentativa de débito recusada: saldo insuficiente para "$descricao".',
      );
      throw SaldoInsuficienteException(
        'Saldo insuficiente para registrar a despesa "$descricao".',
        saldoAtual,
        valor,
      );
    }
    registrarLog('Despesa "$descricao" debitada com sucesso.');
    return saldoAtual - valor;
  }

  @override
  String toString() {
    final obs = observacao ?? 'sem observações';
    return '${super.toString()} | Tipo: Despesa | '
        'Categoria: ${categoria.name} | Valor: ${formatarMoeda(valor)} | '
        'Paga: $_paga | Obs: $obs';
  }
}

/// Representa uma meta de economia, com simulação de juros compostos
/// sobre o valor já acumulado.
class MetaEconomia with FormatadorMoedaMixin {
  final String nome;
  final double valorAlvo;
  final DateTime prazo;
  double _valorAtual;

  MetaEconomia({
    required this.nome,
    required this.valorAlvo,
    required this.prazo,
    double valorInicial = 0,
  }) : _valorAtual = valorInicial {
    if (valorAlvo <= 0) {
      throw MetaInvalidaException(
        'O valor-alvo de "$nome" deve ser positivo.',
      );
    }
    if (prazo.isBefore(DateTime.now())) {
      throw MetaInvalidaException(
        'O prazo de "$nome" não pode estar no passado.',
      );
    }
  }

  double get valorAtual => _valorAtual;

  double get percentualConcluido =>
      ((_valorAtual / valorAlvo) * 100).clamp(0.0, 100.0).toDouble();

  void depositar(double valor) {
    if (valor <= 0) {
      throw ValorInvalidoException(
        'Depósito em meta deve ser positivo.',
        valor,
      );
    }
    _valorAtual += valor;
  }

  /// Simula o crescimento do valor atual da meta aplicando juros compostos
  /// mensais. É uma projeção pura — não altera o estado real da meta.
  double simularJurosCompostos({
    required double taxaMensal,
    required int meses,
  }) {
    if (taxaMensal < 0 || meses < 0) {
      throw ValorInvalidoException(
        'Taxa e número de meses devem ser não negativos para a simulação.',
      );
    }
    var montanteProjetado = _valorAtual;
    for (var mes = 0; mes < meses; mes++) {
      montanteProjetado *= (1 + taxaMensal);
    }
    return montanteProjetado;
  }

  @override
  String toString() => 'Meta[$nome] Alvo: ${formatarMoeda(valorAlvo)} | '
      'Atual: ${formatarMoeda(_valorAtual)} | '
      'Progresso: ${percentualConcluido.toStringAsFixed(1)}%';
}
