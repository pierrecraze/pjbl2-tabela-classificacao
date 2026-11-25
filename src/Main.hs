module Main (main) where

import System.IO (hSetEncoding, stdout, utf8)

-- ===== Main: demonstração das três camadas =====
-- Única parte do programa com IO. Por enquanto só confirma que o projeto
-- compila; as demonstrações entram conforme cada camada for implementada.

main :: IO ()
main = do
  -- nomes como "Paraná" e "Operário" têm acento; sem isso o terminal do
  -- Windows (ou um shell sem locale UTF-8) derruba o programa ao imprimir
  hSetEncoding stdout utf8
  putStrLn "PjBL2 - Tabela de Classificação (em construção)"
