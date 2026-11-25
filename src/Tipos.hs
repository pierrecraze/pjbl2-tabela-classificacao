module Tipos
  ( Time
  , Resultado (..)
  , Partida (..)
  , Linha (..)
  ) where

-- ===== Camada 1: Tipos e Dados do Campeonato =====
-- Define o que existe no domínio. As decisões estão em docs/decisoes.md.

-- | Nome de um time. Apelido (type): só deixa as assinaturas mais legíveis.
type Time = String

-- | Resultado de uma partida do ponto de vista de um time.
-- Tipo soma: só existem estes três valores, e o -Wall avisa se algum
-- caso ficar sem tratamento. Sem Ord de propósito: quem diz quanto vale
-- cada resultado é a função pontos (Camada 2), não a ordem da declaração.
data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq, Enum, Bounded)

-- | Uma partida, na ordem em que um placar é lido:
--   Partida 1 "Coritiba" 2 1 "Athletico"  ==  rodada 1, Coritiba 2 x 1 Athletico
data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)

-- | Uma linha da tabela de classificação.
-- Guarda só contagens; pontos e saldo são derivados (pontosLinha e saldo,
-- na Camada 2), para não existir uma linha com pontos que não batem.
data Linha = Linha
  { time       :: Time
  , jogos      :: Int
  , vitorias   :: Int
  , empates    :: Int
  , derrotas   :: Int
  , golsPro    :: Int
  , golsContra :: Int
  } deriving (Show, Eq)
