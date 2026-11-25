module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)
import Tipos

main :: IO ()
main = do
  let jogo = Partida 1 "Coritiba" 1 2 "Athletico"
      empate = Partida 2 "Athletico" 0 0 "Londrina"
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
        ]
  mapM_ (\(nome, ok, valor) -> putStrLn
    (if ok then "OK " ++ nome else "FALHOU " ++ nome ++ ": " ++ valor)) casos
  unless (all (\(_, ok, _) -> ok) casos) exitFailure
