# Cumbuca

[![lint](https://github.com/zoedsoupe/cumbuca_teste/actions/workflows/lint.yml/badge.svg)](https://github.com/zoedsoupe/cumbuca_teste/actions/workflows/lint.yml)
[![test](https://github.com/zoedsoupe/cumbuca_teste/actions/workflows/test.yml/badge.svg)](https://github.com/zoedsoupe/cumbuca_teste/actions/workflows/test.yml)

Boas vindas ao meu Case técnico para a Cumbuca ☺️!

## Tipos

<table>
    <tr>
        <td>Entidade</td>
        <td>Campos</td>
    </tr>
    <tr>
        <td>UserAccount</td>
        <td>
            ```elixir
            %{
                balance: string,
                owner_cpf: string,
                owner_first_name: string,
                owner_last_name: string | nil,
                identifier: string
            }
            ```
        </td>
    </tr>
    <tr>
        <td>Transaction</td>
        <td>
            ```elixir
            %{
                amount: string,
                processed_at: naive_date_time | nil,
                chargebacked_at: naive_date_time | nil,
                sender: UserAccount,
                receiver: UserAccount,
            }
            ```
        </td>
    </tr>
</table>

## Queries e Mutations

<table>
    <tr>
        <td>Ação</td>
        <td>Tipo</td>
        <td>Argumentos</td>
        <td>Retorno</td>
        <td>Autenticada?</td>
    </tr>
    <tr>
        <td>CheckBalance</td>
        <td>Query</td>
        <td>nenhum</td>
        <td>String</td>
        <td>Sim</td>
    </tr>
    <tr>
        <td>Transactions</td>
        <td>Query</td>
        <td>`%{from_period: ISO8601, to_period: ISO8601}`</td>
        <td>[Transaction]</td>
        <td>Sim</td>
    </tr>
    <tr>
        <td>Transact</td>
        <td>Mutation</td>
        <td>`%{amount: integer, receiver: string}`</td>
        <td>`%{identifier: string}`</td>
        <td>Sim</td>
    </tr>
    <tr>
        <td>ChargebackTransaction</td>
        <td>Mutation</td>
        <td>`%{identifier: string}`</td>
        <td>`%{identifier: string}`</td>
        <td>Sim</td>
    </tr>
    <tr>
        <td>RegisterAccount</td>
        <td>Mutation</td>
        <td>`%{cpf: string, first_name: string, last_name: string | nil, balance: integer | nil}`</td>
        <td>UserAccount</td>
        <td>Não</td>
    </tr>
    <tr>
        <td>Login</td>
        <td>Mutation</td>
        <td>`%{cpf: string, account_identifier: string}`</td>
        <td>`%{token: string}`</td>
        <td>Não</td>
    </tr>
    <tr>
        <td>TransactionProcessed</td>
        <td>Subscription</td>
        <td>nenhum</td>
        <td>Transaction</td>
        <td>Sim</td>
    </tr>
    <tr>
        <td>TransactionChargebacked</td>
        <td>Subscription</td>
        <td>nenhum</td>
        <td>Transaction</td>
        <td>Sim</td>
    </tr>
</table>

## Testando a API

A API se encontra deployada em https://cumbuca-teste.fly.dev!

## Rodando Localmente

Lembre-se de antes configurar o PostgreSQL e modificar `config/dev.exs` caso seja necessário.

```console
$ mix do setup, phx.server
```

O servidor estará rodando na porta 4000!

Para rodar os testes:

```console
$ mix test
```

Você pode querer rodar apenas testes unitários ou de integração, portanto, basta passar a flag `--only` para o comando, com os valores `unit` ou `integration`.

ps: Existe um arquivo com todas as queries e mutations, com profiles customizados para Insomnia na raiz do projeto.
