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

Cada caso imprime `OK <nome>` ou `FALHOU <nome>: <valor obtido>`.

## Estado atual

- [x] Estrutura do projeto
- [x] Decisões iniciais de modelagem (`docs/decisoes.md`)
- [x] Camada 1 - tipos (`Time`, `Resultado`, `Partida`, `Linha`)
- [x] Camada 1 - consultas básicas (`participou`, `resultadoPara`, `times`)
- [ ] Campeonato de teste (`Dados.hs`)
- [ ] Camada 2 - classificação e estatísticas
- [ ] Camada 3 - leitura, validação e tabela formatada
- [ ] Testes das três camadas
