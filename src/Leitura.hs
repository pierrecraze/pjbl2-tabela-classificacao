module Leitura
  ( Erro (..)
  , separar
  , lerPartida
  ) where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import Text.Read (readMaybe)

import Tipos

-- ===== Camada 3: Leitura, Validação e Saída =====
-- Os resultados chegam como texto ("rodada;mandante;gols;gols;visitante").
-- Toda entrada inválida vira um Left com um Erro que diz a linha (ou a
-- rodada) do problema; nada aqui pode lançar exceção.

-- | Problemas que uma entrada pode ter. O primeiro Int é sempre o número da
-- linha no texto original (ou a rodada, em TimeRepetidoNaRodada).
data Erro
  = CamposInvalidos Int Int          -- linha, quantos campos vieram (esperado: 5)
  | NumeroInvalido Int String        -- linha, texto que não virou número
  | PlacarNegativo Int               -- linha
  | MesmoTime Int Time               -- linha, time que jogaria contra si mesmo
  | TimeRepetidoNaRodada Int Time    -- rodada, time escalado duas vezes nela
  | RodadaInvalida Int Int           -- linha, rodada menor que 1
  | TimeVazio Int                    -- linha com nome de time em branco
  deriving (Show, Eq)

-- | Quebra uma linha em cada separador. Campos vazios são mantidos
-- (separar ';' "a;;b" == ["a","","b"]), para a contagem de campos não mentir.
-- A Camada 3 permite recursão; o break deixa claro onde cada campo termina.
separar :: Char -> String -> [String]
separar sep texto =
  case break (== sep) texto of
    (campo, [])        -> [campo]
    (campo, _ : resto) -> campo : separar sep resto

-- | Converte uma linha (com o seu número) em partida. Cada passo do do pode
-- falhar com um Left, e o primeiro Left interrompe o resto: sem case aninhado.
lerPartida :: Int -> String -> Either Erro Partida
lerPartida n linha = do
  (r, m, gm, gv, v) <- cincoCampos n (map aparar (separar ';' linha))
  rod   <- lerNumero n r
  golsM <- lerNumero n gm
  golsV <- lerNumero n gv
  exigir (rod >= 1)                   (RodadaInvalida n rod)
  exigir (not (null m || null v))     (TimeVazio n)
  exigir (golsM >= 0 && golsV >= 0)   (PlacarNegativo n)
  exigir (m /= v)                     (MesmoTime n m)
  Right (Partida rod m golsM golsV v)

-- ---------- auxiliares (não exportadas) ----------

-- remove espaços em volta de um campo: " Coritiba " vira "Coritiba"
aparar :: String -> String
aparar = dropWhileEnd isSpace . dropWhile isSpace

cincoCampos :: Int -> [String] -> Either Erro (String, String, String, String, String)
cincoCampos _ [r, m, gm, gv, v] = Right (r, m, gm, gv, v)
cincoCampos n campos            = Left (CamposInvalidos n (length campos))

-- readMaybe no lugar de read: "dois" ou "2a" viram Nothing em vez de exceção,
-- e o maybe transforma esse Nothing num erro que aponta a linha
lerNumero :: Int -> String -> Either Erro Int
lerNumero n txt = maybe (Left (NumeroInvalido n txt)) Right (readMaybe txt)

exigir :: Bool -> Erro -> Either Erro ()
exigir condicao erro
  | condicao  = Right ()
  | otherwise = Left erro
