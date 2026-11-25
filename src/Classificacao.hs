module Classificacao
  ( pontos
  , pontosLinha
  , saldo
  , aproveitamento
  , ateRodada
  ) where

import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

pontosLinha :: Linha -> Int
pontosLinha linha = pontos Vitoria * vitorias linha + pontos Empate * empates linha

saldo :: Linha -> Int
saldo linha = golsPro linha - golsContra linha

-- percentual de 0 a 100
aproveitamento :: Linha -> Double
aproveitamento linha
  | jogos linha == 0 = 0
  | otherwise        = 100 * fromIntegral (pontosLinha linha) / fromIntegral disputados
  where
    disputados = pontos Vitoria * jogos linha

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n = filter ((<= n) . rodada)
