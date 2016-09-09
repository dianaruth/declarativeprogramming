module Feedback (feedback) where

import Card
import GameState
import Data.List

feedback :: [Card] -> [Card] -> (Int, Int, Int, Int, Int)
feedback [] [] = (0, 0, 0, 0, 0)
feedback target guess = (a, b, c, d, e)
                        where a = equalCards target guess
                              b = compareRanks target guess (<)
                              c = correctRankOrSuit (sort $ map rank target) (sort $ map rank guess)
                              d = compareRanks target guess (>)
                              e = correctRankOrSuit (sort $ map suit target) (sort $ map suit guess)

equalCards :: [Card] -> [Card] -> Int
equalCards [] [] = 0
equalCards target guess = length (filter (`elem` target) guess)

correctRankOrSuit :: (Ord a) => [a] -> [a] -> Int
correctRankOrSuit [] _ = 0
correctRankOrSuit _ [] = 0
correctRankOrSuit target guess = equalRankOrSuit target guess

equalRankOrSuit :: (Ord a) => [a] -> [a] -> Int
equalRankOrSuit [] _ = 0
equalRankOrSuit _ [] = 0
equalRankOrSuit (x:xs) (y:ys)
    | x > y  = equalRankOrSuit (x:xs) ys
    | x < y  = equalRankOrSuit xs (y:ys)
    | x == y = 1 + equalRankOrSuit xs ys

compareRanks :: [Card] -> [Card] -> (Rank -> Rank -> Bool) -> Int
compareRanks [] _ _ = 0
compareRanks (target:xs) guess f = if f (rank target) (rank highest) then 1 + (compareRanks xs guess f)
                               else compareRanks xs guess f
                               where highest = highOrLowRank guess f

highOrLowRank :: [Card] -> (Rank -> Rank -> Bool) -> Card
highOrLowRank[c] _ = c
highOrLowRank (c1:c2:cs) f = if f (rank c1) (rank c2) then highOrLowRank (c1:cs) f
                         else highOrLowRank (c2:cs) f
