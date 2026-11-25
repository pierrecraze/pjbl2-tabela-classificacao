module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)
import Classificacao
import Tipos

main :: IO ()
main = do
  let jogo = Partida 1 "Coritiba" 1 2 "Athletico"
      empate = Partida 2 "Athletico" 0 0 "Londrina"
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
        ]
  mapM_ (\(nome, ok, valor) -> putStrLn
    (if ok then "OK " ++ nome else "FALHOU " ++ nome ++ ": " ++ valor)) casos
  unless (all (\(_, ok, _) -> ok) casos) exitFailure
