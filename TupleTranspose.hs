{-# LANGUAGE TemplateHaskell#-}
module TupleTranspose where

--import Language.Haskell.TH

{-
TODO

Create generic accessor/tensor product functions for endo n-functors in the category of tuples
Create generic transpose
-}

--Endobifunctors in the category of tuples

--Left tensor product

lTp :: (a,b) -> (c,d) -> (a,c)
lTp tab tcd = (,) (fst tab) (fst tcd)

--Right tensor product

rTp :: (a,b) -> (c,d) -> (b,d)
rTp tab tcd = (,) (snd tab) (snd tcd)

--Endofunctor in the category of array's containing 2 - tuples

transpose :: [(c, c)] -> [(c, c)]
transpose (l1:l2:l) = lTp l1 l2 : rTp l1 l2 : transpose l
transpose [] = []