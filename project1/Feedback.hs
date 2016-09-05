module Feedback (feedback, equalCards, rankLower, lowestRank, correctRank, correctSuit, equalRankOrSuit, rankHigher, highestRank) where

import Card
import GameState
import Data.List

feedback :: [Card] -> [Card] -> (Int, Int, Int, Int, Int)
feedback [] [] = (0, 0, 0, 0, 0)
feedback target guess = (a, b, c, d, e)
                        where a = equalCards target guess
                              b = rankLower target guess
                              c = correctRank target guess
                              d = rankHigher target guess
                              e = correctSuit target guess

equalCards :: [Card] -> [Card] -> Int
equalCards [] [] = 0
equalCards target guess = length (filter (`elem` target) guess)

rankLower :: [Card] -> [Card] -> Int
rankLower [] _ = 0
rankLower (target:xs) guess = if rank target < rank lowest then 1 + (rankLower xs guess)
                              else rankLower xs guess
                              where lowest = lowestRank guess

lowestRank :: [Card] -> Card
lowestRank [c] = c
lowestRank (c1:c2:cs) = if rank c1 < rank c2 then lowestRank (c1:cs)
                        else lowestRank (c2:cs)

correctRank :: [Card] -> [Card] -> Int
correctRank [] _ = 0
correctRank _ [] = 0
correctRank target guess = equalRankOrSuit targetRanks guessRanks
                           where targetRanks = sort (map rank target)
                                 guessRanks = sort (map rank guess)

correctSuit :: [Card] -> [Card] -> Int
correctSuit [] _ = 0
correctSuit _ [] = 0
correctSuit target guess = equalRankOrSuit targetSuits guessSuits
                        where targetSuits = sort (map suit target)
                              guessSuits = sort (map suit guess)

equalRankOrSuit :: (Ord a) => [a] -> [a] -> Int
equalRankOrSuit [] _ = 0
equalRankOrSuit _ [] = 0
equalRankOrSuit (x:xs) (y:ys)
    | x > y  = equalRankOrSuit (x:xs) ys
    | x < y  = equalRankOrSuit xs (y:ys)
    | x == y = 1 + equalRankOrSuit xs ys

rankHigher :: [Card] -> [Card] -> Int
rankHigher [] _ = 0
rankHigher (target:xs) guess = if rank target > rank highest then 1 + (rankLower xs guess)
                              else rankHigher xs guess
                              where highest = highestRank guess

highestRank :: [Card] -> Card
highestRank [c] = c
highestRank (c1:c2:cs) = if rank c1 > rank c2 then highestRank (c1:cs)
                        else highestRank (c2:cs)
