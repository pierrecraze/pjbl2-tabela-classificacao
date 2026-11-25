module Main (main) where

import System.IO (hSetEncoding, stdout, utf8)

import Tipos

-- ===== Main: demonstração das três camadas =====
-- Única parte do programa com IO. As demonstrações das Camadas 2 e 3
-- entram conforme forem implementadas.

-- | Partida do exemplo do enunciado, só para exercitar os tipos da Camada 1.
exemplo :: Partida
exemplo = Partida 1 "Coritiba" 2 1 "Athletico"

main :: IO ()
main = do
  -- nomes como "Paraná" e "Operário" têm acento; sem isso o terminal do
  -- Windows (ou um shell sem locale UTF-8) derruba o programa ao imprimir
  hSetEncoding stdout utf8
  putStrLn "=== Camada 1: tipos ==="
  print exemplo
  putStrLn (mandante exemplo ++ " " ++ show (golsMandante exemplo)
            ++ " x " ++ show (golsVisitante exemplo) ++ " " ++ visitante exemplo)
  print [minBound .. maxBound :: Resultado]
