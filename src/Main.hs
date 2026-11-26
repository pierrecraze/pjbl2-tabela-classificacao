module Main (main) where

import Data.Maybe (listToMaybe)
import System.IO (hSetEncoding, stdout, utf8)

import Classificacao
import Dados
import Leitura
import Tipos

-- ===== Main: demonstração das três camadas =====
-- main é a única função com IO: ela só fixa a codificação da saída e imprime
-- o relatório. Todo o resto deste módulo é puro e monta texto.

main :: IO ()
main = do
  -- nomes como "Paraná" e "Operário" têm acento; sem isso o terminal do
  -- Windows (ou um shell sem locale UTF-8) derruba o programa ao imprimir
  hSetEncoding stdout utf8
  putStr relatorio

-- | Tudo que o programa mostra, em sequência: tabela final, tabela numa rodada
-- intermediária, estatísticas e o tratamento de uma entrada com erros.
relatorio :: String
relatorio =
  either falhaNaLeitura demonstracao (lerCampeonato dadosCampeonato)
    ++ entradaComErros

-- se o campeonato de teste tivesse algum erro, o programa explica e segue
falhaNaLeitura :: Erro -> String
falhaNaLeitura erro =
  secao "Campeonato de teste" ++ "Não foi possível ler: " ++ descreverErro erro ++ "\n"

demonstracao :: [Partida] -> String
demonstracao partidas =
  secao "Classificação final"
    ++ tabelaFormatada (classificacao partidas)
    ++ secao "Classificação após a rodada 3"
    ++ tabelaFormatada (classificacao (ateRodada 3 partidas))
    ++ secao "Estatísticas"
    ++ estatisticas partidas

estatisticas :: [Partida] -> String
estatisticas partidas = unlines
  [ "Maior goleada: " ++ maybe "nenhuma partida" placar (maiorGoleada partidas)
  , "Média de gols por partida: " ++ maybe "sem partidas" duasCasas (mediaGols partidas)
  , "Aproveitamento do líder: "
      ++ maybe "sem times" aproveitamentoDe (listToMaybe (classificacao partidas))
  ]
  where
    aproveitamentoDe l = time l ++ ", " ++ duasCasas (aproveitamento l) ++ "%"

entradaComErros :: String
entradaComErros =
  secao "Entrada com erros (dadosComErros)"
    ++ "lerCampeonato para no primeiro erro:\n  "
    ++ either descreverErro (const "nenhum erro") (lerCampeonato dadosComErros) ++ "\n"
    ++ "todosOsErros lista todos:\n"
    ++ unlines (map (("  - " ++) . descreverErro) (todosOsErros dadosComErros))

-- ---------- formatação ----------

secao :: String -> String
secao titulo = "\n=== " ++ titulo ++ " ===\n"

placar :: Partida -> String
placar p =
  mandante p ++ " " ++ show (golsMandante p) ++ " x " ++ show (golsVisitante p)
    ++ " " ++ visitante p ++ " (rodada " ++ show (rodada p) ++ ")"

-- número com duas casas e vírgula decimal, sem Text.Printf (fora da lista do enunciado)
duasCasas :: Double -> String
duasCasas x = show inteiro ++ "," ++ centavos
  where
    total :: Int
    total = round (x * 100)
    inteiro = total `div` 100
    resto = total `mod` 100
    centavos = (if resto < 10 then "0" else "") ++ show resto
