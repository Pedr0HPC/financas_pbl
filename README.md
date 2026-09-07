# Financas PBL — Controle Financeiro e Orçamentário Pessoal

Avaliação Processual — Marco 1 do Projeto Prático Integrado (PBL)
da disciplina **Computação Móvel**, Curso de Sistemas de Informação,
Faculdade Multivix. Professor: Edgard da Cunha Pontes.

Núcleo de domínio e lógica de negócio, em **Dart puro**, para uma solução
móvel de controle financeiro pessoal: categorização de despesas, metas de
economia e simulação de juros compostos. 

## Integrantes

- Caio Rohr Vargas Ribeiro
- João Eduardo Herculano Galito
- João Lucas Rodrigues Almeida
- Pedro Henrique de Paula Caetano

## Tema

**Tema 06 — Controle Financeiro e Orçamentário Pessoal:** categorização de
despesas, metas de economia e simulação de juros compostos.

## Estrutura do projeto

```
financas_pbl/
├── bin/
│   └── main.dart              # Executável CLI de demonstração
├── lib/
│   ├── exceptions/
│   │   └── exceptions.dart    # Exceções customizadas de domínio
│   ├── models/
│   │   └── models.dart        # Entidades, mixins e classe abstrata
│   └── services/
│       └── services.dart      # Orquestração e regras de negócio
├── ENVIRONMENT_REPORT.md
├── pubspec.yaml
└── README.md
```

## Como executar

Pré-requisitos: Dart SDK 3.3 ou superior instalado (`dart --version`).

```bash
# instalar dependências (não há dependências externas, mas gera o pubspec.lock)
dart pub get

# rodar o executável de demonstração
dart run bin/main.dart

# (opcional) formatar o código antes de commitar
dart format .

# (opcional) rodar o analisador estático
dart analyze
```

## Arquitetura e decisões técnicas (resumo)

- `MovimentoFinanceiro` — classe abstrata que define o contrato
  `impactarSaldo(double saldoAtual)`, implementado de forma polimórfica por
  `Receita` (soma) e `Despesa` (subtrai, podendo lançar
  `SaldoInsuficienteException`).
- `AuditoriaMixin` e `FormatadorMoedaMixin` — comportamentos transversais
  aplicados via `with`, evitando herança múltipla artificial.
- Construtores gerativo, nomeado (`Receita.salario`, `Despesa.recorrente`)
  e `factory` (`Receita.fromMap`, `Despesa.fromMap`) com validação de dados
  de entrada.
- Encapsulamento com atributos privados (`_paga`, `_valorAtual`) expostos
  por getters/setters que validam estado.
- Sound null safety sem uso de `!`: tipos anuláveis (`String?`), `?.`, `??`
  e `??=` usados de forma consistente.
- Coleções manipuladas de forma funcional (`.map()`, `.where()`, `.fold()`,
  `.every()`, `.any()`), com Spread Operators e Collection-If/For na
  montagem do relatório.

## Declaração de Uso de Inteligência Artificial

Em conformidade com a Política Institucional de Uso de IA do Plano de
Ensino 2026/2 da disciplina Computação Móvel:

O grupo utilizou o assistente de IA **Gemini** durante o
desenvolvimento deste projeto, com as seguintes contribuições:

- **Estruturação inicial do projeto**: sugestão da organização de pastas
  (`lib/models`, `lib/services`, `lib/exceptions`, `bin`) e do
  `pubspec.yaml`.
- **Geração de um esqueleto de código** para as classes de domínio,
  mixins, exceções customizadas e serviço, cobrindo os requisitos técnicos
  do enunciado (herança, mixins, construtores factory, null safety,
  coleções funcionais, tratamento de exceções). Que foi sendo aperfeiçoada
  conforme andando e testes do processo.
- **Revisão de sintaxe e boas práticas de Dart 3** (sound null safety,
  convenções de nomenclatura, uso de `super` parameters).
- **Apoio na elaboração deste README (Ex: Formatação) e do template de ambiente.**

Basicamente usada como apoio em duvidas e erros gerais que ocorriam durante o 
desenvolvimento geral do projeto.

## Referências bibliográficas

- Documentação oficial do Dart: <https://dart.dev/language>
- Documentação oficial do Flutter: <https://docs.flutter.dev>
- Plano de Ensino 2026/2 — Computação Móvel, Faculdade Multivix.
