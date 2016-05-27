module AtomOM1
  ( compileOM1 )
where

import Data.Word
import Language.Atom


-- Parameters ----------------------------------------------------------

sourcePeriod = 20
observerPeriod = 20


-- Messages ------------------------------------------------------------

type MsgType = Word64

-- | Special message type value indicating "no message present"
missingMsgValue :: MsgType
missingMsgValue = 0

-- | Delcare a local variable of message type
msgVar :: Name -> Atom (V MsgType)
msgVar = flip word64 missingMsgValue


-- OM1 Spec ------------------------------------------------------------

om1 :: Atom ()
om1 = do

  -- setup channels for communication bewteen source, relays, and receivers
  c1v <- msgVar "c1v"
  c1 <- vchannel c1v  -- :: VChannel MsgType

  atom "source" $ source c1

  atom "observer" $ observer c1


source :: VChannel MsgType -> Atom ()
source c1 = do
  done <- bool "done" False
  msg  <- msgVar "msg"
  msg  <== 1
  period sourcePeriod $ do
    cond $ not_ (value done)
    updateVChannel c1 (value msg)
    writeVChannel c1
    done <== Const True


observer :: VChannel MsgType -> Atom ()
observer c1 = period observerPeriod $ do
  v <- obsVChannel c1  -- non-disruptive read
  printIntegralE "v = " v


-- Variable Channels ---------------------------------------------------

type VChannel a = Channel (V a)

vchannel :: V a -> Atom (VChannel a)
vchannel = channel

-- | Write the value of the held variable to the channel; sets 'hasData' to
-- True
writeVChannel :: VChannel a -> Atom ()
writeVChannel = writeChannel

-- | Read the channel if it has data available; sets 'hasData' to False
readVChannel :: VChannel a -> Atom (E a)
readVChannel c = value <$> readChannel c

-- | Read the channel without affecting its 'hasData' state
obsVChannel :: VChannel a -> Atom (E a)
obsVChannel (Channel var _) = return $ value var

-- | Update the value of the variable held by the channel
updateVChannel :: Assign a => VChannel a -> E a -> Atom ()
updateVChannel (Channel var _) expr = do
  var <== expr


-- Code Generator ------------------------------------------------------

-- | Invoke the atom compiler, generating 'om1.{c,h}'
-- Also print out info on the generated schedule.
compileOM1 :: IO ()
compileOM1 = do
  (sched, _, _, _, _) <- compile "om1" cfg om1
  putStrLn $ reportSchedule sched
  where
    cfg = defaults { cCode = prePostCode }

-- | Custom pre-post code for generated C
prePostCode :: [Name] -> [Name] -> [(Name, Type)] -> (String, String)
prePostCode _ _ _ =
  ( unlines [ "#include <stdio.h>"
            , "#include <unistd.h>"
            , ""
            , "// ---- BEGIN of source automatically generated by Atom ----"
            ]
  , unlines [ "// ---- END of source automatically generated by Atom ----"
            , ""
            , "int main(int argc, char **argv) {"
            , "  while(1) { om1(); sleep(1); }"
            , "}"
            ]
  )
