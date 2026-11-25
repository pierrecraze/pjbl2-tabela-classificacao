# Decisões de modelagem e limitações conhecidas

Este documento registra **por que** o código está escrito do jeito que está.
Ele é atualizado junto com o código: cada decisão marcada como *planejada* vira
*tomada* (ou é revista) quando a camada correspondente for implementada.

Legenda: ✅ tomada e implementada · 🕓 planejada (ainda não implementada)

---

## 0. Decisões gerais

### ✅ Ambiente: GHC local via GHCup, com um módulo por camada

O enunciado permite GHC local ou playground. Escolhemos o **GHC local** porque:

- a Seção 6 pede um módulo por camada (`Tipos`, `Classificacao`, `Leitura`, `Dados`, `Main`),
  e o playground só trabalha com um arquivo (Aula 12, "Criando seus próprios módulos");
- os testes ficam num executável separado (`tests/Testes.hs`) que importa os mesmos módulos,
  sem duplicar código;
- compilar com `-Wall` localmente é o jeito mais simples de garantir "nenhum aviso".

Compilação: `ghc -Wall -isrc -outputdir build -o tabela src/Main.hs`
(ver README). Usamos só a `base`, sem Cabal/Stack, para que qualquer integrante
rode com o GHC que já tem instalado.

### ✅ Saída forçada em UTF-8 (`hSetEncoding stdout utf8`)

Os times do campeonato de teste têm acento ("Paraná", "Operário"). No primeiro teste,
rodando num terminal sem locale UTF-8, o programa caiu com
`commitBuffer: invalid argument (cannot encode character '\231')` só por imprimir
"Classificação". O terminal padrão do Windows tem o mesmo problema. Como uma entrada
válida **nunca pode derrubar o programa**, o `main` fixa a codificação da saída.

Isso usa `System.IO`, que também faz parte da `base`; o uso fica restrito ao `main`,
que já é a única função com IO.

### ✅ Esporte: futebol, com os critérios do Brasileirão Série A

Mantivemos o futebol (as funções obrigatórias do enunciado ficam exatamente como pedidas).
A ordenação segue o regulamento da CBF para a Série A 2026:

1. pontos (3 por vitória, 1 por empate, 0 por derrota);
2. número de vitórias;
3. saldo de gols;
4. gols pró;
5. confronto direto, cartões vermelhos, cartões amarelos e sorteio (**não modelados**, ver Limitações).

No lugar dos critérios 5+ usamos a **ordem alfabética do nome do time**, só para que a tabela
seja sempre determinística (a mesma entrada gera sempre a mesma ordem).

---

## 1. Camada 1 - Tipos e dados (`Tipos.hs`)

### ✅ `type Time = String` (e não `newtype`)

O enunciado fixa `type Time = String`. Na Aula 13 vimos que um `newtype Time = Time String`
impediria misturar um nome de time com qualquer outra `String`; aqui isso traria pouco
ganho, porque o único lugar em que um time "nasce" é a leitura da Camada 3, e
custaria embrulhar/desembrulhar o nome em todo lugar. Fica o apelido, pela legibilidade
das assinaturas.

### ✅ `Resultado` como tipo soma

`data Resultado = Vitoria | Empate | Derrota`, em vez de `String` ("V"/"E"/"D") ou `Int`:
o conjunto de valores fica fechado, e com `-Wall` o compilador aponta qualquer função que
esqueça um dos três casos (armadilha da Camada 1).

Derivamos `Show, Eq` (exigidos pelos testes) e `Enum, Bounded`, para poder percorrer todos
os resultados com `[minBound .. maxBound]` (como na Aula 13 com `Categoria`), por exemplo
para testar `pontos` em todos os casos.
**Não** derivamos `Ord`: a ordem de declaração não significa "melhor" ou "pior";
quem dá valor a um resultado é a função `pontos`.

### ✅ `Partida` como record, com os campos na ordem do enunciado

`rodada, mandante, golsMandante, golsVisitante, visitante`. A ordem dos campos é a de
um placar lido em voz alta, então o construtor posicional fica natural:
`Partida 1 "Coritiba" 2 1 "Athletico"` = "rodada 1, Coritiba 2 x 1 Athletico".

Usar record e não tupla `(Int, String, Int, Int, String)` dá nome aos dois `Int` de gols,
que numa tupla seriam fáceis de trocar sem o compilador perceber.

### ✅ `Linha` guarda só contagens; pontos e saldo são **derivados**

`Linha` tem `time, jogos, vitorias, empates, derrotas, golsPro, golsContra`, como pede o
enunciado. Pontos e saldo **não** são campos: são calculados por `pontosLinha` e `saldo`
(Camada 2). Se fossem campos, seria possível construir uma linha com 2 vitórias e
"10 pontos"; derivando, esse estado inválido simplesmente não existe.

O campo de nome do time se chama `time` (e não `nome`) para casar com o tipo `Time`.
Nenhum campo se chama `saldo`, porque `saldo :: Linha -> Int` é uma função obrigatória
da Camada 2 e os dois nomes colidiriam.

### 🕓 Consultas básicas

- `participou t p`: `t` é o mandante **ou** o visitante.
- `resultadoPara t p`: compara os gols do ponto de vista de `t`; `Nothing` se `t` não jogou.
  É a única fonte da verdade sobre "quem ganhou": a Camada 2 não compara gols de novo.
- `times`: junta mandantes e visitantes, remove repetidos com `nub` e ordena com `sort`.
  Evitamos o idioma `map head . group . sort` porque `head` é parcial.

### 🕓 Campeonato de teste (`Dados.hs`)

Times do futebol paranaense (Athletico, Coritiba, Paraná, Operário, Londrina, Cascavel):
6 times em turno único dão exatamente **5 rodadas de 3 jogos**, com cada time jogando uma
vez por rodada. O campeonato será montado para ter, no mínimo: um 0 x 0, uma vitória por
3 ou mais gols, e dois times empatados em pontos cuja ordem seja decidida por um critério
de desempate (e um teste deixando claro qual critério decidiu).

Os dados ficam como `String` (`unlines [...]`) no próprio código, no formato da Camada 3,
para que o `main` passe pela leitura e pela validação, exatamente como uma entrada real.

---

## 2. Camada 2 - Classificação (`Classificacao.hs`)

### 🕓 Sem recursão explícita; só `map`, `filter`, dobras e composição

### 🕓 `linhaDoTime` com `foldl'` (dobra à esquerda estrita, de `Data.List`)

A linha começa "zerada" e cada partida em que o time jogou é somada a ela, na ordem das
rodadas. Uma dobra à esquerda descreve exatamente isso (acumulador = linha parcial).
Usamos a versão estrita `foldl'`, como em `saldoFinal = foldl' aplicar` (Aula 12), para não
acumular cálculos pendentes. O resultado de cada partida vem de `resultadoPara`, tratado
como `Maybe` (com `maybe`).

### 🕓 Ordenação como **uma única** comparação

```haskell
sortBy (comparing (Down . pontosLinha)
     <> comparing (Down . vitorias)
     <> comparing (Down . saldo)
     <> comparing (Down . golsPro)
     <> comparing time)
```

`Ordering` é um `Monoid`: `<>` só olha o próximo critério quando o anterior deu `EQ`.
Evita a armadilha de encadear vários `sortBy` esperando que um preserve o anterior.

### 🕓 Funções totais

- `aproveitamento`: `fromIntegral` nos dois lados da divisão (não `div`), em **percentual de 0 a 100**;
  0 quando o time não jogou (evita divisão por zero).
- `maiorGoleada` e `mediaGols`: `Nothing` para lista vazia, sem `head`, `maximum` ou `foldr1`.
  Em `maiorGoleada`, se duas partidas tiverem a mesma diferença, vale a que aparece primeiro.
- `ateRodada n`: `filter ((<= n) . rodada)`.

---

## 3. Camada 3 - Leitura e validação (`Leitura.hs`)

### 🕓 Erros carregam o número da linha **do texto original**

As linhas são numeradas (`zip [1 ..]`) **antes** de descartar linhas em branco e comentários,
para que "linha 7" aponte para a linha 7 que a pessoa vê no arquivo.

### 🕓 Construtores de `Erro`

Os cinco exigidos (`CamposInvalidos`, `NumeroInvalido`, `PlacarNegativo`, `MesmoTime`,
`TimeRepetidoNaRodada`), cada um com a linha (ou a rodada, no caso do time repetido) e,
quando ajuda a mensagem, o trecho problemático (ex.: o texto que não virou número).
Avaliando incluir também rodada menor que 1 e nome de time vazio.

### 🕓 `lerPartida` com `do` na mônada `Either`

Ordem das verificações: quantidade de campos → números (`readMaybe`, nunca `read`)
→ placar negativo → mesmo time. O primeiro `Left` interrompe o resto, sem `case` aninhado.
Espaços em volta dos campos são removidos (`" Coritiba "` vira `"Coritiba"`).

### 🕓 `lerCampeonato` vs. `todosOsErros`

- `lerCampeonato`: `traverse` sobre as linhas (para no primeiro erro) e, se todas forem
  válidas, verifica times repetidos na mesma rodada.
- `todosOsErros`: valida cada linha de forma independente e junta **todos** os `Left`
  (mais os erros de rodada), para o relatório completo.

---

## Limitações conhecidas

- **Critérios de desempate parciais**: confronto direto, cartões e sorteio não são modelados
  (a entrada não tem cartões). A ordem alfabética entra só como último critério determinístico,
  o que não é o regulamento real.
- **Nome do time é comparado exatamente**: "Paraná" e "Parana" (ou "paraná") viram dois times
  diferentes. Não normalizamos acento nem maiúsculas para não "corrigir" a entrada por conta própria.
- **`jogos` é redundante** com `vitorias + empates + derrotas`. O campo existe porque o enunciado
  pede; a consistência é garantida por construção (toda `Linha` sai de `linhaDoTime`), não pelo tipo.
- **Gols são `Int`**: o tipo aceita negativos; a regra "placar não negativo" é verificada em tempo de
  execução, na leitura (como discutido na Aula 13, "Tipos não resolvem tudo").
