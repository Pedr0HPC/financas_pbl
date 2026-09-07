// =====================================================================
// ARQUIVO: lib/exceptions/exceptions.dart
// Exceções customizadas de domínio para o núcleo financeiro.
// Cada uma representa a violação de UMA regra de negócio específica,
// permitindo tratamento diferenciado no fluxo de execução (try-catch).
// =====================================================================

/// Lançada quando uma operação de débito deixaria o saldo negativo.
/// Representa a restrição de negócio central do módulo: nunca permitir
/// saldo irreal (negativo) sem controle explícito (ex.: crédito/limite).
class SaldoInsuficienteException implements Exception {
  final String mensagem;
  final double saldoAtual;
  final double valorSolicitado;

  SaldoInsuficienteException(
    this.mensagem,
    this.saldoAtual,
    this.valorSolicitado,
  );

  @override
  String toString() => 'SaldoInsuficienteException: $mensagem '
      '(Saldo: R\$ ${saldoAtual.toStringAsFixed(2)}, '
      'Solicitado: R\$ ${valorSolicitado.toStringAsFixed(2)})';
}

/// Lançada quando um valor monetário informado é inválido
/// (nulo, ausente, zero ou negativo), tanto em construtores diretos
/// quanto em construtores factory que fazem parsing de Map.
class ValorInvalidoException implements Exception {
  final String mensagem;
  final Object? valorRecebido;

  ValorInvalidoException(this.mensagem, [this.valorRecebido]);

  @override
  String toString() => 'ValorInvalidoException: $mensagem'
      '${valorRecebido != null ? ' (valor recebido: $valorRecebido)' : ''}';
}

/// Lançada quando uma Meta de Economia é criada ou operada com dados
/// incoerentes (ex.: valor-alvo <= 0, prazo no passado, depósito inválido).
class MetaInvalidaException implements Exception {
  final String mensagem;

  MetaInvalidaException(this.mensagem);

  @override
  String toString() => 'MetaInvalidaException: $mensagem';
}
