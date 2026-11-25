module Dados
  ( dadosCampeonato
  , dadosComErros
  ) where

-- ===== Campeonato de teste (Camada 1 / entrada da Camada 3) =====
-- 6 times paranaenses em turno único = 5 rodadas de 3 partidas (nenhum time repete na mesma rodada).
--
-- Conferência manual da classificação final:
-- 1. Athletico : 10 pts | 5J 3V 1E 1D | 9 GP,  4 GC, SG  +5
-- 2. Coritiba  : 10 pts | 5J 3V 1E 1D | 7 GP,  3 GC, SG  +4
-- 3. Londrina  : 10 pts | 5J 3V 1E 1D | 7 GP,  4 GC, SG  +3
--    -> Triplo empate em pontos (10) e vitórias (3); ordem decidida pelo saldo de gols.
-- 4. Paraná    :  5 pts | 5J 1V 2E 2D | 5 GP,  6 GC, SG  -1
-- 5. Operário  :  4 pts | 5J 1V 1E 3D | 4 GP,  5 GC, SG  -1
-- 6. Cascavel  :  3 pts | 5J 1V 0E 4D | 1 GP, 11 GC, SG -10

dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# Campeonato Paranaense de Teste - 6 times, 5 rodadas"
  , "# rodada; mandante; gols mandante; gols visitante; visitante"
  , ""
  , "# Rodada 1"
  , "1; Coritiba; 1; 2; Athletico"
  , "1; Paraná; 1; 1; Londrina"
  , "1; Operário; 2; 0; Cascavel"
  , ""
  , "# Rodada 2"
  , "2; Athletico; 1; 1; Paraná"
  , "2; Coritiba; 0; 0; Operário"
  , "2; Londrina; 2; 0; Cascavel"
  , ""
  , "# Rodada 3"
  , "3; Athletico; 4; 0; Cascavel"
  , "3; Coritiba; 2; 1; Paraná"
  , "3; Londrina; 2; 1; Operário"
  , ""
  , "# Rodada 4"
  , "4; Londrina; 2; 1; Athletico"
  , "4; Coritiba; 3; 0; Cascavel"
  , "4; Operário; 1; 2; Paraná"
  , ""
  , "# Rodada 5"
  , "5; Athletico; 1; 0; Operário"
  , "5; Coritiba; 1; 0; Londrina"
  , "5; Paraná; 0; 1; Cascavel"
  ]

dadosComErros :: String
dadosComErros = unlines
  [ "# Exemplo de entrada com múltiplos erros"
  , "1; Coritiba; 2; 1; Athletico"
  , "1; Coritiba; 0; 0; Londrina"
  , "2; Paraná; dois; 1; Operário"
  , "2; Cascavel; -1; 2; Londrina"
  , "3; Athletico; 1; 1; Athletico"
  , "3; campo_faltando; 1; 0"
  ]
