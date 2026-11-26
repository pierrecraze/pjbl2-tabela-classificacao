# PjBL2 - Tabela de Classificação de Campeonato (Haskell)

Trabalho PjBL2 da disciplina **Programação Lógica e Funcional** (BCC - PUCPR, 2026/2).

O programa calcula a tabela de classificação de um campeonato de futebol a partir
dos resultados das partidas, em três camadas:

| Camada | Módulo                  | Responsabilidade                                      |
| ------ | ----------------------- | ----------------------------------------------------- |
| 1      | `src/Tipos.hs`          | Tipos algébricos do domínio e consultas básicas       |
| 2      | `src/Classificacao.hs`  | Classificação e estatísticas com ordem superior       |
| 3      | `src/Leitura.hs`        | Leitura do texto, validação (Maybe/Either) e saída    |
| -      | `src/Dados.hs`          | Campeonato de teste, como `String`                    |
| -      | `src/Main.hs`           | Demonstração das três camadas (única função com IO)   |
| -      | `tests/Testes.hs`       | Casos de teste com resultado esperado                 |

As decisões de modelagem e as limitações conhecidas estão em
[`docs/decisoes.md`](docs/decisoes.md).

## Equipe

- Matheus Antunes Marçal de Souza
- Patrick Davidson Narciso de Carvalho
- Pedro Henrique Magno Lopes
- Pierre Craze

## Ambiente utilizado

**GHC local, instalado via [GHCup](https://www.haskell.org/ghcup/)** (testado com GHC 9.4).
O projeto usa apenas a biblioteca padrão (`base`), então não precisa de Cabal nem Stack.

Instalação do GHCup:

- macOS / Linux: `curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh`
- Windows (PowerShell): seguir as instruções em <https://www.haskell.org/ghcup/>

## Como compilar e executar

Na raiz do repositório:

```bash
# compilar (o -isrc diz ao GHC onde estão os módulos)
ghc -Wall -isrc -outputdir build -o tabela src/Main.hs

# executar
./tabela            # macOS / Linux
tabela.exe          # Windows
```

Sem compilar, também dá para rodar direto:

```bash
runghc -isrc src/Main.hs
```

## Como rodar os testes

```bash
runghc -isrc tests/Testes.hs
```

Cada caso imprime `OK <nome>` ou `FALHOU <nome>: <valor obtido>`; se algum falhar,
o programa de testes termina com código de saída 1.

## O que o programa mostra

O `main` lê o campeonato de teste (`Dados.hs`) pela Camada 3 e imprime, em sequência,
a classificação final, a classificação após a rodada 3, as estatísticas da Camada 2 e o
tratamento de uma entrada com erros. Trecho da saída:

```
=== Classificação final ===
Pos  Time        P   J   V   E   D  SG
  1  Athletico  10   5   3   1   1  +5
  2  Coritiba   10   5   3   1   1  +4
  3  Londrina   10   5   3   1   1  +3
  4  Paraná      5   5   1   2   2  -1
  5  Operário    4   5   1   1   3  -1
  6  Cascavel    3   5   1   0   4 -10
...
=== Entrada com erros (dadosComErros) ===
lerCampeonato para no primeiro erro:
  linha 4: "dois" não é um número inteiro
todosOsErros lista todos:
  - linha 4: "dois" não é um número inteiro
  - linha 5: placar com gols negativos
  - linha 6: Athletico jogaria contra si mesmo
  - linha 7: esperava 5 campos separados por ';', mas vieram 4
  - rodada 1: Coritiba está escalado em mais de uma partida
```

## Estado atual

- [x] Estrutura do projeto
- [x] Decisões iniciais de modelagem (`docs/decisoes.md`)
- [x] Camada 1 - tipos (`Time`, `Resultado`, `Partida`, `Linha`)
- [x] Camada 1 - consultas básicas (`participou`, `resultadoPara`, `times`)
- [x] Campeonato de teste (`Dados.hs`)
- [x] Camada 2 - classificação e estatísticas
- [x] Camada 3 - leitura de uma linha (`Erro`, `separar`, `lerPartida`)
- [x] Camada 3 - campeonato inteiro e relatório de erros (`lerCampeonato`, `todosOsErros`)
- [x] Camada 3 - tabela formatada e `main` final
- [x] Testes das três camadas (55 casos)
