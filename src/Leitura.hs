module Leitura
  ( Erro (..)
  , separar
  , lerPartida
  , lerCampeonato
  , todosOsErros
  ) where

import Data.Char (isSpace)
import Data.Either (lefts, rights)
import Data.List (dropWhileEnd, isPrefixOf, nub, (\\))
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

-- | Lê o texto inteiro. O traverse aplica lerPartida a cada linha e para no
-- primeiro Left; se todas as linhas forem válidas, ainda confere se algum time
-- foi escalado duas vezes na mesma rodada.
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasUteis texto)
  case errosDeRodada partidas of
    []         -> Right partidas
    (erro : _) -> Left erro

-- | Relatório completo: cada linha é lida de forma independente, então um erro
-- não esconde os seguintes. As partidas válidas ainda passam pela checagem de
-- time repetido na rodada.
todosOsErros :: String -> [Erro]
todosOsErros texto = lefts lidas ++ errosDeRodada (rights lidas)
  where
    lidas = map (uncurry lerPartida) (linhasUteis texto)

-- ---------- auxiliares (não exportadas) ----------

-- linhas que contêm partidas, já com o número da linha no texto original:
-- a numeração vem antes do filtro, então "linha 7" é a sétima linha que a
-- pessoa vê no arquivo, contando comentários e linhas em branco
linhasUteis :: String -> [(Int, String)]
linhasUteis = filter (temPartida . snd) . zip [1 ..] . lines
  where
    temPartida linha = not (null (aparar linha) || "#" `isPrefixOf` aparar linha)

-- um erro para cada time que aparece mais de uma vez numa mesma rodada,
-- na ordem das rodadas
errosDeRodada :: [Partida] -> [Erro]
errosDeRodada partidas =
  [ TimeRepetidoNaRodada r equipe
  | r <- nub (map rodada partidas)
  , equipe <- repetidos (concatMap escalados (filter ((== r) . rodada) partidas))
  ]
  where
    escalados p = [mandante p, visitante p]
    -- xs \\ nub xs tira uma ocorrência de cada; o que sobra é o que se repetiu
    repetidos xs = nub (xs \\ nub xs)


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
