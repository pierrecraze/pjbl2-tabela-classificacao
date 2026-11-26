module Main (main) where

import Control.Monad (unless)
import Data.List (nub)
import System.Exit (exitFailure)
import Classificacao
import Dados
import Leitura
import Tipos

main :: IO ()
main = do
  let jogo = Partida 1 "Coritiba" 1 2 "Athletico"
      empate = Partida 2 "Athletico" 0 0 "Londrina"
      goleada = Partida 3 "Londrina" 4 0 "Coritiba"
      -- Athletico e Londrina terminam com 4 pontos e 1 vitoria cada:
      -- quem decide e o saldo (Londrina +4, Athletico +1)
      tresRodadas = [jogo, empate, goleada]
      linhaAthletico = linhaDoTime [jogo, empate] "Athletico"
      conferir nome obtido esperado =
        (nome, obtido == esperado, show obtido)
      casos =
        [ conferir "participou como mandante" (participou "Coritiba" jogo) True
        , conferir "participou como visitante" (participou "Athletico" jogo) True
        , conferir "nao participou" (participou "Londrina" jogo) False
        , conferir "derrota em casa" (resultadoPara "Coritiba" jogo) (Just Derrota)
        , conferir "vitoria fora" (resultadoPara "Athletico" jogo) (Just Vitoria)
        , conferir "empate em casa" (resultadoPara "Athletico" empate) (Just Empate)
        , conferir "empate fora" (resultadoPara "Londrina" empate) (Just Empate)
        , conferir "resultado de ausente" (resultadoPara "Londrina" jogo) Nothing
        , conferir "times sem jogos" (times []) []
        , conferir "times em ordem e sem repeticao" (times [jogo, empate])
            ["Athletico", "Coritiba", "Londrina"]
        , conferir "pontos de cada resultado" (map pontos [minBound .. maxBound]) [3, 1, 0]
        , conferir "linha de quem venceu e empatou" linhaAthletico
            (Linha "Athletico" 2 1 1 0 2 1)
        , conferir "linha de quem perdeu em casa" (linhaDoTime [jogo, empate] "Coritiba")
            (Linha "Coritiba" 1 0 0 1 1 2)
        , conferir "linha de quem nao jogou" (linhaDoTime [jogo, empate] "Cascavel")
            (Linha "Cascavel" 0 0 0 0 0 0)
        , conferir "pontos da linha" (pontosLinha linhaAthletico) 4
        , conferir "saldo da linha" (saldo linhaAthletico) 1
        , conferir "aproveitamento total" (aproveitamento (linhaDoTime [jogo] "Athletico")) 100
        , conferir "aproveitamento sem jogos" (aproveitamento (linhaDoTime [] "Cascavel")) 0
        , conferir "ate a rodada 1" (ateRodada 1 [jogo, empate]) [jogo]
        , conferir "ate a rodada 0" (ateRodada 0 [jogo, empate]) []
        , conferir "classificacao sem partidas" (classificacao []) []
        , conferir "desempate pelo saldo (mesmos pontos e vitorias)"
            (map time (classificacao tresRodadas)) ["Londrina", "Athletico", "Coritiba"]
        , conferir "pontos empatados de quem desempatou"
            (map pontosLinha (classificacao tresRodadas)) [4, 4, 0]
        , conferir "classificacao ate a rodada 2 difere da final"
            (map time (classificacao (ateRodada 2 tresRodadas))) ["Athletico", "Londrina", "Coritiba"]
        , conferir "maior goleada" (maiorGoleada tresRodadas) (Just goleada)
        , conferir "maior goleada sem partidas" (maiorGoleada []) Nothing
        , conferir "media de gols" (mediaGols [jogo, goleada]) (Just 3.5)
        , conferir "media de gols sem partidas" (mediaGols []) Nothing
        -- camada 3: separar e lerPartida
        , conferir "separar mantem campos vazios" (separar ';' "a;;b;") ["a", "", "b", ""]
        , conferir "separar texto vazio" (separar ';' "") [""]
        , conferir "lerPartida valida, com espacos"
            (lerPartida 1 " 1 ; Coritiba ; 1 ; 2 ; Athletico ") (Right jogo)
        , conferir "CamposInvalidos" (lerPartida 2 "1;Coritiba;1;2")
            (Left (CamposInvalidos 2 4))
        , conferir "NumeroInvalido no placar" (lerPartida 3 "2;Parana;dois;1;Operario")
            (Left (NumeroInvalido 3 "dois"))
        , conferir "NumeroInvalido na rodada" (lerPartida 4 "2a;Parana;1;1;Operario")
            (Left (NumeroInvalido 4 "2a"))
        , conferir "PlacarNegativo" (lerPartida 5 "2;Cascavel;-1;2;Londrina")
            (Left (PlacarNegativo 5))
        , conferir "MesmoTime" (lerPartida 6 "3;Athletico;1;1;Athletico")
            (Left (MesmoTime 6 "Athletico"))
        , conferir "RodadaInvalida" (lerPartida 7 "0;Coritiba;1;0;Londrina")
            (Left (RodadaInvalida 7 0))
        , conferir "TimeVazio" (lerPartida 8 "1; ;1;0;Londrina")
            (Left (TimeVazio 8))
        , conferir "primeiro erro interrompe o resto" (lerPartida 9 "x;A;-1;0;A")
            (Left (NumeroInvalido 9 "x"))
        -- camada 3: campeonato inteiro (Dados.hs)
        , conferir "lerCampeonato valido devolve Right com 15 partidas"
            (fmap length (lerCampeonato dadosCampeonato)) (Right 15)
        , conferir "classificacao final do campeonato de teste"
            (fmap (map time . classificacao) (lerCampeonato dadosCampeonato))
            (Right ["Athletico", "Coritiba", "Londrina", "Paraná", "Operário", "Cascavel"])
        , conferir "triplo empate em pontos e vitorias, decidido pelo saldo"
            (fmap (map (\l -> (pontosLinha l, vitorias l, saldo l)) . take 3 . classificacao)
                  (lerCampeonato dadosCampeonato))
            (Right [(10, 3, 5), (10, 3, 4), (10, 3, 3)])
        , conferir "pontos da tabela final"
            (fmap (map pontosLinha . classificacao) (lerCampeonato dadosCampeonato))
            (Right [10, 10, 10, 5, 4, 3])
        , conferir "classificacao ate a rodada 3 difere da final"
            (fmap (map time . classificacao . ateRodada 3) (lerCampeonato dadosCampeonato))
            (Right ["Athletico", "Londrina", "Operário", "Coritiba", "Paraná", "Cascavel"])
        , conferir "campeonato vazio" (lerCampeonato "# so comentario\n\n") (Right [])
        , conferir "TimeRepetidoNaRodada"
            (lerCampeonato "1;Coritiba;2;1;Athletico\n1;Coritiba;0;0;Londrina")
            (Left (TimeRepetidoNaRodada 1 "Coritiba"))
        , conferir "lerCampeonato para no primeiro erro de linha"
            (lerCampeonato dadosComErros) (Left (NumeroInvalido 4 "dois"))
        , conferir "todosOsErros lista todos, com a linha do texto original"
            (todosOsErros dadosComErros)
            [ NumeroInvalido 4 "dois", PlacarNegativo 5, MesmoTime 6 "Athletico"
            , CamposInvalidos 7 4, TimeRepetidoNaRodada 1 "Coritiba" ]
        , conferir "todosOsErros de entrada valida" (todosOsErros dadosCampeonato) []
        -- camada 3: saida
        , conferir "tabela vazia tem so o cabecalho"
            (map words (lines (tabelaFormatada [])))
            [["Pos", "Time", "P", "J", "V", "E", "D", "SG"]]
        , conferir "tabela final: cabecalho + 6 times"
            (fmap (length . lines . tabelaFormatada . classificacao) (lerCampeonato dadosCampeonato))
            (Right 7)
        , conferir "linha do lider na tabela formatada"
            (fmap (map words . take 1 . drop 1 . lines . tabelaFormatada . classificacao)
                  (lerCampeonato dadosCampeonato))
            (Right [["1", "Athletico", "10", "5", "3", "1", "1", "+5"]])
        , conferir "colunas alinhadas (todas as linhas com a mesma largura)"
            (fmap (length . nub . map length . lines . tabelaFormatada . classificacao)
                  (lerCampeonato dadosCampeonato))
            (Right 1)
        , conferir "mensagem de erro cita a linha"
            (descreverErro (NumeroInvalido 4 "dois")) "linha 4: \"dois\" não é um número inteiro"
        , conferir "mensagem de erro de rodada cita a rodada"
            (descreverErro (TimeRepetidoNaRodada 1 "Coritiba"))
            "rodada 1: Coritiba está escalado em mais de uma partida"
        ]
  mapM_ (\(nome, ok, valor) -> putStrLn
    (if ok then "OK " ++ nome else "FALHOU " ++ nome ++ ": " ++ valor)) casos
  unless (all (\(_, ok, _) -> ok) casos) exitFailure
