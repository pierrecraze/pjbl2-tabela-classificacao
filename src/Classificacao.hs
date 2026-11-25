module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  , ateRodada
  ) where

-- qualificado porque a partir do ghc 9.10 o prelude tambem exporta foldl'
import qualified Data.List as L

import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas equipe = L.foldl' somar (Linha equipe 0 0 0 0 0 0) partidas
  where
    somar linha partida =
      maybe linha (contar linha (golsDa partida)) (resultadoPara equipe partida)

    -- gols a favor e contra do ponto de vista da equipe
    golsDa partida
      | mandante partida == equipe = (golsMandante partida, golsVisitante partida)
      | otherwise                  = (golsVisitante partida, golsMandante partida)

    contar linha (pro, contra) resultado =
      let nova = linha { jogos      = jogos linha + 1
                       , golsPro    = golsPro linha + pro
                       , golsContra = golsContra linha + contra
                       }
      in case resultado of
           Vitoria -> nova { vitorias = vitorias nova + 1 }
           Empate  -> nova { empates = empates nova + 1 }
           Derrota -> nova { derrotas = derrotas nova + 1 }

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
